-- Seva-Connect Integration Schema
-- Run this to enable API Key management and Cross-App features in the CRM

-- 1. API Keys Table
CREATE TABLE IF NOT EXISTS api_keys (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  label TEXT NOT NULL,
  key TEXT UNIQUE NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Add 'source' column to future_appointments if not exists
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'future_appointments' AND column_name = 'source') THEN 
        ALTER TABLE future_appointments ADD COLUMN source TEXT DEFAULT 'INTERNAL'; 
    END IF; 
END $$;

-- 3. Seed Demo Key
INSERT INTO api_keys (label, key) VALUES
('Seva-Sangrah Partner', 'sk_seva_crm_partner_001')
ON CONFLICT (key) DO NOTHING;

-- Verification
SELECT * FROM api_keys;
