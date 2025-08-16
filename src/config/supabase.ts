import { createClient } from '@supabase/supabase-js';

// Supabase configuration with multiple fallback options
const getEnvVar = (key: string, fallback: string) => {
  // First try import.meta.env (build time)
  if (import.meta.env[key]) return import.meta.env[key];
  
  // Then try window._env (runtime)
  if (typeof window !== 'undefined' && (window as any)._env && (window as any)._env[key]) {
    return (window as any)._env[key];
  }
  
  // Finally use fallback
  return fallback;
};

const supabaseUrl = getEnvVar('VITE_SUPABASE_URL', 'https://hgwomxpzaeeqgxsnhceq.supabase.co');
const supabaseAnonKey = getEnvVar('VITE_SUPABASE_ANON_KEY', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhnd29teHB6YWVlcWd4c25oY2VxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUxMDEwNDEsImV4cCI6MjA3MDY3NzA0MX0.Eeucjix4oV-mGVcIuOXgfFGGVXjsXZj2-oA8ify2O0g');

if (!supabaseUrl || !supabaseAnonKey) {
  console.error('❌ Missing Supabase environment variables');
  throw new Error('Missing Supabase environment variables');
}

console.log('✅ Supabase config loaded:', { 
  url: supabaseUrl, 
  hasKey: !!supabaseAnonKey,
  keyLength: supabaseAnonKey?.length 
});

// Create Supabase client
export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: true,
  },
  realtime: {
    params: {
      eventsPerSecond: 10,
    },
  },
});

// Database Types (matching Supabase schema)
export interface User {
  id: string;
  email: string;
  first_name: string;
  last_name: string;
  role: 'ADMIN' | 'DOCTOR' | 'NURSE' | 'STAFF';
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface Patient {
  id: string;
  patient_id: string;
  first_name: string;
  last_name: string;
  age: number;
  gender: 'M' | 'F' | 'OTHER';
  phone: string;
  email?: string;
  address: string;
  emergency_contact_name: string;
  emergency_contact_phone: string;
  medical_history?: string;
  allergies?: string;
  current_medications?: string;
  blood_group?: string;
  notes?: string;
  is_active: boolean;
  created_at: string;
  updated_at: string;
  created_by: string;
}

export interface Department {
  id: string;
  name: string;
  description?: string;
  head_doctor_id?: string;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface Appointment {
  id: string;
  appointment_id: string;
  patient_id: string;
  doctor_id: string;
  department_id: string;
  scheduled_at: string;
  duration: number;
  status: 'SCHEDULED' | 'CONFIRMED' | 'IN_PROGRESS' | 'COMPLETED' | 'CANCELLED' | 'NO_SHOW';
  reason: string;
  appointment_type: string;
  actual_start_time?: string;
  actual_end_time?: string;
  diagnosis?: string;
  prescription?: string;
  follow_up_date?: string;
  notes?: string;
  created_at: string;
  updated_at: string;
}

export interface Bill {
  id: string;
  bill_number: string;
  patient_id: string;
  appointment_id: string;
  items: any; // JSON
  consultation_fee: number;
  subtotal: number;
  discount: number;
  cgst: number;
  sgst: number;
  igst: number;
  total_tax: number;
  total_amount: number;
  paid_amount?: number;
  status: 'PENDING' | 'PAID' | 'PARTIALLY_PAID' | 'OVERDUE' | 'CANCELLED' | 'REFUNDED';
  payment_method?: 'CASH' | 'CARD' | 'UPI' | 'BANK_TRANSFER' | 'CHEQUE' | 'INSURANCE';
  payment_date?: string;
  payment_reference?: string;
  notes?: string;
  created_at: string;
  updated_at: string;
  created_by: string;
}

// Extended types with relations
export interface PatientWithRelations extends Patient {
  created_by_user?: User;
  appointments?: AppointmentWithRelations[];
  bills?: BillWithRelations[];
}

export interface AppointmentWithRelations extends Appointment {
  patient?: Patient;
  doctor?: User;
  department?: Department;
  bills?: Bill[];
}

export interface BillWithRelations extends Bill {
  patient?: Patient;
  appointment?: AppointmentWithRelations;
  created_by_user?: User;
}

// API Response types
export interface ApiResponse<T> {
  data: T;
  error?: string;
  message?: string;
}

export interface PaginatedResponse<T> {
  data: T[];
  count: number;
  page: number;
  limit: number;
  totalPages: number;
}

// Form types
export interface CreatePatientData {
  first_name: string;
  last_name: string;
  age: number;
  gender: 'M' | 'F' | 'OTHER';
  phone: string;
  email?: string;
  address: string;
  emergency_contact_name: string;
  emergency_contact_phone: string;
  medical_history?: string;
  allergies?: string;
  current_medications?: string;
  blood_group?: string;
  notes?: string;
}

export interface CreateAppointmentData {
  patient_id: string;
  doctor_id: string;
  department_id: string;
  scheduled_at: string;
  duration?: number;
  reason: string;
  appointment_type?: string;
  notes?: string;
}

export interface CreateBillData {
  appointment_id: string;
  patient_id: string;
  items: any[];
  consultation_fee: number;
  discount?: number;
  notes?: string;
}

// Dashboard types
export interface DashboardStats {
  totalPatients: number;
  totalDoctors: number;
  todayAppointments: number;
  pendingBills: number;
  monthlyRevenue: number;
  patientGrowthRate: number;
  appointmentCompletionRate: number;
  averageWaitTime: number;
  revenueGrowthRate: number;
}

export interface ChartData {
  revenueByMonth: { month: string; revenue: number }[];
  patientsByMonth: { month: string; count: number }[];
  appointmentsByStatus: Record<string, number>;
  appointmentsByType: Record<string, number>;
  revenueByPaymentMethod: Record<string, number>;
}

// Auth types
export interface AuthUser {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  role: string;
  isActive: boolean;
}

// Utility type for Supabase queries
export type SupabaseQuery<T> = {
  data: T[] | null;
  error: any;
  count?: number | null;
};

// Export configured client as default
export default supabase;
// DEFAULT HOSPITAL ID (Bhilwara Hospital)
export const HOSPITAL_ID = '550e8400-e29b-41d4-a716-446655440000';

// Additional interfaces for compatibility
export interface AssignedDoctor {
  name: string;
  department: string;
  consultationFee?: number;
  isPrimary?: boolean;
}

export interface CreateTransactionData {
  patient_id: string;
  transaction_type: 'ENTRY_FEE' | 'CONSULTATION' | 'LAB_TEST' | 'XRAY' | 'MEDICINE' | 'PROCEDURE' | 'ADMISSION_FEE' | 'DAILY_CHARGE' | 'SERVICE' | 'REFUND';
  amount: number;
  payment_mode: 'CASH' | 'CARD' | 'UPI' | 'ONLINE' | 'BANK_TRANSFER' | 'INSURANCE';
  description: string;
  doctor_id?: string;
  doctor_name?: string;
  department?: string;
  status?: 'PENDING' | 'COMPLETED' | 'CANCELLED';
  transaction_reference?: string;
  transaction_date?: string;
}
