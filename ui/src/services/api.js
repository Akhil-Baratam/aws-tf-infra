import axios from 'axios';
import { API_CONFIG } from '../config/apiConfig';

const CONSULTATION_FEE = 800.00;

// Axios instances for each service
const patientAPI = axios.create({
  baseURL: API_CONFIG.patientService,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json'
  }
});

const insuranceAPI = axios.create({
  baseURL: API_CONFIG.insuranceService,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json'
  }
});

const pricingAPI = axios.create({
  baseURL: API_CONFIG.pricingService,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json'
  }
});

// Call Patient Service
export const callPatientService = async (data) => {
  try {
    const response = await patientAPI.post('/api/patient', {
      firstName: data.firstName,
      lastName: data.lastName,
      dob: data.dob,
      location: data.location
    });
    return response.data;
  } catch (error) {
    console.error('Patient Service Error:', error);
    throw new Error('Failed to verify patient information');
  }
};

// Call Insurance Service
export const callInsuranceService = async (data) => {
  try {
    const response = await insuranceAPI.post('/api/insurance', {
      insuranceProvider: data.insuranceProvider,
      insuranceId: data.insuranceId,
      groupNumber: data.groupNumber,
      policyType: data.policyType
    });
    return response.data;
  } catch (error) {
    console.error('Insurance Service Error:', error);
    throw new Error('Failed to verify insurance information');
  }
};

// Call Pricing Service
export const callPricingService = async (data) => {
  try {
    const response = await pricingAPI.post('/api/pricing', {
      location: data.location,
      discountCode: data.discountCode,
      consultationCharge: CONSULTATION_FEE
    });
    return response.data;
  } catch (error) {
    console.error('Pricing Service Error:', error);
    throw new Error('Failed to calculate pricing');
  }
};

// Main function to process consultation
export const processConsultation = async (formData) => {
  try {
    // Call all three services in parallel
    const [patientResponse, insuranceResponse, pricingResponse] = await Promise.all([
      callPatientService(formData),
      callInsuranceService(formData),
      callPricingService(formData)
    ]);

    // Calculate final billing
    const adjustedTotal = pricingResponse.finalPrice;
    const insuranceAmount = adjustedTotal * (insuranceResponse.coveragePercentage / 100);
    const copayAmount = adjustedTotal * (insuranceResponse.copayPercentage / 100);

    return {
      patient: patientResponse,
      insurance: insuranceResponse,
      pricing: pricingResponse,
      insuranceAmount,
      copayAmount
    };
  } catch (error) {
    throw error;
  }
};
