package main

import (
	"encoding/json"
	"fmt"
	"log"
	"math/rand"
	"net/http"
	"time"
)

// InsuranceRequest represents incoming insurance data
type InsuranceRequest struct {
	InsuranceProvider string `json:"insuranceProvider"`
	InsuranceID       string `json:"insuranceId"`
	GroupNumber       string `json:"groupNumber"`
	PolicyType        string `json:"policyType"`
}

// InsuranceResponse represents the service response
type InsuranceResponse struct {
	Verified           bool   `json:"verified"`
	CoveragePercentage int    `json:"coveragePercentage"`
	CopayPercentage    int    `json:"copayPercentage"`
	PolicyActive       bool   `json:"policyActive"`
	InsuranceName      string `json:"insuranceName"`
	ApprovalCode       string `json:"approvalCode"`
}

func enableCORS(w *http.ResponseWriter) {
	(*w).Header().Set("Access-Control-Allow-Origin", "*")
	(*w).Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS")
	(*w).Header().Set("Access-Control-Allow-Headers", "Content-Type")
}

func insuranceHandler(w http.ResponseWriter, r *http.Request) {
	enableCORS(&w)

	if r.Method == "OPTIONS" {
		w.WriteHeader(http.StatusOK)
		return
	}

	if r.Method != "POST" {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req InsuranceRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	log.Println("Received insurance verification request:", req)

	// Generate random but sensible insurance verification data
	rand.Seed(time.Now().UnixNano())
	approvalCode := fmt.Sprintf("AUTH%08d", rand.Intn(99999999))

	providerNames := map[string]string{
		"blue-cross": "Blue Cross Blue Shield",
		"aetna":      "Aetna",
		"cigna":      "Cigna",
		"united":     "UnitedHealthcare",
		"humana":     "Humana",
	}

	response := InsuranceResponse{
		Verified:           true,
		CoveragePercentage: 90,
		CopayPercentage:    10,
		PolicyActive:       true,
		InsuranceName:      providerNames[req.InsuranceProvider],
		ApprovalCode:       approvalCode,
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func main() {
	http.HandleFunc("/api/insurance", insuranceHandler)

	fmt.Println("Insurance Service running on :8002")
	log.Fatal(http.ListenAndServe(":8002", nil))
}
