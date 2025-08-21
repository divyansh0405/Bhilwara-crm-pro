-- Create Admin User with Full Access
-- Credentials: admin@valant.com / Admin@321

-- First, sign up the user with Supabase Auth (this needs to be done through the application)
-- This SQL script handles the metadata setup after signup

-- Update user metadata to set admin role
UPDATE auth.users 
SET 
  raw_user_meta_data = jsonb_build_object(
    'role', 'admin',
    'first_name', 'Admin',
    'last_name', 'User'
  ),
  email_confirmed_at = now()
WHERE email = 'admin@valant.com';

-- Insert or update user profile in users table
INSERT INTO users (
  id,
  email,
  first_name,
  last_name,
  role,
  is_active,
  created_at,
  updated_at
) 
SELECT 
  id,
  'admin@valant.com',
  'Admin',
  'User',
  'admin'::user_role,
  true,
  now(),
  now()
FROM auth.users 
WHERE email = 'admin@valant.com'
ON CONFLICT (id) 
DO UPDATE SET
  role = 'admin'::user_role,
  first_name = 'Admin',
  last_name = 'User',
  is_active = true,
  updated_at = now();

-- Verify the admin user was created correctly
SELECT 
  u.id,
  u.email,
  u.first_name,
  u.last_name,
  u.role,
  u.is_active,
  au.raw_user_meta_data->>'role' as metadata_role
FROM users u
JOIN auth.users au ON u.id = au.id
WHERE u.email = 'admin@valant.com';