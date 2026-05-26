import React from 'react';

const InsuranceForm = ({ formData, onChange }) => {
  return (
    <div className="section">
      <h2>Insurance Information</h2>
      <div className="form-row">
        <div className="form-group">
          <label>
            Insurance Provider <span className="required">*</span>
          </label>
          <select
            value={formData.insuranceProvider}
            onChange={(e) => onChange('insuranceProvider', e.target.value)}
            required
          >
            <option value="">Select Provider</option>
            <option value="blue-cross">Blue Cross Blue Shield</option>
            <option value="aetna">Aetna</option>
            <option value="cigna">Cigna</option>
            <option value="united">UnitedHealthcare</option>
            <option value="humana">Humana</option>
          </select>
        </div>
        <div className="form-group">
          <label>
            Insurance ID <span className="required">*</span>
          </label>
          <input
            type="text"
            value={formData.insuranceId}
            onChange={(e) => onChange('insuranceId', e.target.value)}
            placeholder="ABC123456789"
            required
          />
        </div>
      </div>
      <div className="form-row">
        <div className="form-group">
          <label>Group Number</label>
          <input
            type="text"
            value={formData.groupNumber}
            onChange={(e) => onChange('groupNumber', e.target.value)}
            placeholder="GRP98765"
          />
        </div>
        <div className="form-group">
          <label>
            Policy Type <span className="required">*</span>
          </label>
          <select
            value={formData.policyType}
            onChange={(e) => onChange('policyType', e.target.value)}
            required
          >
            <option value="">Select Type</option>
            <option value="HMO">HMO</option>
            <option value="PPO">PPO</option>
            <option value="EPO">EPO</option>
            <option value="POS">POS</option>
          </select>
        </div>
      </div>
    </div>
  );
};

export default InsuranceForm;
