-- Verify and fix user account for anand@valant.com
-- Run this in Supabase SQL Editor

-- Step 1: Check if user exists in auth.users
SELECT
    id,
    email,
    email_confirmed_at,
    created_at,
    confirmed_at,
    last_sign_in_at
FROM auth.users
WHERE email = 'anand@valant.com';

-- Step 2: CONFIRM the user if not confirmed (this is likely the issue)
UPDATE auth.users
SET
    email_confirmed_at = NOW(),
    confirmed_at = NOW()
WHERE email = 'anand@valant.com'
AND email_confirmed_at IS NULL;

-- Step 3: Check if user exists in users table
SELECT
    id,
    email,
    first_name,
    last_name,
    role,
    is_active
FROM users
WHERE email = 'anand@valant.com';

-- Step 4: If user doesn't exist in users table, create it
INSERT INTO users (
    id,
    email,
    first_name,
    last_name,
    role,
    hospital_id,
    is_active
)
SELECT
    id,
    'anand@valant.com',
    'Anand',
    'Admin',
    'ADMIN',
    '550e8400-e29b-41d4-a716-446655440000',
    TRUE
FROM auth.users
WHERE email = 'anand@valant.com'
ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    first_name = EXCLUDED.first_name,
    last_name = EXCLUDED.last_name,
    role = EXCLUDED.role,
    is_active = TRUE;

-- Step 5: Verify everything is correct
SELECT
    au.id,
    au.email,
    au.email_confirmed_at,
    u.first_name,
    u.last_name,
    u.role,
    u.is_active
FROM auth.users au
LEFT JOIN users u ON u.id = au.id
WHERE au.email = 'anand@valant.com';
