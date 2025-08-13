-- HOSPITAL CRM INITIAL DATABASE SETUP
-- Run this entire script in your Supabase SQL Editor to set up the database

-- ============================================
-- PART 1: CREATE ALL NECESSARY TABLES
-- ============================================

-- 1. Create users table (extends auth.users)
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT UNIQUE NOT NULL,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'STAFF' CHECK (role IN ('ADMIN', 'DOCTOR', 'NURSE', 'STAFF')),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Create hospitals table
CREATE TABLE IF NOT EXISTS hospitals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    address TEXT,
    phone TEXT,
    email TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Insert default hospital
INSERT INTO hospitals (id, name, address, phone, email)
VALUES (
    '550e8400-e29b-41d4-a716-446655440000',
    'City General Hospital',
    '123 Main St, City',
    '555-0100',
    'info@hospital.com'
) ON CONFLICT (id) DO NOTHING;

-- 4. Create departments table
CREATE TABLE IF NOT EXISTS departments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT UNIQUE NOT NULL,
    description TEXT,
    hospital_id UUID DEFAULT '550e8400-e29b-41d4-a716-446655440000',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. Create doctors table
CREATE TABLE IF NOT EXISTS doctors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    department TEXT NOT NULL,
    specialization TEXT NOT NULL,
    fee NUMERIC(10,2) NOT NULL DEFAULT 500.00,
    hospital_id UUID DEFAULT '550e8400-e29b-41d4-a716-446655440000',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. Create patients table
CREATE TABLE IF NOT EXISTS patients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id TEXT UNIQUE NOT NULL,
    first_name TEXT NOT NULL,
    last_name TEXT,
    age TEXT,
    gender TEXT CHECK (gender IN ('M', 'F', 'MALE', 'FEMALE', 'OTHER')),
    phone TEXT,
    email TEXT,
    address TEXT,
    emergency_contact_name TEXT,
    emergency_contact_phone TEXT,
    medical_history TEXT,
    allergies TEXT,
    current_medications TEXT,
    blood_group TEXT,
    notes TEXT,
    date_of_entry DATE,
    hospital_id UUID DEFAULT '550e8400-e29b-41d4-a716-446655440000',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES users(id)
);

-- 7. Create beds table
CREATE TABLE IF NOT EXISTS beds (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bed_number TEXT UNIQUE NOT NULL,
    room_type TEXT NOT NULL CHECK (room_type IN ('GENERAL', 'PRIVATE', 'ICU', 'EMERGENCY')),
    department TEXT,
    status TEXT DEFAULT 'AVAILABLE' CHECK (status IN ('AVAILABLE', 'OCCUPIED', 'MAINTENANCE')),
    daily_rate NUMERIC(10,2) NOT NULL DEFAULT 1000,
    hospital_id UUID DEFAULT '550e8400-e29b-41d4-a716-446655440000',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 8. Create patient_admissions table
CREATE TABLE IF NOT EXISTS patient_admissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
    bed_number TEXT,
    room_type TEXT CHECK (room_type IN ('GENERAL', 'PRIVATE', 'ICU', 'EMERGENCY')),
    department TEXT,
    daily_rate NUMERIC(10,2),
    admission_date DATE NOT NULL,
    discharge_date DATE,
    status TEXT DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'DISCHARGED')),
    services JSONB DEFAULT '[]',
    total_amount NUMERIC(10,2) DEFAULT 0,
    amount_paid NUMERIC(10,2) DEFAULT 0,
    balance_amount NUMERIC(10,2) DEFAULT 0,
    hospital_id UUID DEFAULT '550e8400-e29b-41d4-a716-446655440000',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 9. Create patient_transactions table
CREATE TABLE IF NOT EXISTS patient_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
    transaction_type TEXT NOT NULL,
    amount NUMERIC(10,2) NOT NULL,
    payment_mode TEXT,
    doctor_id TEXT,
    doctor_name TEXT,
    department TEXT,
    description TEXT,
    hospital_id UUID DEFAULT '550e8400-e29b-41d4-a716-446655440000',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 10. Create daily_expenses table
CREATE TABLE IF NOT EXISTS daily_expenses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    expense_category TEXT NOT NULL,
    description TEXT NOT NULL,
    amount NUMERIC(10,2) NOT NULL,
    payment_mode TEXT,
    expense_date DATE NOT NULL,
    hospital_id UUID DEFAULT '550e8400-e29b-41d4-a716-446655440000',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES users(id)
);

-- ============================================
-- PART 2: CREATE ADMIN USER
-- ============================================

-- Create admin user in auth.users (if not exists)
-- Note: You need to create the user through Supabase Auth first
-- Go to Authentication > Users > Create new user with:
-- Email: admin@hospital.com
-- Password: admin123

-- After creating the auth user, run this to create the profile:
DO $$
DECLARE
    admin_user_id UUID;
