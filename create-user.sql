-- Create admin user in Supabase Authentication
-- Run this in Supabase SQL Editor

-- First, check if user exists in auth.users
SELECT id, email FROM auth.users WHERE email = 'anand@valant.com';

-- If user doesn't exist, you need to create it via Supabase Dashboard:
-- 1. Go to: https://supabase.com/dashboard/project/hgwomxpzaeeqgxsnhceq/auth/users
-- 2. Click "Add User" button
-- 3. Enter:
--    Email: anand@valant.com
--    Password: Anand@123
--    Auto Confirm User: YES (check this box)
-- 4. Click "Create User"

-- After creating in Dashboard, create the user profile in users table:
-- Replace 'USER_ID_FROM_AUTH' with the actual UUID from auth.users

INSERT INTO users (
    id,
    email,
    first_name,
    last_name,
    role,
    phone,
    hospital_id,
    is_active
)
SELECT
    id,
    'anand@valant.com',
    'Anand',
    'Admin',
    'ADMIN',
    NULL,
    '550e8400-e29b-41d4-a716-446655440000',
    TRUE
FROM auth.users
WHERE email = 'anand@valant.com'
ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    role = EXCLUDED.role;

-- Verify the user was created
SELECT
    u.id,
    u.email,
    u.first_name,
    u.last_name,
    u.role,
    u.is_active
FROM users u
WHERE u.email = 'anand@valant.com';
