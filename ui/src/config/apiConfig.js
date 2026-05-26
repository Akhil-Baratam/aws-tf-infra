// API Configuration
// Update these URLs for production deployment
export const API_CONFIG = {
    patientService: process.env.REACT_APP_PATIENT_SERVICE_URL || 'http://localhost:8001',
    insuranceService: process.env.REACT_APP_INSURANCE_SERVICE_URL || 'http://localhost:8002',
    pricingService: process.env.REACT_APP_PRICING_SERVICE_URL || 'http://localhost:8003',
    CONSULTATION_FEE: process.env.REACT_APP_CONSULTATION_FEE || 800.00
};


export const STATES = [
    { code: 'CA', name: 'California' },
    { code: 'NY', name: 'New York' },
    { code: 'TX', name: 'Texas' },
    { code: 'FL', name: 'Florida' },
    { code: 'IL', name: 'Illinois' },
    { code: 'PA', name: 'Pennsylvania' },
    { code: 'OH', name: 'Ohio' },
    { code: 'WA', name: 'Washington' }
];

export const INSURANCE_PROVIDERS = [
    { code: 'blue-cross', name: 'Blue Cross Blue Shield' },
    { code: 'aetna', name: 'Aetna' },
    { code: 'cigna', name: 'Cigna' },
    { code: 'united', name: 'UnitedHealthcare' },
    { code: 'humana', name: 'Humana' }
];

export const POLICY_TYPES = ['HMO', 'PPO', 'EPO', 'POS'];

export const DOCTORS = [
    { code: 'dr-smith', name: 'Dr. Sarah Smith - Cardiology' },
    { code: 'dr-johnson', name: 'Dr. Michael Johnson - Internal Medicine' },
    { code: 'dr-williams', name: 'Dr. Emily Williams - Family Practice' },
    { code: 'dr-brown', name: 'Dr. James Brown - Orthopedics' },
    { code: 'dr-davis', name: 'Dr. Lisa Davis - Pediatrics' }
];
