import React, { useState } from 'react';
import './App.css';
import PatientForm from './components/PatientForm';
import InsuranceForm from './components/InsuranceForm';
import DoctorForm from './components/DoctorForm';
import BillingSummary from './components/BillingSummary';
import { processConsultation } from './services/api';

function App() {
  const [formData, setFormData] = useState({
    firstName: '',
    lastName: '',
    dob: '',
    location: '',
    insuranceProvider: '',
    insuranceId: '',
    groupNumber: '',
    policyType: '',
    doctorName: '',
    appointmentDate: '',
    discountCode: ''
  });

  const [billingSummary, setBillingSummary] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleInputChange = (field, value) => {
    setFormData(prev => ({
      ...prev,
      [field]: value
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');
    setBillingSummary(null);

    try {
      const result = await processConsultation(formData);
      setBillingSummary(result);
    } catch (err) {
      setError(err.message || 'Failed to process consultation. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const handleReset = () => {
    setFormData({
      firstName: '',
      lastName: '',
      dob: '',
      location: '',
      insuranceProvider: '',
      insuranceId: '',
      groupNumber: '',
      policyType: '',
      doctorName: '',
      appointmentDate: '',
      discountCode: ''
    });
    setBillingSummary(null);
    setError('');
  };

  return (
    <div className="app">
      <div className="container">
        <header className="header">
          <h1>🏥 Healthcare Portal</h1>
          <p>Patient Consultation & Billing System</p>
        </header>

        <div className="content">
          <div className="info-box">
            <p>
              <strong>Insurance Coverage:</strong> Doctor consultation charges are covered by insurance 
              (90% approved amount, 10% co-pay). Standard consultation fee: $800.00
            </p>
          </div>

          <form onSubmit={handleSubmit}>
            <PatientForm 
              formData={formData} 
              onChange={handleInputChange} 
            />

            <InsuranceForm 
              formData={formData} 
              onChange={handleInputChange} 
            />

            <DoctorForm 
              formData={formData} 
              onChange={handleInputChange} 
            />

            <div className="button-group">
              <button type="submit" className="btn-primary" disabled={loading}>
                {loading ? '⏳ Processing...' : 'Calculate Bill'}
              </button>
              <button type="button" className="btn-secondary" onClick={handleReset}>
                Reset Form
              </button>
            </div>
          </form>

          {error && (
            <div className="error">
              {error}
            </div>
          )}

          {billingSummary && (
            <BillingSummary data={billingSummary} formData={formData} />
          )}
        </div>
      </div>
    </div>
  );
}

export default App;
