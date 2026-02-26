# Sweatcoin App Testing Guide

## Overview

This guide helps you test and verify that your Sweatcoin app is properly syncing user data to MongoDB Atlas.

## Quick Testing Steps

### 1. Start the Backend Server
```bash
cd backend
npm run dev
```
The server should start on port 5001.

### 2. Test the Backend API
```bash
cd backend
npm run test:api
```
This will test all API endpoints and verify they're working correctly.

### 3. Run the Flutter App
```bash
cd flutter_app
flutter run
```

### 4. Test User Registration
1. Open the Flutter app
2. Tap "Sign In with Google"
3. Complete the Google authentication
4. Check the logs for successful MongoDB sync

## Expected Log Output

When a user successfully signs in, you should see logs like this:

```
[AUTH] [TOKEN_VERIFICATION_START] Verifying Firebase ID token with backend
[AUTH] [TOKEN_VERIFICATION_SUCCESS] Token verified successfully. User: John Doe (user@example.com)
[AUTH] [USER_DATA_RECEIVED] Balance: 0, Steps: 0
[AUTH] [MONGODB_SYNC_SUCCESS] User synced with MongoDB successfully
```

## Troubleshooting

### Issue: 404 Error on /api/auth/verify-token
**Solution**: Make sure the backend server is running and the Flutter app is configured to use the local API.

1. Check backend server is running:
   ```bash
   cd backend
   npm run dev
   ```

2. Verify Flutter app uses local API:
   - Check `flutter_app/lib/core/config/env_config.dart`
   - Ensure `useLiveApi = false`

### Issue: MongoDB Connection Error
**Solution**: Verify your MongoDB connection string in `backend/.env`:

```
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/database
```

### Issue: Firebase Token Verification Failed
**Solution**: Check that Firebase Admin SDK is properly initialized in `backend/routes/auth.js`.

## API Testing Details

### Manual API Testing

You can manually test the API endpoints using curl:

```bash
# Test health check
curl http://localhost:5001/health

# Test auth endpoint (will return 400 without token)
curl -X POST http://localhost:5001/api/auth/verify-token -H "Content-Type: application/json" -d '{}'

# Test sync endpoint (will return 400 without data)
curl -X POST http://localhost:5001/api/sync -H "Content-Type: application/json" -d '{}'
```

### Database Verification

After a user signs in, you can verify the data was stored in MongoDB:

1. Open MongoDB Atlas
2. Navigate to your cluster
3. Check the `users` collection
4. You should see a document with the user's Firebase UID, name, email, etc.

## Common Issues and Solutions

### Issue: "API endpoint not found"
**Cause**: Flutter app trying to connect to wrong server
**Solution**: 
- Set `useLiveApi = false` in `env_config.dart`
- Restart the Flutter app

### Issue: "Network error during token verification"
**Cause**: Backend server not running or unreachable
**Solution**:
- Start backend server with `npm run dev`
- Check that port 5001 is not blocked by firewall

### Issue: "Invalid Firebase token"
**Cause**: Token expired or malformed
**Solution**: 
- Ensure Firebase authentication is working
- Check Firebase project configuration

## Verification Checklist

- [ ] Backend server running on port 5001
- [ ] MongoDB connection successful
- [ ] Flutter app configured for local API
- [ ] User can sign in with Google
- [ ] Logs show successful MongoDB sync
- [ ] User data appears in MongoDB Atlas

## Reset Database for Testing

If you need to start fresh:

```bash
cd backend
npm run db:cleanup
```

This will remove all data and allow you to test the sync process from scratch.

## Next Steps

Once you've verified the sync is working:

1. You can switch back to live API if needed by setting `useLiveApi = true`
2. Test with multiple users to ensure each user gets their own MongoDB document
3. Test step syncing and reward redemption functionality