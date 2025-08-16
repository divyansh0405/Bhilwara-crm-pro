import React from 'react';

const Debug: React.FC = () => {
  console.log('Debug component rendering...');
  
  return (
    <div style={{ padding: '20px', textAlign: 'center', background: '#f0f0f0', minHeight: '100vh' }}>
      <h1>Hospital CRM Bhilwara - Debug Mode</h1>
      <p>React is working! ✓</p>
      <p>Check browser console for errors.</p>
      
      <div style={{ marginTop: '20px', textAlign: 'left', maxWidth: '600px', margin: '20px auto' }}>
        <h3>Debug Checklist:</h3>
        <ul>
          <li>✓ React rendering</li>
          <li>✓ Basic styles applied</li>
          <li>Check console for errors</li>
          <li>Check network tab for failed requests</li>
        </ul>
      </div>
      
      <button 
        onClick={() => window.location.reload()} 
        style={{ 
          marginTop: '20px', 
          padding: '10px 20px', 
          background: '#007bff', 
          color: 'white', 
          border: 'none', 
          borderRadius: '5px',
          cursor: 'pointer'
        }}
      >
        Reload Page
      </button>
    </div>
  );
};

export default Debug;