// Script to create admin user: admin@valant.com / Admin@321
// Run this after setting up the Supabase project

import { supabase } from './src/config/supabase.js';

async function createAdminUser() {
  console.log('🔧 Creating admin user...');
  
  try {
    // Step 1: Sign up the admin user
    const { data: signUpData, error: signUpError } = await supabase.auth.signUp({
      email: 'admin@valant.com',
      password: 'Admin@321',
      options: {
        data: {
          role: 'admin',
          first_name: 'Admin',
          last_name: 'User'
        }
      }
    });

    if (signUpError) {
      console.error('❌ Signup error:', signUpError);
      return;
    }

    console.log('✅ Admin user signup successful:', signUpData.user?.email);

    // Step 2: Update user metadata (in case signup doesn't set it)
    if (signUpData.user) {
      const { error: metadataError } = await supabase.auth.admin.updateUserById(
        signUpData.user.id,
        {
          user_metadata: {
            role: 'admin',
            first_name: 'Admin',
            last_name: 'User'
          }
        }
      );

      if (metadataError) {
        console.error('❌ Metadata update error:', metadataError);
      } else {
        console.log('✅ Admin user metadata updated');
      }
    }

    console.log('🎉 Admin user created successfully!');
    console.log('📧 Email: admin@valant.com');
    console.log('🔑 Password: Admin@321');
    console.log('👑 Role: admin (full access)');
    
  } catch (error) {
    console.error('❌ Error creating admin user:', error);
  }
}

// Run the function
createAdminUser();