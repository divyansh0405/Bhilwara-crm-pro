-- Fix appointments table - Add missing appointment_id column
-- Run this in Supabase SQL Editor

-- Step 1: Check current appointments table structure
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'appointments'
ORDER BY ordinal_position;

-- Step 2: Add appointment_id column if it doesn't exist
DO $$
BEGIN
    -- Check if column exists
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'appointments'
        AND column_name = 'appointment_id'
    ) THEN
        -- Add the column
        ALTER TABLE appointments
        ADD COLUMN appointment_id TEXT;

        RAISE NOTICE 'Added appointment_id column';
    ELSE
        RAISE NOTICE 'appointment_id column already exists';
    END IF;
END $$;

-- Step 3: Generate appointment_id for existing records that don't have one
DO $$
DECLARE
    rec RECORD;
    new_apt_id TEXT;
    counter INTEGER := 1;
BEGIN
    FOR rec IN
        SELECT id, created_at
        FROM appointments
        WHERE appointment_id IS NULL
        ORDER BY created_at
    LOOP
        -- Generate appointment_id in format APT202601XXXX
        new_apt_id := 'APT' ||
                      TO_CHAR(rec.created_at, 'YYYYMM') ||
                      LPAD(counter::TEXT, 4, '0');

        UPDATE appointments
        SET appointment_id = new_apt_id
        WHERE id = rec.id;

        counter := counter + 1;
    END LOOP;

    RAISE NOTICE 'Updated % existing appointments with appointment_id', counter - 1;
END $$;

-- Step 4: Make appointment_id NOT NULL and UNIQUE
ALTER TABLE appointments
ALTER COLUMN appointment_id SET NOT NULL;

-- Step 5: Add unique constraint if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'appointments_appointment_id_key'
    ) THEN
        ALTER TABLE appointments
        ADD CONSTRAINT appointments_appointment_id_key UNIQUE (appointment_id);

        RAISE NOTICE 'Added unique constraint on appointment_id';
    ELSE
        RAISE NOTICE 'Unique constraint already exists';
    END IF;
END $$;

-- Step 6: Verify the changes
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'appointments'
AND column_name = 'appointment_id';

-- Step 7: Show sample data
SELECT
    id,
    appointment_id,
    patient_id,
    doctor_id,
    status,
    scheduled_at
FROM appointments
ORDER BY created_at DESC
LIMIT 5;
