import React from 'react';

const PatientForm = ({ formData, onChange }) => {
  return (
    <div className="section">
      <h2>Patient Information</h2>
      <div className="form-row">
        <div className="form-group">
          <label>
            First Name <span className="required">*</span>
          </label>
          <input
            type="text"
            value={formData.firstName}
            onChange={(e) => onChange('firstName', e.target.value)}
            placeholder="John"
            required
          />
        </div>
        <div className="form-group">
          <label>
            Last Name <span className="required">*</span>
          </label>
          <input
            type="text"
            value={formData.lastName}
            onChange={(e) => onChange('lastName', e.target.value)}
            placeholder="Doe"
            required
          />
        </div>
      </div>
      <div className="form-row">
        <div className="form-group">
          <label>
            Date of Birth <span className="required">*</span>
          </label>
          <input
            type="text"
            value={formData.dob}
            onChange={(e) => onChange('dob', e.target.value)}
            placeholder="MM/DD/YYYY"
            pattern="\d{2}/\d{2}/\d{4}"
            required
          />
        </div>
        <div className="form-group">
          <label>
            Location (State) <span className="required">*</span>
          </label>
          <select
            value={formData.location}
            onChange={(e) => onChange('location', e.target.value)}
            required
          >
            <option value="">Select State</option>
            <option value="CA">California</option>
            <option value="NY">New York</option>
            <option value="TX">Texas</option>
            <option value="FL">Florida</option>
            <option value="IL">Illinois</option>
            <option value="PA">Pennsylvania</option>
            <option value="OH">Ohio</option>
            <option value="WA">Washington</option>
          </select>
        </div>
      </div>
    </div>
  );
};

export default PatientForm;
