-- ================================================
-- COMPLETE HOSPITAL CRM DATABASE SETUP
-- Run this entire script in Supabase SQL Editor
-- ================================================

-- Drop existing tables if needed (uncomment if you want to reset)
-- DROP TABLE IF EXISTS discharge_bills CASCADE;
-- DROP TABLE IF EXISTS discharge_summaries CASCADE;
-- DROP TABLE IF EXISTS patient_visits CASCADE;
-- DROP TABLE IF EXISTS future_appointments CASCADE;
-- DROP TABLE IF EXISTS patient_transactions CASCADE;
-- DROP TABLE IF EXISTS patient_admissions CASCADE;
-- DROP TABLE IF EXISTS patients CASCADE;
-- DROP TABLE IF EXISTS beds CASCADE;
-- DROP TABLE IF EXISTS doctors CASCADE;
-- DROP TABLE IF EXISTS departments CASCADE;
-- DROP TABLE IF EXISTS daily_expenses CASCADE;
-- DROP TABLE IF EXISTS users CASCADE;
-- DROP TABLE IF EXISTS hospitals CASCADE;

-- ================================================
-- SECTION 1: CORE TABLES
-- ================================================

-- 1. Hospitals table (Organization)
CREATE TABLE IF NOT EXISTS hospitals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    address TEXT,
    phone TEXT,
    email TEXT,
    registration_number TEXT,
    gst_number TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert default hospital
INSERT INTO hospitals (id, name, address, phone, email, registration_number, gst_number)
VALUES (
    '550e8400-e29b-41d4-a716-446655440000',
    'VALANT HOSPITAL BHILWARA',
    '123 Medical Street, City',
    '555-0100',
    'info@valanthospital.com',
    'REG123456',
    'GST123456789'
) ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    address = EXCLUDED.address;

-- 2. Users table (Staff, Doctors, Nurses, Admin)
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT UNIQUE NOT NULL,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'STAFF' CHECK (role IN ('ADMIN', 'DOCTOR', 'NURSE', 'STAFF', 'RECEPTIONIST')),
    phone TEXT,
    specialization TEXT,
    consultation_fee NUMERIC(10,2),
    department TEXT,
    hospital_id UUID DEFAULT '550e8400-e29b-41d4-a716-446655440000' REFERENCES hospitals(id),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Departments table
CREATE TABLE IF NOT EXISTS departments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT UNIQUE NOT NULL,
    description TEXT,
    head_doctor_id UUID REFERENCES users(id),
    hospital_id UUID DEFAULT '550e8400-e29b-41d4-a716-446655440000' REFERENCES hospitals(id),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Doctors table (Separate from users for flexibility)
CREATE TABLE IF NOT EXISTS doctors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    department TEXT NOT NULL,
    specialization TEXT NOT NULL,
    degree TEXT,
    experience_years INTEGER,
    fee NUMERIC(10,2) NOT NULL DEFAULT 500.00,
    phone TEXT,
    email TEXT,
    hospital_id UUID DEFAULT '550e8400-e29b-41d4-a716-446655440000' REFERENCES hospitals(id),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. Patients table (Main patient records)
