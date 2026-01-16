-- Fix receipt_number column in daily_expenses table
-- This script will add the receipt_number column if it doesn't exist

-- First, let's check if the column exists and add it if missing
DO $$ 
BEGIN
    -- Check if receipt_number column exists
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'daily_expenses' 
        AND column_name = 'receipt_number'
    ) THEN
        -- Add the missing column
        ALTER TABLE daily_expenses 
        ADD COLUMN receipt_number TEXT;
        
        RAISE NOTICE 'Added receipt_number column to daily_expenses table';
    ELSE
        RAISE NOTICE 'receipt_number column already exists in daily_expenses table';
    END IF;
END $$;

-- Also ensure the status column exists and has the correct name
DO $$ 
BEGIN
    -- Check if status column exists (might be named approval_status)
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'daily_expenses' 
        AND column_name = 'status'
    ) THEN
        -- Check if approval_status exists and rename it to status
        IF EXISTS (
            SELECT 1 
            FROM information_schema.columns 
            WHERE table_name = 'daily_expenses' 
            AND column_name = 'approval_status'
        ) THEN
            ALTER TABLE daily_expenses 
            RENAME COLUMN approval_status TO status;
            
            RAISE NOTICE 'Renamed approval_status to status in daily_expenses table';
        ELSE
            -- Add status column if neither exists
            ALTER TABLE daily_expenses 
            ADD COLUMN status TEXT DEFAULT 'APPROVED' CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED'));
            
            RAISE NOTICE 'Added status column to daily_expenses table';
        END IF;
    ELSE
        RAISE NOTICE 'status column already exists in daily_expenses table';
    END IF;
END $$;

-- Update any existing records to have default status if NULL
UPDATE daily_expenses 
SET status = 'APPROVED' 
WHERE status IS NULL;