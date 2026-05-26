package main

import (
	"encoding/json"
	"fmt"
	"log"
	"math/rand"
	"net/http"
	"time"
)

// PatientRequest represents incoming patient data
type PatientRequest struct {
	FirstName string `json:"firstName"`
	LastName  string `json:"lastName"`
	DOB       string `json:"dob"`
	Location  string `json:"location"`
}

// PatientResponse represents the service response
type PatientResponse struct {
	PatientID string `json:"patientId"`
	Verified  bool   `json:"verified"`
	FullName  string `json:"fullName"`
	Age       int    `json:"age"`
}

func enableCORS(w *http.ResponseWriter) {
	(*w).Header().Set("Access-Control-Allow-Origin", "*")
	(*w).Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS")
	(*w).Header().Set("Access-Control-Allow-Headers", "Content-Type")
}

func patientHandler(w http.ResponseWriter, r *http.Request) {
	enableCORS(&w)

	if r.Method == "OPTIONS" {
		w.WriteHeader(http.StatusOK)
		return
	}

	if r.Method != "POST" {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req PatientRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	log.Println("Received patient verification request:", req)
	// Generate random but sensible patient data
	rand.Seed(time.Now().UnixNano())
	patientID := fmt.Sprintf("P%06d", rand.Intn(999999))
	age := calculateAge(req.DOB)

	response := PatientResponse{
		PatientID: patientID,
		Verified:  true,
		FullName:  fmt.Sprintf("%s %s", req.FirstName, req.LastName),
		Age:       age,
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func calculateAge(dob string) int {
	// Simple age calculation from MM/DD/YYYY
	// In production, use proper date parsing
	rand.Seed(time.Now().UnixNano())
	return rand.Intn(60) + 20 // Random age between 20-80
}

func main() {
	http.HandleFunc("/api/patient", patientHandler)

	fmt.Println("Patient Service running on :8001")
	log.Fatal(http.ListenAndServe(":8001", nil))
}