CREATE TABLE IF NOT EXISTS patients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id TEXT UNIQUE NOT NULL,
    prefix TEXT CHECK (prefix IN ('Mr', 'Mrs', 'Ms', 'Dr', 'Prof')),
    first_name TEXT NOT NULL,
    last_name TEXT,
    date_of_birth DATE,
    age TEXT,
    gender TEXT CHECK (gender IN ('M', 'F', 'MALE', 'FEMALE', 'OTHER')),
    phone TEXT,
    email TEXT,
    address TEXT,
    city TEXT,
    state TEXT,
    pincode TEXT,
    emergency_contact_name TEXT,
    emergency_contact_phone TEXT,
    emergency_contact_relation TEXT,
    blood_group TEXT,
    medical_history TEXT,
    allergies TEXT,
    current_medications TEXT,
    insurance_provider TEXT,
    insurance_number TEXT,
    -- Reference fields
    has_reference BOOLEAN DEFAULT FALSE,
    reference_details TEXT,
    -- Doctor assignment
    assigned_doctor TEXT,
    assigned_department TEXT,
    assigned_doctors JSONB,
    consultation_fees JSONB,
    -- Additional medical info
    chief_complaint TEXT,
    diagnosis TEXT,
    treatment_plan TEXT,
    notes TEXT,
    -- Visit tracking
    date_of_entry DATE,
    last_visit_date DATE,
    total_visits INTEGER DEFAULT 0,
    -- IPD status
    ipd_status TEXT CHECK (ipd_status IN ('OPD', 'ADMITTED', 'DISCHARGED')),
    ipd_bed_number TEXT,
    admission_date DATE,
    discharge_date DATE,
    -- System fields
    patient_tag TEXT,
    hospital_id UUID DEFAULT '550e8400-e29b-41d4-a716-446655440000' REFERENCES hospitals(id),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES users(id)
);

