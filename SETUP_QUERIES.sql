-- ================================================
-- STEP 1: CREATE ALL TABLES
-- ================================================

-- 1. Users table
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

-- 2. Hospitals table
CREATE TABLE IF NOT EXISTS hospitals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    address TEXT,
    phone TEXT,
    email TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Departments table
CREATE TABLE IF NOT EXISTS departments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT UNIQUE NOT NULL,
    description TEXT,
    hospital_id UUID DEFAULT '550e8400-e29b-41d4-a716-446655440000',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Doctors table
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

-- 5. Patients table
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

-- 6. Beds table
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

-- 7. Patient Admissions table
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

-- 8. Patient Transactions table
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

-- 9. Daily Expenses table
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

-- ================================================
-- STEP 2: INSERT DEFAULT DATA
-- ================================================

-- Insert default hospital
INSERT INTO hospitals (id, name, address, phone, email)
VALUES (
    '550e8400-e29b-41d4-a716-446655440000',
    'City General Hospital',
    '123 Main St, City',
    '555-0100',
    'info@hospital.com'
) ON CONFLICT (id) DO NOTHING;

-- Insert departments
INSERT INTO departments (name, description) VALUES
    ('GENERAL', 'General Medicine'),
    ('CARDIOLOGY', 'Heart and Cardiovascular'),
    ('ORTHOPEDICS', 'Bones and Joints'),
    ('PEDIATRICS', 'Child Care'),
    ('ICU', 'Intensive Care Unit')
ON CONFLICT (name) DO NOTHING;

-- Insert doctors
INSERT INTO doctors (name, department, specialization, fee) VALUES
    ('Dr. Smith', 'GENERAL', 'General Physician', 500),
    ('Dr. Johnson', 'CARDIOLOGY', 'Cardiologist', 1000),
    ('Dr. Williams', 'ORTHOPEDICS', 'Orthopedic Surgeon', 1500),
    ('Dr. Brown', 'PEDIATRICS', 'Pediatrician', 600),
    ('Dr. Davis', 'ICU', 'Critical Care', 2000)
ON CONFLICT DO NOTHING;

-- Insert beds
INSERT INTO beds (bed_number, room_type, department, daily_rate) VALUES
    ('GEN-001', 'GENERAL', 'GENERAL', 1000),
    ('GEN-002', 'GENERAL', 'GENERAL', 1000),
    ('GEN-003', 'GENERAL', 'GENERAL', 1000),
    ('PVT-001', 'PRIVATE', 'GENERAL', 2500),
    ('PVT-002', 'PRIVATE', 'GENERAL', 2500),
    ('ICU-001', 'ICU', 'ICU', 5000),
    ('ICU-002', 'ICU', 'ICU', 5000),
    ('EMG-001', 'EMERGENCY', 'EMERGENCY', 3000)
ON CONFLICT (bed_number) DO NOTHING;

-- ================================================
-- STEP 3: ENABLE ROW LEVEL SECURITY
-- ================================================

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE patients ENABLE ROW LEVEL SECURITY;
ALTER TABLE patient_admissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE patient_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE beds ENABLE ROW LEVEL SECURITY;
ALTER TABLE doctors ENABLE ROW LEVEL SECURITY;
ALTER TABLE departments ENABLE ROW LEVEL SECURITY;
ALTER TABLE hospitals ENABLE ROW LEVEL SECURITY;

-- ================================================
-- STEP 4: CREATE POLICIES (Allow all for now)
-- ================================================

-- Drop existing policies if any
DROP POLICY IF EXISTS "Enable all for authenticated users" ON users;
DROP POLICY IF EXISTS "Enable all for authenticated users" ON patients;
DROP POLICY IF EXISTS "Enable all for authenticated users" ON patient_admissions;
DROP POLICY IF EXISTS "Enable all for authenticated users" ON patient_transactions;
DROP POLICY IF EXISTS "Enable all for authenticated users" ON daily_expenses;
DROP POLICY IF EXISTS "Enable all for authenticated users" ON beds;
DROP POLICY IF EXISTS "Enable all for authenticated users" ON doctors;
DROP POLICY IF EXISTS "Enable all for authenticated users" ON departments;
DROP POLICY IF EXISTS "Enable all for authenticated users" ON hospitals;

-- Create permissive policies
CREATE POLICY "Enable all for authenticated users" ON users FOR ALL USING (true);
CREATE POLICY "Enable all for authenticated users" ON patients FOR ALL USING (true);
CREATE POLICY "Enable all for authenticated users" ON patient_admissions FOR ALL USING (true);
CREATE POLICY "Enable all for authenticated users" ON patient_transactions FOR ALL USING (true);
CREATE POLICY "Enable all for authenticated users" ON daily_expenses FOR ALL USING (true);
CREATE POLICY "Enable all for authenticated users" ON beds FOR ALL USING (true);
CREATE POLICY "Enable all for authenticated users" ON doctors FOR ALL USING (true);
CREATE POLICY "Enable all for authenticated users" ON departments FOR ALL USING (true);
CREATE POLICY "Enable all for authenticated users" ON hospitals FOR ALL USING (true);

-- ================================================
-- STEP 5: CREATE ADMIN USER PROFILE
-- ================================================

-- After creating user in Authentication, run this:
DO $$
DECLARE
    admin_id UUID;
BEGIN
    -- Get the admin user ID
    SELECT id INTO admin_id FROM auth.users WHERE email = 'admin@hospital.com' LIMIT 1;
    
    IF admin_id IS NOT NULL THEN
        INSERT INTO users (id, email, first_name, last_name, role, is_active)
        VALUES (
            admin_id,
            'admin@hospital.com',
            'Admin',
            'User',
            'ADMIN',
            TRUE
        )
        ON CONFLICT (id) DO UPDATE SET
            first_name = 'Admin',
            last_name = 'User',
            role = 'ADMIN',
            is_active = TRUE;
        
        RAISE NOTICE 'Admin profile created successfully!';
    ELSE
        RAISE NOTICE 'Please create admin@hospital.com in Authentication first!';
    END IF;
END $$;

-- ================================================
-- STEP 6: VERIFY SETUP
-- ================================================

SELECT 'TABLES CREATED:' as info;
SELECT COUNT(*) as table_count FROM information_schema.tables WHERE table_schema = 'public';

SELECT 'DATA SUMMARY:' as info;
SELECT 'Departments' as type, COUNT(*) as count FROM departments
UNION ALL SELECT 'Doctors', COUNT(*) FROM doctors
UNION ALL SELECT 'Beds', COUNT(*) FROM beds
UNION ALL SELECT 'Users', COUNT(*) FROM users;