# Backend Logging Guide

## Overview

I've added comprehensive logging to your backend to help you see exactly what's happening when users interact with the API.

## What's Being Logged

### Server Level (server.js)
- Every incoming request with method, path, query params, and body
- Example: `📥 [SERVER] POST /api/auth/verify-token`

### Auth Routes (routes/auth.js)
- Request received and body content
- Firebase token verification process
- User creation/update in MongoDB
- JWT token generation
- Response sent to client

### MongoDB Operations (models/User.js)
- User lookup in database
- New user creation with all details
- User updates with changed fields
- Final user data returned

## How to Test

### Step 1: Start Backend with Logging
```bash
cd backend
npm run dev
```

### Step 2: Run Flutter App
```bash
cd flutter_app
flutter run
```

### Step 3: Sign In and Watch Logs
1. Open the Flutter app
2. Tap "Sign In with Google"
3. Complete authentication
4. Watch the backend terminal for detailed logs

## Expected Backend Log Output

When a user signs in, you should see logs like this:

```
📥 [SERVER] POST /api/auth/verify-token
📥 [SERVER] Query: {}
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

## What to Look For

### ✅ Success Indicators
- `✅ [BACKEND] Token verified for user: [UID]`
- `➕ [MONGODB] User not found, creating new user: [UID]`
- `✅ [MONGODB] New user created successfully: [UID]`
- `📤 [BACKEND] Sending response to client`

### ❌ Error Indicators
- `❌ [BACKEND] ID token is missing from request`
- `❌ [BACKEND] Invalid Firebase token detected`
- `❌ [BACKEND] Token verification error: [details]`

## Troubleshooting

### If You Don't See Backend Logs
1. Make sure backend server is running: `npm run dev`
2. Check that Flutter app is using local API (should be after our fix)
3. Verify the request is actually reaching the backend

### If You See 404 Errors
1. Check that the backend server is running on the correct port (5001)
2. Verify the Flutter app is configured for local API
3. Check the server logs for incoming requests

### If MongoDB Operations Fail
1. Verify MongoDB connection in `.env` file
2. Check MongoDB Atlas cluster status
3. Look for database connection errors in logs

## Next Steps

Once you see the logs working:
1. Verify users are being created in MongoDB Atlas
2. Check that the response is being sent back to the Flutter app
3. Confirm the Flutter app receives the success response

This logging will help you see exactly what's happening at every step of the authentication and sync process!