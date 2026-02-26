#!/bin/bash

# Quick Database Cleanup Script
# Usage: ./cleanup-db.sh

echo "🧹 Cleaning up Sweatcoin database..."
echo "📍 This will permanently delete all data!"
echo ""

# Check if npm is available
if command -v npm &> /dev/null; then
    echo "📦 Using npm script..."
    npm run db:cleanup
else
    echo "📦 Using direct node execution..."
    node scripts/cleanup_database.js
fi

echo ""
echo "✅ Database cleanup complete!"