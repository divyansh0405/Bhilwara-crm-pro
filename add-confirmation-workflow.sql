-- Add confirmation workflow for appointments and patients
-- Run this in Supabase SQL Editor

-- Step 1: Add is_confirmed flag to patients table
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'patients' AND column_name = 'is_confirmed'
    ) THEN
        ALTER TABLE patients ADD COLUMN is_confirmed BOOLEAN DEFAULT false;
        RAISE NOTICE 'Added is_confirmed column to patients';
    END IF;
END $$;

-- Step 2: Add confirmation_date to appointments table
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'appointments' AND column_name = 'confirmation_date'
    ) THEN
        ALTER TABLE appointments ADD COLUMN confirmation_date TIMESTAMP WITH TIME ZONE;
        RAISE NOTICE 'Added confirmation_date column to appointments';
    END IF;
END $$;

-- Step 3: Add source column to track where appointment came from
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'appointments' AND column_name = 'source'
    ) THEN
        ALTER TABLE appointments ADD COLUMN source TEXT DEFAULT 'CRM';
        RAISE NOTICE 'Added source column to appointments';
    END IF;
END $$;

-- Step 4: Mark existing patients as confirmed
UPDATE patients
SET is_confirmed = true
WHERE is_confirmed IS NULL OR is_confirmed = false;

-- Step 5: Mark existing appointments as confirmed
UPDATE appointments
SET confirmation_date = created_at,
    source = 'CRM'
WHERE confirmation_date IS NULL;

-- Step 6: Create a function to confirm an appointment
CREATE OR REPLACE FUNCTION confirm_appointment(appointment_uuid UUID)
RETURNS void AS $$
BEGIN
    -- Update appointment confirmation date
    UPDATE appointments
    SET confirmation_date = NOW(),
        status = 'CONFIRMED'
    WHERE id = appointment_uuid;

    -- Mark patient as confirmed
    UPDATE patients
    SET is_confirmed = true
    WHERE id = (
        SELECT patient_id FROM appointments WHERE id = appointment_uuid
    );

    RAISE NOTICE 'Appointment % confirmed', appointment_uuid;
END;
$$ LANGUAGE plpgsql;

-- Step 7: Verify changes
SELECT
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'patients'
AND column_name = 'is_confirmed';

SELECT
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'appointments'
AND column_name IN ('confirmation_date', 'source');

-- Step 8: Show sample data
SELECT
    a.id,
    a.appointment_id,
    a.status,
    a.source,
    a.confirmation_date,
    p.first_name,
    p.last_name,
    p.is_confirmed as patient_confirmed
FROM appointments a
LEFT JOIN patients p ON p.id = a.patient_id
ORDER BY a.created_at DESC
LIMIT 5;