-- 6. Beds table (IPD bed management)
CREATE TABLE IF NOT EXISTS beds (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bed_number TEXT UNIQUE NOT NULL,
    room_number TEXT,
    room_type TEXT NOT NULL CHECK (room_type IN ('GENERAL', 'PRIVATE', 'ICU', 'EMERGENCY', 'DELUXE', 'SUITE')),
    floor TEXT,
    building TEXT,
    department TEXT,
    daily_rate NUMERIC(10,2) NOT NULL DEFAULT 1000,
    status TEXT DEFAULT 'AVAILABLE' CHECK (status IN ('AVAILABLE', 'OCCUPIED', 'MAINTENANCE', 'RESERVED')),
    current_patient_id UUID REFERENCES patients(id),
    features TEXT[],
    notes TEXT,
    hospital_id UUID DEFAULT '550e8400-e29b-41d4-a716-446655440000' REFERENCES hospitals(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ================================================
-- SECTION 2: TRANSACTION & BILLING TABLES
-- ================================================

-- 7. Patient Admissions table (IPD admissions)
CREATE TABLE IF NOT EXISTS patient_admissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    admission_number TEXT UNIQUE,
    patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
    bed_id UUID REFERENCES beds(id),
    bed_number TEXT,
    room_type TEXT CHECK (room_type IN ('GENERAL', 'PRIVATE', 'ICU', 'EMERGENCY', 'DELUXE', 'SUITE')),
    department TEXT,
    daily_rate NUMERIC(10,2),
    admission_date DATE NOT NULL,
    expected_discharge_date DATE,
    actual_discharge_date DATE,
    discharge_date DATE,
    admission_reason TEXT,
    admission_notes TEXT,
    discharge_notes TEXT,
    treating_doctor TEXT,
    referring_doctor TEXT,
    status TEXT DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'DISCHARGED', 'TRANSFERRED', 'ABSCONDED')),
    -- Medical info
    diagnosis TEXT,
    treatment_given TEXT,
    condition_on_discharge TEXT,
    follow_up_instructions TEXT,
    -- Billing
    services JSONB DEFAULT '[]',
    total_amount NUMERIC(10,2) DEFAULT 0,
    amount_paid NUMERIC(10,2) DEFAULT 0,
    balance_amount NUMERIC(10,2) DEFAULT 0,
    discount_amount NUMERIC(10,2) DEFAULT 0,
    discount_reason TEXT,
    insurance_claim_amount NUMERIC(10,2) DEFAULT 0,
    -- System fields
    admitted_by UUID REFERENCES users(id),
    discharged_by UUID REFERENCES users(id),
    hospital_id UUID DEFAULT '550e8400-e29b-41d4-a716-446655440000' REFERENCES hospitals(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 8. Patient Transactions table (All financial transactions)
CREATE TABLE IF NOT EXISTS patient_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    transaction_number TEXT UNIQUE,
    patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
    admission_id UUID REFERENCES patient_admissions(id),
    transaction_type TEXT NOT NULL,
    transaction_category TEXT,
    amount NUMERIC(10,2) NOT NULL,
    payment_mode TEXT,
    payment_reference TEXT,
    transaction_date DATE DEFAULT CURRENT_DATE,
    service_date DATE,
    doctor_id TEXT,
    doctor_name TEXT,
    department TEXT,
    description TEXT,
    quantity INTEGER DEFAULT 1,
    unit_price NUMERIC(10,2),
    discount_amount NUMERIC(10,2) DEFAULT 0,
    tax_amount NUMERIC(10,2) DEFAULT 0,
    net_amount NUMERIC(10,2),
    status TEXT DEFAULT 'COMPLETED' CHECK (status IN ('PENDING', 'COMPLETED', 'CANCELLED', 'REFUNDED')),
    notes TEXT,
    receipt_number TEXT,
    invoice_number TEXT,
    created_by UUID REFERENCES users(id),
    cancelled_by UUID REFERENCES users(id),
    cancelled_at TIMESTAMP WITH TIME ZONE,
    cancellation_reason TEXT,
    hospital_id UUID DEFAULT '550e8400-e29b-41d4-a716-446655440000' REFERENCES hospitals(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 9. Daily Expenses table (Hospital expenses)
CREATE TABLE IF NOT EXISTS daily_expenses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    expense_number TEXT UNIQUE,
    expense_category TEXT NOT NULL,
    expense_subcategory TEXT,
    vendor_name TEXT,
    vendor_contact TEXT,
    description TEXT NOT NULL,
    amount NUMERIC(10,2) NOT NULL,
    payment_mode TEXT,
    payment_reference TEXT,
    invoice_number TEXT,
    receipt_number TEXT,
    expense_date DATE NOT NULL,
    approval_status TEXT DEFAULT 'PENDING' CHECK (approval_status IN ('PENDING', 'APPROVED', 'REJECTED')),
    approved_by UUID REFERENCES users(id),
    approved_at TIMESTAMP WITH TIME ZONE,
    notes TEXT,
    attachments JSONB,
    hospital_id UUID DEFAULT '550e8400-e29b-41d4-a716-446655440000' REFERENCES hospitals(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES users(id)
);

-- ================================================
-- SECTION 3: APPOINTMENT & VISIT TABLES
-- ================================================

-- 10. Future Appointments table
CREATE TABLE IF NOT EXISTS future_appointments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    appointment_number TEXT UNIQUE,
    patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
    doctor_id UUID REFERENCES users(id),
    doctor_name TEXT,
    department TEXT,
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    appointment_end_time TIME,
    duration_minutes INTEGER DEFAULT 30,
    appointment_type TEXT DEFAULT 'CONSULTATION',
    reason TEXT,
    symptoms TEXT,
    status TEXT DEFAULT 'SCHEDULED' CHECK (status IN ('SCHEDULED', 'CONFIRMED', 'ARRIVED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED', 'NO_SHOW')),
    estimated_cost NUMERIC(10,2),
    notes TEXT,
    reminder_sent BOOLEAN DEFAULT FALSE,
    reminder_sent_at TIMESTAMP WITH TIME ZONE,
    cancelled_by UUID REFERENCES users(id),
    cancelled_at TIMESTAMP WITH TIME ZONE,
    cancellation_reason TEXT,
    rescheduled_from UUID REFERENCES future_appointments(id),
    hospital_id UUID DEFAULT '550e8400-e29b-41d4-a716-446655440000' REFERENCES hospitals(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES users(id)
);

-- 11. Patient Visits table (Visit history)
CREATE TABLE IF NOT EXISTS patient_visits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    visit_number TEXT UNIQUE,
    patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
    appointment_id UUID REFERENCES future_appointments(id),
    visit_date DATE NOT NULL DEFAULT CURRENT_DATE,
    visit_time TIME DEFAULT CURRENT_TIME,
    visit_type TEXT,
    chief_complaint TEXT,
    symptoms TEXT,
    vital_signs JSONB,
    diagnosis TEXT,
    treatment_plan TEXT,
    prescriptions JSONB,
    lab_tests_ordered TEXT[],
    lab_results JSONB,
    procedures_performed TEXT[],
    doctor_id UUID REFERENCES users(id),
    doctor_name TEXT,
    department TEXT,
    follow_up_date DATE,
    follow_up_instructions TEXT,
    notes TEXT,
    attachments JSONB,
    hospital_id UUID DEFAULT '550e8400-e29b-41d4-a716-446655440000' REFERENCES hospitals(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES users(id)
);

-- ================================================
-- SECTION 4: DISCHARGE & BILLING TABLES
-- ================================================

-- 12. Discharge Summaries table
CREATE TABLE IF NOT EXISTS discharge_summaries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    discharge_number TEXT UNIQUE,
    patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
    admission_id UUID REFERENCES patient_admissions(id),
    discharge_date DATE NOT NULL,
    discharge_time TIME,
    discharge_type TEXT,
    condition_on_discharge TEXT,
    diagnosis_on_discharge TEXT,
    procedures_performed TEXT,
    treatment_given TEXT,
    medications_on_discharge JSONB,
    follow_up_instructions TEXT,
    follow_up_date DATE,
    diet_instructions TEXT,
    activity_restrictions TEXT,
    warning_signs TEXT,
    emergency_contact TEXT,
    doctor_name TEXT,
    doctor_signature TEXT,
    notes TEXT,
    hospital_id UUID DEFAULT '550e8400-e29b-41d4-a716-446655440000' REFERENCES hospitals(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES users(id)
);

-- 13. Discharge Bills table
CREATE TABLE IF NOT EXISTS discharge_bills (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bill_number TEXT UNIQUE,
    patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
    admission_id UUID REFERENCES patient_admissions(id),
    discharge_summary_id UUID REFERENCES discharge_summaries(id),
    bill_date DATE NOT NULL DEFAULT CURRENT_DATE,
    -- Charges breakdown
    room_charges NUMERIC(10,2) DEFAULT 0,
    doctor_fees NUMERIC(10,2) DEFAULT 0,
    nursing_charges NUMERIC(10,2) DEFAULT 0,
    medicine_charges NUMERIC(10,2) DEFAULT 0,
    lab_charges NUMERIC(10,2) DEFAULT 0,
    procedure_charges NUMERIC(10,2) DEFAULT 0,
    other_charges NUMERIC(10,2) DEFAULT 0,
    -- Totals
    subtotal NUMERIC(10,2) DEFAULT 0,
    discount_amount NUMERIC(10,2) DEFAULT 0,
    discount_percentage NUMERIC(5,2) DEFAULT 0,
    tax_amount NUMERIC(10,2) DEFAULT 0,
    total_amount NUMERIC(10,2) DEFAULT 0,
    amount_paid NUMERIC(10,2) DEFAULT 0,
    balance_amount NUMERIC(10,2) DEFAULT 0,
    -- Payment info
    payment_mode TEXT,
    payment_reference TEXT,
    payment_date DATE,
    payment_status TEXT DEFAULT 'PENDING' CHECK (payment_status IN ('PENDING', 'PARTIAL', 'PAID', 'CANCELLED')),
    -- Insurance
    insurance_claim_amount NUMERIC(10,2) DEFAULT 0,
    insurance_approved_amount NUMERIC(10,2) DEFAULT 0,
    insurance_claim_number TEXT,
    -- Additional info
    bill_details JSONB,
    notes TEXT,
    hospital_id UUID DEFAULT '550e8400-e29b-41d4-a716-446655440000' REFERENCES hospitals(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES users(id)
);

-- ================================================
-- SECTION 5: INSERT SAMPLE DATA
-- ================================================

-- Insert Departments
INSERT INTO departments (name, description) VALUES
    ('GENERAL', 'General Medicine'),
    ('CARDIOLOGY', 'Heart and Cardiovascular'),
    ('ORTHOPEDICS', 'Bones and Joints'),
    ('PEDIATRICS', 'Child Care'),
    ('GYNECOLOGY', 'Women Health'),
    ('NEUROLOGY', 'Brain and Nervous System'),
    ('DERMATOLOGY', 'Skin Care'),
    ('ENT', 'Ear, Nose, and Throat'),
    ('OPHTHALMOLOGY', 'Eye Care'),
    ('PSYCHIATRY', 'Mental Health'),
    ('EMERGENCY', 'Emergency Services'),
    ('ICU', 'Intensive Care Unit'),
    ('SURGERY', 'General Surgery'),
    ('RADIOLOGY', 'Imaging Services'),
    ('PATHOLOGY', 'Laboratory Services')
ON CONFLICT (name) DO NOTHING;

-- Insert Doctors
INSERT INTO doctors (name, department, specialization, degree, experience_years, fee, phone) VALUES
    ('Dr. Smith', 'GENERAL', 'General Physician', 'MBBS, MD', 10, 500, '9876543210'),
    ('Dr. Johnson', 'CARDIOLOGY', 'Cardiologist', 'MBBS, MD, DM', 15, 1000, '9876543211'),
    ('Dr. Williams', 'ORTHOPEDICS', 'Orthopedic Surgeon', 'MBBS, MS', 12, 1500, '9876543212'),
    ('Dr. Brown', 'PEDIATRICS', 'Pediatrician', 'MBBS, MD', 8, 600, '9876543213'),
    ('Dr. Davis', 'ICU', 'Critical Care', 'MBBS, MD', 20, 2000, '9876543214'),
    ('Dr. Miller', 'SURGERY', 'General Surgeon', 'MBBS, MS', 18, 1800, '9876543215'),
    ('Dr. Wilson', 'GYNECOLOGY', 'Gynecologist', 'MBBS, MD', 14, 800, '9876543216'),
    ('Dr. Moore', 'NEUROLOGY', 'Neurologist', 'MBBS, MD, DM', 16, 1200, '9876543217'),
    ('Dr. Taylor', 'ENT', 'ENT Specialist', 'MBBS, MS', 11, 700, '9876543218'),
    ('Dr. Anderson', 'OPHTHALMOLOGY', 'Eye Specialist', 'MBBS, MS', 13, 900, '9876543219')
ON CONFLICT DO NOTHING;

-- Insert Beds
INSERT INTO beds (bed_number, room_number, room_type, floor, department, daily_rate) VALUES
    -- General Ward Beds
    ('GEN-001', '101', 'GENERAL', '1', 'GENERAL', 1000),
    ('GEN-002', '101', 'GENERAL', '1', 'GENERAL', 1000),
    ('GEN-003', '101', 'GENERAL', '1', 'GENERAL', 1000),
    ('GEN-004', '102', 'GENERAL', '1', 'GENERAL', 1000),
    ('GEN-005', '102', 'GENERAL', '1', 'GENERAL', 1000),
    -- Private Rooms
    ('PVT-001', '201', 'PRIVATE', '2', 'GENERAL', 2500),
    ('PVT-002', '202', 'PRIVATE', '2', 'GENERAL', 2500),
    ('PVT-003', '203', 'PRIVATE', '2', 'GENERAL', 2500),
    ('PVT-004', '204', 'PRIVATE', '2', 'CARDIOLOGY', 3000),
    ('PVT-005', '205', 'PRIVATE', '2', 'CARDIOLOGY', 3000),
    -- ICU Beds
    ('ICU-001', '301', 'ICU', '3', 'ICU', 5000),
    ('ICU-002', '301', 'ICU', '3', 'ICU', 5000),
    ('ICU-003', '301', 'ICU', '3', 'ICU', 5000),
    ('ICU-004', '302', 'ICU', '3', 'ICU', 5000),
    ('ICU-005', '302', 'ICU', '3', 'ICU', 5000),
    -- Emergency Beds
    ('EMG-001', 'ER-1', 'EMERGENCY', 'G', 'EMERGENCY', 3000),
    ('EMG-002', 'ER-1', 'EMERGENCY', 'G', 'EMERGENCY', 3000),
    ('EMG-003', 'ER-2', 'EMERGENCY', 'G', 'EMERGENCY', 3000),
    -- Deluxe Rooms
    ('DLX-001', '401', 'DELUXE', '4', 'GENERAL', 4000),
    ('DLX-002', '402', 'DELUXE', '4', 'GENERAL', 4000)
ON CONFLICT (bed_number) DO NOTHING;

-- ================================================
-- SECTION 6: CREATE INDEXES FOR PERFORMANCE
-- ================================================

-- Patient indexes
CREATE INDEX IF NOT EXISTS idx_patients_patient_id ON patients(patient_id);
CREATE INDEX IF NOT EXISTS idx_patients_phone ON patients(phone);
CREATE INDEX IF NOT EXISTS idx_patients_date_of_entry ON patients(date_of_entry);
CREATE INDEX IF NOT EXISTS idx_patients_created_at ON patients(created_at);
CREATE INDEX IF NOT EXISTS idx_patients_hospital_id ON patients(hospital_id);

-- Transaction indexes
CREATE INDEX IF NOT EXISTS idx_transactions_patient_id ON patient_transactions(patient_id);
CREATE INDEX IF NOT EXISTS idx_transactions_created_at ON patient_transactions(created_at);
CREATE INDEX IF NOT EXISTS idx_transactions_status ON patient_transactions(status);
CREATE INDEX IF NOT EXISTS idx_transactions_hospital_id ON patient_transactions(hospital_id);

-- Admission indexes
CREATE INDEX IF NOT EXISTS idx_admissions_patient_id ON patient_admissions(patient_id);
CREATE INDEX IF NOT EXISTS idx_admissions_status ON patient_admissions(status);
CREATE INDEX IF NOT EXISTS idx_admissions_admission_date ON patient_admissions(admission_date);

-- Appointment indexes
CREATE INDEX IF NOT EXISTS idx_appointments_patient_id ON future_appointments(patient_id);
CREATE INDEX IF NOT EXISTS idx_appointments_date ON future_appointments(appointment_date);
CREATE INDEX IF NOT EXISTS idx_appointments_status ON future_appointments(status);

-- Bed indexes
CREATE INDEX IF NOT EXISTS idx_beds_status ON beds(status);
CREATE INDEX IF NOT EXISTS idx_beds_room_type ON beds(room_type);

-- ================================================
-- SECTION 7: ROW LEVEL SECURITY (RLS)
-- ================================================

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE patients ENABLE ROW LEVEL SECURITY;
ALTER TABLE patient_admissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE patient_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE beds ENABLE ROW LEVEL SECURITY;
ALTER TABLE doctors ENABLE ROW LEVEL SECURITY;
ALTER TABLE departments ENABLE ROW LEVEL SECURITY;
ALTER TABLE hospitals ENABLE ROW LEVEL SECURITY;
ALTER TABLE future_appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE patient_visits ENABLE ROW LEVEL SECURITY;
ALTER TABLE discharge_summaries ENABLE ROW LEVEL SECURITY;
ALTER TABLE discharge_bills ENABLE ROW LEVEL SECURITY;

-- Create permissive policies for authenticated users
-- (Allowing all operations for authenticated users - adjust as needed for production)

-- Drop existing policies if any
DO $$ 
BEGIN
    DROP POLICY IF EXISTS "Enable all for authenticated users" ON users;
    DROP POLICY IF EXISTS "Enable all for authenticated users" ON patients;
    DROP POLICY IF EXISTS "Enable all for authenticated users" ON patient_admissions;
    DROP POLICY IF EXISTS "Enable all for authenticated users" ON patient_transactions;
    DROP POLICY IF EXISTS "Enable all for authenticated users" ON daily_expenses;
    DROP POLICY IF EXISTS "Enable all for authenticated users" ON beds;
    DROP POLICY IF EXISTS "Enable all for authenticated users" ON doctors;
    DROP POLICY IF EXISTS "Enable all for authenticated users" ON departments;
    DROP POLICY IF EXISTS "Enable all for authenticated users" ON hospitals;
    DROP POLICY IF EXISTS "Enable all for authenticated users" ON future_appointments;
    DROP POLICY IF EXISTS "Enable all for authenticated users" ON patient_visits;
    DROP POLICY IF EXISTS "Enable all for authenticated users" ON discharge_summaries;
    DROP POLICY IF EXISTS "Enable all for authenticated users" ON discharge_bills;
EXCEPTION
    WHEN OTHERS THEN NULL;
END $$;

-- Create new policies
CREATE POLICY "Enable all for authenticated users" ON users FOR ALL USING (true);
CREATE POLICY "Enable all for authenticated users" ON patients FOR ALL USING (true);
CREATE POLICY "Enable all for authenticated users" ON patient_admissions FOR ALL USING (true);
CREATE POLICY "Enable all for authenticated users" ON patient_transactions FOR ALL USING (true);
CREATE POLICY "Enable all for authenticated users" ON daily_expenses FOR ALL USING (true);
CREATE POLICY "Enable all for authenticated users" ON beds FOR ALL USING (true);
CREATE POLICY "Enable all for authenticated users" ON doctors FOR ALL USING (true);
CREATE POLICY "Enable all for authenticated users" ON departments FOR ALL USING (true);
CREATE POLICY "Enable all for authenticated users" ON hospitals FOR ALL USING (true);
CREATE POLICY "Enable all for authenticated users" ON future_appointments FOR ALL USING (true);
CREATE POLICY "Enable all for authenticated users" ON patient_visits FOR ALL USING (true);
CREATE POLICY "Enable all for authenticated users" ON discharge_summaries FOR ALL USING (true);
CREATE POLICY "Enable all for authenticated users" ON discharge_bills FOR ALL USING (true);

-- ================================================
-- SECTION 8: FUNCTIONS AND TRIGGERS
-- ================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for updated_at
DROP TRIGGER IF EXISTS update_users_updated_at ON users;
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_patients_updated_at ON patients;
CREATE TRIGGER update_patients_updated_at BEFORE UPDATE ON patients
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_patient_admissions_updated_at ON patient_admissions;
CREATE TRIGGER update_patient_admissions_updated_at BEFORE UPDATE ON patient_admissions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_beds_updated_at ON beds;
CREATE TRIGGER update_beds_updated_at BEFORE UPDATE ON beds
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to generate patient ID
CREATE OR REPLACE FUNCTION generate_patient_id()
RETURNS TRIGGER AS $$
DECLARE
    next_id INTEGER;
BEGIN
    -- Get the next ID number
    SELECT COALESCE(MAX(CAST(SUBSTRING(patient_id FROM 2) AS INTEGER)), 0) + 1
    INTO next_id
    FROM patients;
    
    -- Generate the patient ID
    NEW.patient_id := 'P' || LPAD(next_id::TEXT, 6, '0');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for auto-generating patient ID
DROP TRIGGER IF EXISTS generate_patient_id_trigger ON patients;
CREATE TRIGGER generate_patient_id_trigger
    BEFORE INSERT ON patients
    FOR EACH ROW
    WHEN (NEW.patient_id IS NULL)
    EXECUTE FUNCTION generate_patient_id();

-- Function to update bed status when admission is created
CREATE OR REPLACE FUNCTION update_bed_on_admission()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.bed_id IS NOT NULL THEN
        UPDATE beds SET 
            status = 'OCCUPIED',
            current_patient_id = NEW.patient_id
        WHERE id = NEW.bed_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for bed status update
DROP TRIGGER IF EXISTS update_bed_on_admission_trigger ON patient_admissions;
CREATE TRIGGER update_bed_on_admission_trigger
    AFTER INSERT ON patient_admissions
    FOR EACH ROW
    EXECUTE FUNCTION update_bed_on_admission();

-- Function to release bed on discharge
CREATE OR REPLACE FUNCTION release_bed_on_discharge()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status = 'ACTIVE' AND NEW.status = 'DISCHARGED' AND NEW.bed_id IS NOT NULL THEN
        UPDATE beds SET 
            status = 'AVAILABLE',
            current_patient_id = NULL
        WHERE id = NEW.bed_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for bed release
DROP TRIGGER IF EXISTS release_bed_on_discharge_trigger ON patient_admissions;
CREATE TRIGGER release_bed_on_discharge_trigger
    AFTER UPDATE ON patient_admissions
    FOR EACH ROW
    EXECUTE FUNCTION release_bed_on_discharge();

-- ================================================
-- SECTION 9: CREATE ADMIN USER PROFILE
-- ================================================

-- After creating user in Authentication, run this to create profile:
DO $$
DECLARE
    admin_id UUID;
BEGIN
    -- Get the admin user ID from auth.users
    SELECT id INTO admin_id FROM auth.users WHERE email = 'admin@hospital.com' LIMIT 1;
    
    IF admin_id IS NOT NULL THEN
        INSERT INTO users (id, email, first_name, last_name, role, is_active, hospital_id)
        VALUES (
            admin_id,
            'admin@hospital.com',
            'Admin',
            'User',
            'ADMIN',
            TRUE,
            '550e8400-e29b-41d4-a716-446655440000'
        )
        ON CONFLICT (id) DO UPDATE SET
            first_name = 'Admin',
            last_name = 'User',
            role = 'ADMIN',
            is_active = TRUE;
        
        RAISE NOTICE 'Admin profile created/updated successfully!';
    ELSE
        RAISE NOTICE 'Admin user not found. Please create admin@hospital.com in Authentication first!';
    END IF;
END $$;

-- ================================================
-- SECTION 10: VERIFY SETUP
-- ================================================

-- Check tables
SELECT 'TABLES CREATED:' as status;
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

-- Check data counts
SELECT 'DATA SUMMARY:' as status;
SELECT 'Hospitals' as type, COUNT(*) as count FROM hospitals
UNION ALL SELECT 'Departments', COUNT(*) FROM departments
UNION ALL SELECT 'Doctors', COUNT(*) FROM doctors
UNION ALL SELECT 'Beds', COUNT(*) FROM beds
UNION ALL SELECT 'Users', COUNT(*) FROM users
UNION ALL SELECT 'Patients', COUNT(*) FROM patients;

-- Check admin user
SELECT 'ADMIN USER STATUS:' as status;
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM users WHERE email = 'admin@hospital.com' AND role = 'ADMIN') 
        THEN 'Admin user profile exists and ready!' 
        ELSE 'Admin profile not found - Run script after creating auth user' 
    END as admin_status;

-- Show available beds
SELECT 'AVAILABLE BEDS:' as status;
SELECT room_type, COUNT(*) as available_count 
FROM beds 
WHERE status = 'AVAILABLE' 
GROUP BY room_type;

-- ================================================
-- SUCCESS MESSAGE
-- ================================================
SELECT '✅ DATABASE SETUP COMPLETE!' as message,
       'All tables, indexes, and policies have been created.' as details,
       'Make sure to create admin@hospital.com user in Authentication.' as reminder;