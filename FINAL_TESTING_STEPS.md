# Final Testing Steps - Complete MongoDB Sync Flow

## Overview
Your backend server is now running on port 5002 with comprehensive logging. Follow these steps to test the complete user registration and MongoDB sync flow.

## Step 1: Update Flutter App Configuration
```bash
cd backend
npm run update:flutter
```
This will automatically detect your backend port and update the Flutter config.

## Step 2: Start Flutter App
```bash
cd flutter_app
flutter run
```

## Step 3: Test User Registration
1. Open the Flutter app
2. Tap "Sign In with Google"
3. Complete the Google authentication process
4. **Watch the backend terminal for detailed logs**

## Expected Backend Log Output

When a user signs in, you should see these logs in your backend terminal:

```
📥 [SERVER] POST /api/auth/verify-token
📥 [SERVER] Body: { idToken: 'eyJhbGciOiJSUzI1NiIs...' }

🔍 [BACKEND] Received verify-token request
🔍 [BACKEND] Request body: {
  "idToken": "eyJhbGciOiJSUzI1NiIs..."
}

✅ [BACKEND] ID token received, verifying with Firebase...
✅ [BACKEND] Token verified for user: jN4tUtKaQ1fkGMwKmdYcA3tt2Lm1
✅ [BACKEND] User details: name=John Doe, email=john@example.com, picture=https://...

🔄 [MONGODB] Finding user with UID: jN4tUtKaQ1fkGMwKmdYcA3tt2Lm1
➕ [MONGODB] User not found, creating new user: jN4tUtKaQ1fkGMwKmdYcA3tt2Lm1
✅ [MONGODB] New user created successfully: jN4tUtKaQ1fkGMwKmdYcA3tt2Lm1
✅ [MONGODB] User data: {
  uid: 'jN4tUtKaQ1fkGMwKmdYcA3tt2Lm1',
  name: 'John Doe',
  email: 'john@example.com',
  balance: 0,
  lifetimeSteps: 0
}

✅ [BACKEND] User operation completed: jN4tUtKaQ1fkGMwKmdYcA3tt2Lm1
✅ [BACKEND] JWT token generated successfully
📤 [BACKEND] Sending response to client
📤 [BACKEND] Response: {
  "success": true,
  "user": {
    "uid": "jN4tUtKaQ1fkGMwKmdYcA3tt2Lm1",
    "name": "John Doe",
    "email": "john@example.com",
    "photoUrl": "https://...",
    "balance": 0,
    "lifetimeSteps": 0,
    "lifetimeCoins": 0
  },
  "token": "eyJhbGciOiJIUzI1NiIs..."
}
```

## Step 4: Verify MongoDB Data

### Option A: Check MongoDB Atlas
1. Open MongoDB Atlas
2. Navigate to your cluster
3. Go to Collections → sweatcoin → users
4. You should see a document with the user's Firebase UID, name, email, etc.

### Option B: Use Cleanup Script to Verify
```bash
cd backend
npm run db:cleanup
```
This will show you all existing collections and then clean them up.

## Step 5: Test Multiple Users
1. Sign out from the Flutter app
2. Sign in with a different Google account
3. Verify a new user document is created in MongoDB
4. Check that both users exist in the database

## Success Indicators

### ✅ Backend Logs Should Show:
- `✅ [BACKEND] Token verified for user: [UID]`
- `➕ [MONGODB] User not found, creating new user: [UID]`
- `✅ [MONGODB] New user created successfully: [UID]`
- `📤 [BACKEND] Sending response to client`

### ✅ Flutter Logs Should Show:
- `[AUTH] [MONGODB_SYNC_SUCCESS] User synced with MongoDB successfully`

### ✅ MongoDB Atlas Should Show:
- User documents in the `users` collection
- Each document contains: uid, name, email, balance, lifetimeSteps, etc.

## Troubleshooting

### If You Don't See Backend Logs:
1. Make sure backend server is running: `npm run dev`
2. Check that Flutter app is using local API (should be after our fix)
3. Verify the request is actually reaching the backend

### If MongoDB Sync Fails:
1. Check MongoDB connection in `.env` file
2. Verify MongoDB Atlas cluster status
3. Look for database connection errors in backend logs

### If Port Changes:
Run `npm run update:flutter` to automatically update the Flutter config

## Next Steps After Success

Once you've verified the sync is working:
1. You can switch back to live API if needed by setting `useLiveApi = true`
2. Test step syncing functionality
3. Test reward redemption
4. Test wallet operations

## Quick Commands Reference

```bash
# Start backend with logging
cd backend && npm run dev

# Update Flutter config automatically
cd backend && npm run update:flutter

# Test all API endpoints
cd backend && npm run test:api

# Clean database for testing
cd backend && npm run db:cleanup

# Start Flutter app
cd flutter_app && flutter run
```

The comprehensive logging will help you see exactly what's happening at every step of the authentication and sync process. Watch the backend terminal closely during user registration to verify everything is working correctly!