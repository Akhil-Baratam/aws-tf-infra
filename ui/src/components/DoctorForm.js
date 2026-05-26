import React from 'react';

const DoctorForm = ({ formData, onChange }) => {
  return (
    <div className="section">
      <h2>Doctor & Consultation Details</h2>
      <div className="form-row">
        <div className="form-group">
          <label>
            Doctor Name <span className="required">*</span>
          </label>
          <select
            value={formData.doctorName}
            onChange={(e) => onChange('doctorName', e.target.value)}
            required
          >
            <option value="">Select Doctor</option>
            <option value="dr-smith">Dr. Sarah Smith - Cardiology</option>
            <option value="dr-johnson">Dr. Michael Johnson - Internal Medicine</option>
            <option value="dr-williams">Dr. Emily Williams - Family Practice</option>
            <option value="dr-brown">Dr. James Brown - Orthopedics</option>
            <option value="dr-davis">Dr. Lisa Davis - Pediatrics</option>
          </select>
        </div>
        <div className="form-group">
          <label>Consultation Charge</label>
          <input
            type="text"
            value="$800.00"
            disabled
          />
        </div>
      </div>
      <div className="form-row">
        <div className="form-group">
          <label>
            Appointment Date <span className="required">*</span>
          </label>
          <input
            type="date"
            value={formData.appointmentDate}
            onChange={(e) => onChange('appointmentDate', e.target.value)}
            min={new Date().toISOString().split('T')[0]}
            required
          />
        </div>
        <div className="form-group">
          <label>Discount Code</label>
          <input
            type="text"
            value={formData.discountCode}
            onChange={(e) => onChange('discountCode', e.target.value)}
            placeholder="PROMO2024"
          />
        </div>
      </div>
    </div>
  );
};

export default DoctorForm;