BEGIN
    -- Try to get the admin user ID from auth.users
    SELECT id INTO admin_user_id FROM auth.users WHERE email = 'admin@hospital.com' LIMIT 1;
    
    IF admin_user_id IS NOT NULL THEN
        -- Create or update the user profile
        INSERT INTO users (id, email, first_name, last_name, role, is_active)
        VALUES (
            admin_user_id,
            'admin@hospital.com',
            'Admin',
            'User',
            'ADMIN',
            TRUE
        )
        ON CONFLICT (id) DO UPDATE SET
            first_name = EXCLUDED.first_name,
            last_name = EXCLUDED.last_name,
            role = EXCLUDED.role,
            is_active = EXCLUDED.is_active;
        
        RAISE NOTICE 'Admin user profile created/updated successfully';
    ELSE
        RAISE NOTICE 'Admin user not found in auth.users. Please create it first in Supabase Authentication';
    END IF;
END $$;

-- ============================================
-- PART 3: INSERT SAMPLE DATA
-- ============================================

-- Insert sample departments
INSERT INTO departments (name, description) VALUES
    ('GENERAL', 'General Medicine'),
    ('CARDIOLOGY', 'Heart and Cardiovascular'),
    ('ORTHOPEDICS', 'Bones and Joints'),
    ('PEDIATRICS', 'Child Care'),
    ('ICU', 'Intensive Care Unit')
ON CONFLICT (name) DO NOTHING;

-- Insert sample doctors
INSERT INTO doctors (name, department, specialization, fee) VALUES
    ('Dr. Smith', 'GENERAL', 'General Physician', 500),
    ('Dr. Johnson', 'CARDIOLOGY', 'Cardiologist', 1000),
    ('Dr. Williams', 'ORTHOPEDICS', 'Orthopedic Surgeon', 1500),
    ('Dr. Brown', 'PEDIATRICS', 'Pediatrician', 600),
    ('Dr. Davis', 'ICU', 'Critical Care', 2000)
ON CONFLICT DO NOTHING;

-- Insert sample beds
INSERT INTO beds (bed_number, room_type, department, daily_rate) VALUES
    ('GEN-001', 'GENERAL', 'GENERAL', 1000),
    ('GEN-002', 'GENERAL', 'GENERAL', 1000),
    ('PVT-001', 'PRIVATE', 'GENERAL', 2500),
    ('PVT-002', 'PRIVATE', 'GENERAL', 2500),
    ('ICU-001', 'ICU', 'ICU', 5000),
    ('ICU-002', 'ICU', 'ICU', 5000)
ON CONFLICT (bed_number) DO NOTHING;

-- ============================================
-- PART 4: ENABLE ROW LEVEL SECURITY
-- ============================================

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE patients ENABLE ROW LEVEL SECURITY;
ALTER TABLE patient_admissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE patient_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE beds ENABLE ROW LEVEL SECURITY;
ALTER TABLE doctors ENABLE ROW LEVEL SECURITY;
ALTER TABLE departments ENABLE ROW LEVEL SECURITY;

-- Create basic policies for authenticated users
CREATE POLICY "Authenticated users can read all data" ON users
    FOR SELECT USING (true);

CREATE POLICY "Authenticated users can manage patients" ON patients
    FOR ALL USING (true);

CREATE POLICY "Authenticated users can manage admissions" ON patient_admissions
    FOR ALL USING (true);

CREATE POLICY "Authenticated users can manage transactions" ON patient_transactions
    FOR ALL USING (true);

CREATE POLICY "Authenticated users can manage expenses" ON daily_expenses
    FOR ALL USING (true);

CREATE POLICY "Authenticated users can read beds" ON beds
    FOR SELECT USING (true);

CREATE POLICY "Authenticated users can read doctors" ON doctors
    FOR SELECT USING (true);

CREATE POLICY "Authenticated users can read departments" ON departments
    FOR SELECT USING (true);

-- ============================================
-- PART 5: VERIFY SETUP
-- ============================================

-- Check all tables
SELECT 'Tables Created:' as status;
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

-- Check if admin user exists
SELECT 'Admin User Status:' as status;
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM auth.users WHERE email = 'admin@hospital.com') 
        THEN 'Admin user exists in auth.users' 
        ELSE 'Admin user NOT found - Please create in Supabase Authentication' 
    END as admin_status;

-- Check data counts
SELECT 'Data Summary:' as status;
SELECT 'Departments' as table_name, COUNT(*) as count FROM departments
UNION ALL
SELECT 'Doctors', COUNT(*) FROM doctors
UNION ALL
SELECT 'Beds', COUNT(*) FROM beds
UNION ALL
SELECT 'Patients', COUNT(*) FROM patients;

-- ============================================
-- IMPORTANT: MANUAL STEPS REQUIRED
-- ============================================
-- 1. Go to Supabase Dashboard > Authentication > Users
-- 2. Click "Create new user"
-- 3. Enter:
--    Email: admin@hospital.com
--    Password: admin123
-- 4. Click "Create user"
-- 5. Run this SQL script again to create the user profile