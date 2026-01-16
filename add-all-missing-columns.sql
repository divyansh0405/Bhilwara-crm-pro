-- Add all missing columns to appointments table
-- Run this in Supabase SQL Editor

-- Step 1: Check current table structure
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'appointments'
ORDER BY ordinal_position;

-- Step 2: Add appointment_id column
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'appointments' AND column_name = 'appointment_id'
    ) THEN
        ALTER TABLE appointments ADD COLUMN appointment_id TEXT;
        RAISE NOTICE 'Added appointment_id column';
    END IF;
END $$;

-- Step 3: Add appointment_type column
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'appointments' AND column_name = 'appointment_type'
    ) THEN
        ALTER TABLE appointments ADD COLUMN appointment_type TEXT DEFAULT 'CONSULTATION';
        RAISE NOTICE 'Added appointment_type column';
    END IF;
END $$;

-- Step 4: Add duration column
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'appointments' AND column_name = 'duration'
    ) THEN
        ALTER TABLE appointments ADD COLUMN duration INTEGER DEFAULT 30;
        RAISE NOTICE 'Added duration column';
    END IF;
END $$;

-- Step 5: Generate appointment_id for existing records without one
DO $$
DECLARE
    rec RECORD;
    new_apt_id TEXT;
    counter INTEGER := 1;
    year_month TEXT;
BEGIN
    FOR rec IN
        SELECT id, COALESCE(created_at, NOW()) as created_at
        FROM appointments
        WHERE appointment_id IS NULL OR appointment_id = ''
        ORDER BY COALESCE(created_at, NOW())
    LOOP
        year_month := TO_CHAR(rec.created_at, 'YYYYMM');
        new_apt_id := 'APT' || year_month || LPAD(counter::TEXT, 4, '0');

        UPDATE appointments
        SET appointment_id = new_apt_id
        WHERE id = rec.id;

        counter := counter + 1;
    END LOOP;

    RAISE NOTICE 'Updated % appointments with appointment_id', counter - 1;
END $$;

-- Step 6: Set default values for appointment_type if NULL
UPDATE appointments
SET appointment_type = 'CONSULTATION'
WHERE appointment_type IS NULL;

-- Step 7: Set default values for duration if NULL
UPDATE appointments
SET duration = 30
WHERE duration IS NULL;

-- Step 8: Make appointment_id NOT NULL
ALTER TABLE appointments
ALTER COLUMN appointment_id SET NOT NULL;

-- Step 9: Add unique constraint on appointment_id
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'appointments_appointment_id_key'
    ) THEN
        ALTER TABLE appointments
        ADD CONSTRAINT appointments_appointment_id_key UNIQUE (appointment_id);
        RAISE NOTICE 'Added unique constraint on appointment_id';
    END IF;
END $$;

-- Step 10: Verify all changes
SELECT
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'appointments'
AND column_name IN ('appointment_id', 'appointment_type', 'duration')
ORDER BY column_name;

-- Step 11: Show sample data
SELECT
    id,
    appointment_id,
    appointment_type,
    duration,
    patient_id,
    doctor_id,
    status,
    scheduled_at
FROM appointments
ORDER BY created_at DESC
LIMIT 5;
