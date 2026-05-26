package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"strings"
)

// PricingRequest represents incoming pricing data
type PricingRequest struct {
	Location           string  `json:"location"`
	DiscountCode       string  `json:"discountCode"`
	ConsultationCharge float64 `json:"consultationCharge"`
}

// PricingResponse represents the service response
type PricingResponse struct {
	BasePrice          float64 `json:"basePrice"`
	LocationMultiplier float64 `json:"locationMultiplier"`
	LocationAdjustment float64 `json:"locationAdjustment"`
	DiscountRate       float64 `json:"discountRate"`
	DiscountAmount     float64 `json:"discountAmount"`
	FinalPrice         float64 `json:"finalPrice"`
}

var locationMultipliers = map[string]float64{
	"CA": 1.25,
	"NY": 1.30,
	"TX": 1.05,
	"FL": 1.10,
	"IL": 1.15,
	"PA": 1.08,
	"OH": 1.00,
	"WA": 1.20,
}

var discountCodes = map[string]float64{
	"PROMO2024": 0.10,
	"FIRST50":   0.15,
	"SENIOR":    0.20,
	"VETERAN":   0.25,
	"STUDENT":   0.12,
}

func enableCORS(w *http.ResponseWriter) {
	(*w).Header().Set("Access-Control-Allow-Origin", "*")
	(*w).Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS")
	(*w).Header().Set("Access-Control-Allow-Headers", "Content-Type")
}

func pricingHandler(w http.ResponseWriter, r *http.Request) {
	enableCORS(&w)

	if r.Method == "OPTIONS" {
		w.WriteHeader(http.StatusOK)
		return
	}

	if r.Method != "POST" {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req PricingRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	log.Println("Received pricing request:", req)

	// Calculate location-based pricing
	basePrice := req.ConsultationCharge
	locationMult := locationMultipliers[req.Location]
	if locationMult == 0 {
		locationMult = 1.0
	}

	locationAdjusted := basePrice * locationMult
	locationAdjustment := basePrice * (locationMult - 1)

	// Apply discount if valid
	discountRate := 0.0
	if req.DiscountCode != "" {
		discountRate = discountCodes[strings.ToUpper(req.DiscountCode)]
	}

	discountAmount := locationAdjusted * discountRate
	finalPrice := locationAdjusted - discountAmount

	response := PricingResponse{
		BasePrice:          basePrice,
		LocationMultiplier: locationMult,
		LocationAdjustment: locationAdjustment,
		DiscountRate:       discountRate,
		DiscountAmount:     discountAmount,
		FinalPrice:         finalPrice,
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func main() {
	http.HandleFunc("/api/pricing", pricingHandler)

	fmt.Println("Pricing Service running on :8003")
	log.Fatal(http.ListenAndServe(":8003", nil))
}
