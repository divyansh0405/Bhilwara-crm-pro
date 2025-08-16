import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import App from './App.tsx'
import Debug from './Debug.tsx'
import { ReactQueryProvider } from './config/reactQuery.tsx'

console.log('🔧 main.tsx loading...');

// Global error handler
window.addEventListener('error', (event) => {
  console.error('❌ Global error:', event.error);
});

window.addEventListener('unhandledrejection', (event) => {
  console.error('❌ Unhandled promise rejection:', event.reason);
});

const rootElement = document.getElementById('root');
console.log('📦 Root element:', rootElement);

// Check if we should run in debug mode
const urlParams = new URLSearchParams(window.location.search);
const debugMode = urlParams.get('debug') === 'true';

if (rootElement) {
  try {
    if (debugMode) {
      // Render debug component
      createRoot(rootElement).render(
        <StrictMode>
          <Debug />
        </StrictMode>,
      )
    } else {
      // Normal app
      createRoot(rootElement).render(
        <StrictMode>
          <ReactQueryProvider>
            <App />
          </ReactQueryProvider>
        </StrictMode>,
      )
    }
  } catch (error) {
    console.error('❌ Failed to render app:', error);
    // Fallback UI
    rootElement.innerHTML = `
      <div style="padding: 20px; text-align: center;">
        <h1>Error Loading Application</h1>
        <p>Check browser console for details</p>
        <pre style="text-align: left; background: #f0f0f0; padding: 10px; margin: 20px auto; max-width: 600px;">
${error}
        </pre>
        <button onclick="window.location.reload()" style="padding: 10px 20px; background: #007bff; color: white; border: none; border-radius: 5px; cursor: pointer;">
          Reload
        </button>
      </div>
    `;
  }
} else {
  console.error('❌ Root element not found!');
}
