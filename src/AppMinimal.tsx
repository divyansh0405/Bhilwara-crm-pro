import React, { useState, useEffect } from 'react';
import toast, { Toaster } from 'react-hot-toast';

const AppMinimal: React.FC = () => {
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Simulate loading
    setTimeout(() => {
      setLoading(false);
    }, 1000);
  }, []);

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="text-6xl mb-4">🏥</div>
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
          <p className="text-gray-600">Loading Hospital CRM...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-100">
      <Toaster position="top-right" />
      
      <div className="bg-white shadow">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-16">
            <h1 className="text-xl font-semibold">Hospital CRM Bhilwara</h1>
            <button 
              onClick={() => toast.success('Working!')}
              className="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600"
            >
              Test Button
            </button>
          </div>
        </div>
      </div>
      
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="bg-white rounded-lg shadow p-6">
          <h2 className="text-lg font-medium mb-4">Minimal App is Working!</h2>
          <p>If you can see this, the basic React setup is working.</p>
          <p className="mt-2">The issue might be with:</p>
          <ul className="list-disc list-inside mt-2">
            <li>Authentication/Login system</li>
            <li>Supabase connection</li>
            <li>Complex components in the main App</li>
          </ul>
        </div>
      </div>
    </div>
  );
};

export default AppMinimal;