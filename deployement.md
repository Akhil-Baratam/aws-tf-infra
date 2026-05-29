# Deployment Flow

This doc covers how code gets from a local change to running in the cluster. Two separate flows: application deploys and infra changes.

---

## Application Deploy Flow

### What kicks it off

Each of the four services has its own pipeline. Pipelines are path-scoped — only the relevant one fires when you push:

| Push touches... | Pipeline triggered |
|---|---|
| `api/patient_service.go` or `api/Dockerfile` | patient-service-pipeline |
| `api/insurance_service.go` or `api/Dockerfile` | insurance-service-pipeline |
| `api/pricing_service.go` or `api/Dockerfile` | pricing-service-pipeline |
| anything under `ui/` | ui-pipeline |

You can also trigger any pipeline manually from the GitHub Actions UI.

---

### Stage 1 — Build and push to ECR

1. **Checkout** the repo
2. **Generate image tag** from the branch name + commit SHA:
   ```
   master-a1b2c3d4
   ```
3. **Authenticate to AWS** using `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` from repo secrets
4. **Log in to ECR**
5. **Build the Docker image** for `linux/amd64` via Docker Buildx — this matches the node group's AL2023 x86_64 AMI
6. **Push two tags** to ECR:
   - `master-a1b2c3d4` (the specific build)
   - `latest`

For Go services, the build uses a shared `api/Dockerfile` with `APP_PATH` and `PORT` as build args. Final image is built on `scratch` — just the statically compiled binary, nothing else.

The versioned tag is passed to the next job as an output.

---

### Stage 2 — Update Helm values

This job runs after Stage 1 finishes. It updates the image tag in the chart so ArgoCD picks it up.

1. **Fresh checkout** with a write-capable GitHub token (full fetch depth to avoid rebase issues)
2. **Install `yq`** — used to update YAML without reformatting the whole file
3. **Update `image.tag`** in the relevant values file:
   ```yaml
   # before
   image:
     tag: "master-old12345"

   # after
   image:
     tag: "master-a1b2c3d4"
   ```
   Values files per service:
   - `helm-charts/helm-chart-api/values-patient-service.yaml`
   - `helm-charts/helm-chart-api/values-insurance-service.yaml`
   - `helm-charts/helm-chart-api/values-pricing-service.yaml`
   - `helm-charts/helm-chart-ui/values-dev.yaml`

4. **Commit and push** as `github-actions[bot]`:
   ```bash
   git commit -m "Update image tag in patient-service helm values"
   ```
   Push uses a retry loop (3 attempts, 5s apart) to handle cases where two pipelines run at the same time and race to push.

---

### Stage 3 — ArgoCD picks it up

ArgoCD is running in the cluster, watching this repo. When the Helm values file changes:

1. ArgoCD detects the diff between the repo and the live cluster state
2. It renders the Helm templates with the new values
3. Kicks off a rolling update in Kubernetes:
   - New pods spin up with the new image
   - Readiness probes pass → traffic routes to new pods
   - Old pods terminate

If the new pods fail health checks, the rollout stalls (it won't bring down the old pods). You'd need to fix and push again.

`selfHeal: true` means if someone manually changes something in the cluster, ArgoCD reverts it. `prune: true` means resources removed from Helm templates get deleted from the cluster too.

---

## Infrastructure Deploy Flow

Infrastructure is managed by two separate Terraform modules. They're intentionally split — you don't want to apply addon changes every time you touch the cluster config.

### eks — VPC + EKS cluster

Pipeline: `.github/workflows/eks-terraform.yaml`

Triggers when you push to `terraform/eks/**` or the workflow file itself.

```
push to terraform/eks/ → terraform plan runs automatically
                       → plan artifact uploaded
manual trigger (apply=true) → downloads saved plan → terraform apply
```

Apply never runs automatically. You have to go to GitHub Actions → Run workflow → check the `apply` checkbox.

What it creates:
- VPC with public and private subnets across `ap-south-1a` and `ap-south-1b`
- EKS 1.33 cluster with public API endpoint
- Managed node group `apex-dev-01` — `t3a.medium`/`t3.medium`, AL2023, 1–3 nodes
- Core Kubernetes addons: CoreDNS, kube-proxy, VPC CNI, Pod Identity Agent
- IAM access entries (replaces the old `aws-auth` ConfigMap)

State: `s3://apex-app-tf-state`, workspace `dev`, lock table `apex-app-tf-lock`.

---

### eks-addons — tooling on the cluster

Pipeline: `.github/workflows/eks-addons-terraform.yaml`

Same plan/apply pattern. Reads the EKS cluster outputs via Terraform remote state — doesn't manage the cluster itself, just installs things on it.

What it installs:
- **AWS Load Balancer Controller** — creates ALBs from Kubernetes Ingress resources, uses OIDC IAM role
- **Cluster Autoscaler** — watches pending pods and adjusts node count, uses OIDC IAM role
- **ArgoCD** — installed via Helm, exposed via an internet-facing ALB Ingress
- **Kubernetes namespaces** — `dev`, `ops`, `argocd`, `lb-controller`
- **ECR pull secrets** — created in `dev` and `ops` namespaces so pods can pull from ECR without node-level IAM fiddling

---

## Secrets Required

Set these in your GitHub repo under Settings → Secrets → Actions:

| Secret | What it's for |
|---|---|
| `AWS_ACCESS_KEY_ID` | ECR push + Terraform AWS auth |
| `AWS_SECRET_ACCESS_KEY` | ECR push + Terraform AWS auth |
| `AWS_REGION` | Target region (`ap-south-1`) |

`GITHUB_TOKEN` is injected automatically — used by the helm-update job to commit back to the repo.

---

## Full Picture

```
Developer pushes code
        │
        ▼
GitHub Actions detects path change
        │
        ├─► [app pipeline]
        │         │
        │         ├─ Build Docker image (linux/amd64)
        │         ├─ Push to ECR (master-{sha} + latest)
        │         └─ Update image.tag in Helm values → commit to master
        │                   │
        │                   ▼
        │             ArgoCD detects values change
        │                   │
        │                   └─ Rolling deploy to dev namespace on EKS
        │
        └─► [terraform pipeline] (only if terraform/** changed)
                  │
                  ├─ terraform plan (always)
                  └─ terraform apply (manual trigger only)
```