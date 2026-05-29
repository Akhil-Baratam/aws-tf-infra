# Healthcare Portal — AWS EKS Infrastructure

A full-stack healthcare billing application deployed on AWS EKS using a GitOps workflow. The repo covers everything from the application code to the infrastructure that runs it.

## What This Is

A patient consultation and billing portal. A user fills in their patient info, picks an insurance provider and doctor, and the app calculates what they owe — accounting for their state's cost-of-living adjustment, their insurance coverage, and any discount codes.

It's three Go microservices behind a React frontend, all containerised and deployed on Kubernetes.

---

## Repo Structure

```
.
├── api/                    # Three Go microservices
├── ui/                     # React frontend
├── helm-charts/            # Helm charts for all four services
├── argo-apps/              # ArgoCD Application manifests
├── terraform/
│   ├── eks/                # VPC + EKS cluster
│   └── eks-addons/         # ArgoCD, ALB controller, Cluster Autoscaler
├── .github/workflows/      # CI/CD pipelines (6 total)
└── docker-compose.yaml     # Run everything locally
```

---

## Application

### Services

| Service | Port | What it does |
|---|---|---|
| patient-service | 8001 | Verifies patient details, returns a Patient ID |
| insurance-service | 8002 | Verifies insurance, returns approval code and 90/10 coverage split |
| pricing-service | 8003 | Applies state multiplier and discount codes to the base $800 fee |
| ui | 3000 | React SPA — calls all three services in parallel, shows billing summary |

The UI fires all three API calls at the same time using `Promise.all`. There's no backend aggregator — the browser does the math.

### Pricing Logic

Base consultation fee is **$800**. The pricing service applies:

1. A state multiplier (NY is most expensive at 1.3x, OH is baseline at 1.0x)
2. An optional discount code (VETERAN gets 25% off, SENIOR 20%, etc.)

Insurance then covers 90% of the adjusted total. Patient pays the remaining 10%.

**Example:** Patient in New York with PROMO2024 discount code
- Base: $800
- NY multiplier: × 1.30 = $1,040
- 10% discount: − $104 = $936
- Insurance pays (90%): $842.40
- Patient co-pay (10%): $93.60

### Running Locally

The quickest way is Docker Compose — it builds all four images and wires them together on a shared network:

```bash
docker compose up --build
```

UI available at `http://localhost:3000`. Services run on 8001, 8002, 8003.

To run individual Go services without Docker:

```bash
# From the api/ directory
go run patient_service.go    # :8001
go run insurance_service.go  # :8002
go run pricing_service.go    # :8003
```

---

## Infrastructure

Everything runs on AWS EKS in `ap-south-1`. Infrastructure is split into two Terraform modules so the cluster and addons can be managed independently.

### eks module

Creates the base cluster:
- VPC with public and private subnets across two AZs
- EKS 1.33 with a managed node group (`t3a.medium` / `t3.medium`, AL2023)
- Node group scales between 1 and 3 nodes
- Core addons: CoreDNS, kube-proxy, VPC CNI, Pod Identity Agent

State is stored in S3 (`apex-app-tf-state`) with DynamoDB locking (`apex-app-tf-lock`).

### eks-addons module

Installs tooling on top of the cluster. Reads the cluster's outputs via remote state.

- **AWS Load Balancer Controller** — provisions ALBs from Ingress resources
- **Cluster Autoscaler** — adjusts node count based on pending pods
- **ArgoCD** — manages all application deployments via GitOps
- **ECR pull secrets** — injected into `dev` and `ops` namespaces so pods can pull images
- **Namespaces** — `dev`, `ops`, `argocd`, `lb-controller`

Both modules use OIDC-based IAM roles (no static credentials on the cluster).

---

## CI/CD

### Application Pipelines

Four workflows in `.github/workflows/`, one per service. Each is path-scoped — pushing `api/patient_service.go` only triggers the patient service pipeline.

**Job 1 — build-and-push:**
1. Generates an image tag: `master-{first 8 chars of commit SHA}`
2. Authenticates to ECR using repo secrets
3. Builds a `linux/amd64` image via Docker Buildx
4. Pushes both a versioned tag and `latest` to ECR

**Job 2 — update-helm** (runs after job 1 succeeds):
1. Uses `yq` to update `image.tag` in the relevant Helm values file
2. Commits the change back to master as `github-actions[bot]`
3. Pushes with a retry loop (up to 3 attempts) to handle concurrent pipeline runs

### Terraform Pipelines

Two workflows — one for `terraform/eks` and one for `terraform/eks-addons`.

- **On push**: always runs `terraform plan` and uploads the plan as an artifact
- **On manual trigger**: runs `apply` using the saved plan — only if you explicitly set `apply: true`

Infra changes never apply automatically.

### Required Secrets

```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_REGION
```

`GITHUB_TOKEN` is provided automatically by GitHub Actions.

---

## GitOps (ArgoCD)

Once ArgoCD is installed, it watches this repo. The `argo-apps/dev-apex-dev/` directory has one `Application` manifest per service. Each manifest points ArgoCD at the matching Helm chart with the right values file.

When the CI pipeline commits a new image tag to a values file, ArgoCD picks it up and does a rolling deploy automatically. No manual `kubectl` or `helm upgrade` needed.

All apps are configured with `selfHeal: true` and `prune: true` — if someone manually changes something in the cluster, ArgoCD will revert it.

---

## Tech Stack

| Layer | Tools |
|---|---|
| App | Go 1.25, React 18, Axios |
| Containers | Docker (multi-stage, scratch base for Go) |
| Orchestration | AWS EKS 1.33 |
| IaC | Terraform 1.6.6, terraform-aws-modules/eks ~21.0 |
| Helm | helm-chart-api (shared), helm-chart-ui |
| GitOps | ArgoCD 9.4.15 |
| Ingress | AWS Load Balancer Controller 1.13.4 |
| Autoscaling | Cluster Autoscaler 9.43.0 |
| CI/CD | GitHub Actions |
| Registry | AWS ECR |
| State backend | S3 + DynamoDB |
| Region | ap-south-1 (Mumbai) |
