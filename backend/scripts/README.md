# Database Cleanup Scripts

This directory contains scripts for managing your database state.

## cleanup_database.js

Completely resets your MongoDB database by dropping all collections.

### Usage

```bash
# Run the cleanup script
node scripts/cleanup_database.js

# Or use npm script (recommended)
npm run db:cleanup
```

### What it does

1. Connects to your MongoDB database using the `MONGODB_URI` from your `.env` file
2. Lists all existing collections
3. Drops all collections (users, rewards, steps, wallets, etc.)
4. Verifies the cleanup was successful
5. Disconnects from the database

### Safety Features

- ✅ Requires `MONGODB_URI` to be set in `.env`
- ✅ Shows what collections will be dropped before proceeding
- ✅ Graceful error handling
- ✅ Automatic disconnection

### Warning

⚠️ **This will permanently delete all data in your database!** Make sure you have backups if needed.

### Example Output

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