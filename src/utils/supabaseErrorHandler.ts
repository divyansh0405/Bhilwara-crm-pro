import { PostgrestError } from '@supabase/supabase-js';

export interface SupabaseErrorDetails {
  code?: string;
  message: string;
  details?: string;
  hint?: string;
}

export const handleSupabaseError = (error: PostgrestError | Error | null): SupabaseErrorDetails | null => {
  if (!error) return null;

  // Handle Supabase PostgrestError
  if ('code' in error && 'details' in error) {
    const pgError = error as PostgrestError;
    console.error('Supabase Database Error:', {
      code: pgError.code,
      message: pgError.message,
      details: pgError.details,
      hint: pgError.hint,
    });
    
    return {
      code: pgError.code,
      message: pgError.message,
      details: pgError.details,
      hint: pgError.hint,
    };
  }
  
  // Handle generic errors
  console.error('Generic Error:', error.message);
  return {
    message: error.message,
  };
};

export const withErrorHandling = async <T>(
  operation: () => Promise<{ data: T; error: PostgrestError | null }>
): Promise<{ data: T | null; error: SupabaseErrorDetails | null }> => {
  try {
    const result = await operation();
    
    if (result.error) {
      return {
        data: null,
        error: handleSupabaseError(result.error),
      };
    }
    
    return {
      data: result.data,
      error: null,
    };
  } catch (error) {
    return {
      data: null,
      error: handleSupabaseError(error as Error),
    };
  }
};