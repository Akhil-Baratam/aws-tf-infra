import React from 'react';
import './BillingSummary.css';

const BillingSummary = ({ data, formData }) => {
  const getStateName = (code) => {
    const states = {
      'CA': 'California',
      'NY': 'New York',
      'TX': 'Texas',
      'FL': 'Florida',
      'IL': 'Illinois',
      'PA': 'Pennsylvania',
      'OH': 'Ohio',
      'WA': 'Washington'
    };
    return states[code] || code;
  };

  const getDoctorName = (code) => {
    const doctors = {
      'dr-smith': 'Dr. Sarah Smith - Cardiology',
      'dr-johnson': 'Dr. Michael Johnson - Internal Medicine',
      'dr-williams': 'Dr. Emily Williams - Family Practice',
      'dr-brown': 'Dr. James Brown - Orthopedics',
      'dr-davis': 'Dr. Lisa Davis - Pediatrics'
    };
    return doctors[code] || code;
  };

  return (
    <div className="results">
      <h2>💰 Billing Summary</h2>
      <div className="result-grid">
        <div className="result-item">
          <span className="result-label">Patient Name:</span>
          <span className="result-value">{data.patient.fullName}</span>
        </div>
        <div className="result-item">
          <span className="result-label">Doctor:</span>
          <span className="result-value">{getDoctorName(formData.doctorName)}</span>
        </div>
        <div className="result-item">
          <span className="result-label">Location:</span>
          <span className="result-value">{getStateName(formData.location)}</span>
        </div>
        <div className="result-item">
          <span className="result-label">Insurance Provider:</span>
          <span className="result-value">{data.insurance.insuranceName}</span>
        </div>
        <div className="result-item">
          <span className="result-label">Base Consultation Charge:</span>
          <span className="result-value">$800.00</span>
        </div>
        <div className="result-item">
          <span className="result-label">Location Adjustment:</span>
          <span className="result-value">
            {data.pricing.locationAdjustment >= 0 
              ? `+$${data.pricing.locationAdjustment.toFixed(2)}`
              : `-$${Math.abs(data.pricing.locationAdjustment).toFixed(2)}`}
          </span>
        </div>
        <div className="result-item">
          <span className="result-label">Discount Applied:</span>
          <span className="result-value">
            {data.pricing.discountAmount > 0
              ? `-$${data.pricing.discountAmount.toFixed(2)} (${(data.pricing.discountRate * 100).toFixed(0)}%)`
              : 'None'}
          </span>
        </div>
        <div className="result-item">
          <span className="result-label">Total After Adjustments:</span>
          <span className="result-value">${data.pricing.finalPrice.toFixed(2)}</span>
        </div>
      </div>

      <div className="total-section">
        <div className="total-row">
          <span>Insurance Approved Amount (90%):</span>
          <span>${data.insuranceAmount.toFixed(2)}</span>
        </div>
        <div className="total-row">
          <span>Patient Co-Pay (10%):</span>
          <span>${data.copayAmount.toFixed(2)}</span>
        </div>
        <div className="total-row total-final">
          <span>Total Bill:</span>
          <span>${data.pricing.finalPrice.toFixed(2)}</span>
        </div>
      </div>
    </div>
  );
};

export default BillingSummary;
