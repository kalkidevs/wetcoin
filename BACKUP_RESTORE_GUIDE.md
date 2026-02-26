# Sweatcoin Database Cleanup Guide

## Overview

This guide provides instructions for completely resetting your Sweatcoin database to a fresh state.

## Quick Start

### Option 1: Using npm script (Recommended)
```bash
cd backend
npm run db:cleanup
```

### Option 2: Using shell script
```bash
cd backend
./cleanup-db.sh
```

### Option 3: Direct Node.js execution
```bash
cd backend
node scripts/cleanup_database.js
```

## What the Cleanup Script Does

1. **Connects to your MongoDB database** using the `MONGODB_URI` from your `.env` file
2. **Lists all existing collections** (users, rewards, steps, wallets, etc.)
3. **Drops all collections** permanently
4. **Verifies the cleanup** was successful
5. **Disconnects safely** from the database

## Safety Features

- ✅ Requires `MONGODB_URI` to be set in `.env` file
- ✅ Shows what will be deleted before proceeding
- ✅ Graceful error handling
- ✅ Automatic disconnection
- ✅ No accidental execution without confirmation

## Example Output

```
🧹 Starting database cleanup...
📍 Connecting to: mongodb+srv://***:***@cluster.mongodb.net/wetcoin
📋 Found 4 collections:
   - users
   - rewards
   - steps
   - wallets

🗑️  Dropping all collections...
   Dropping: users...
   Dropping: rewards...
   Dropping: steps...
   Dropping: wallets...

✅ All collections dropped successfully!
📊 Remaining collections: 0
🎉 Database cleanup complete! Your database is now fresh and clean.
🔌 Disconnected from database
```

## Files Created

- `backend/scripts/cleanup_database.js` - Main cleanup script
- `backend/scripts/README.md` - Detailed documentation
- `backend/cleanup-db.sh` - Convenient shell script wrapper
- Updated `backend/package.json` - Added `db:cleanup` npm script

## Warning

⚠️ **This will permanently delete ALL data in your database!** Make sure you have backups if needed before running this script.

## Troubleshooting

### Error: MONGODB_URI not found
Make sure you have a `.env` file in the `backend` directory with your MongoDB connection string:
```
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/database
```

### Permission denied (cleanup-db.sh)
Make sure the shell script is executable:
```bash
chmod +x backend/cleanup-db.sh
```

### Connection errors
- Verify your MongoDB connection string is correct
- Check your internet connection
- Ensure your MongoDB cluster is accessible
- Check firewall settings if using local MongoDB

## After Cleanup

Your database will be completely empty. When users sign in again:
1. They will be created fresh in both Firestore and MongoDB
2. No previous step counts, rewards, or wallet data will exist
3. The app will start with a clean slate

## Related Fixes

This cleanup script accompanies the following fixes made to your Sweatcoin app:

1. ✅ **Fixed connection popup** - Only shows when there's no internet
2. ✅ **Fixed Firebase-to-MongoDB sync** - Users now sync properly to MongoDB Atlas
3. ✅ **Added database cleanup** - Easy way to reset database state