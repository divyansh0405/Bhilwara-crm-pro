#!/bin/bash

echo "🔧 Fixing Hospital CRM Bhilwara blank screen issue..."

# 1. Clear npm cache
echo "📦 Clearing npm cache..."
npm cache clean --force

# 2. Remove node_modules and package-lock
echo "🗑️ Removing node_modules and package-lock.json..."
rm -rf node_modules package-lock.json

# 3. Reinstall dependencies
echo "📥 Reinstalling dependencies..."
npm install

# 4. Clear Vite cache
echo "🧹 Clearing Vite cache..."
rm -rf .vite

# 5. Check for TypeScript errors
echo "🔍 Checking for TypeScript errors..."
npx tsc --noEmit || true

# 6. Try to build
echo "🏗️ Testing build..."
npm run build

echo "✅ Fixes applied!"
echo ""
echo "📝 Now try:"
echo "1. Run: npm run dev"
echo "2. Visit: http://localhost:3000?debug=true"
echo "3. Check browser console (F12) for errors"
echo ""
echo "If debug page works but main app doesn't:"
echo "- There's an issue with authentication or API calls"
echo "- Check Supabase connection in src/config/supabaseNew.ts"