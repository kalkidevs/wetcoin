# Sweatcoin Backend - Authentication & MongoDB Integration

## Overview

This document provides a comprehensive guide to troubleshooting and optimizing the Google sign-in/signup functionality with Firebase Authentication and MongoDB Atlas integration.

## Issues Identified & Solutions Implemented

### 1. **Missing Backend Authentication Flow**

**Problem**: The Flutter app was only using Firebase Authentication without communicating with the backend to store user data in MongoDB.

**Solution**: 
- Created `/api/auth/verify-token` endpoint to verify Firebase ID tokens
- Implemented user creation/updates in MongoDB when users sign in
- Added JWT token generation for backend authentication

### 2. **Database Connection Issues**

**Problem**: MongoDB connection was not properly established, causing silent failures.

**Solution**:
- Fixed MongoDB connection string in `.env`
- Added proper error handling and logging
- Implemented connection retry logic
- Added database indexes for better performance

### 3. **User Data Persistence Problems**

**Problem**: User data was being stored in Firebase Firestore but not in MongoDB Atlas.

**Solution**:
- Created proper User model with all required fields
- Implemented `findOrCreate` static method for efficient user management
- Added pre-save middleware for automatic timestamp updates
- Integrated user creation with authentication flow

### 4. **Missing Error Handling & Logging**

**Problem**: Silent failures made debugging difficult.

**Solution**:
- Added comprehensive logging throughout the application
- Implemented proper error handling with meaningful messages
- Created centralized logging utility for Flutter app
- Added validation and sanitization for all inputs

## Architecture Changes

### Backend Structure

```
backend/
├── config/
│   └── database.js          # MongoDB connection with error handling
├── models/
│   └── User.js              # Enhanced User model with indexes
├── routes/
│   ├── auth.js              # NEW: Authentication endpoints
│   ├── sync.js              # Updated: User validation
│   ├── wallet.js
│   └── rewards.js
└── server.js                # Updated: Added auth routes
```

### New Authentication Flow

1. **Flutter App**: User signs in with Google
2. **Firebase**: Returns ID token
3. **Backend**: Verifies Firebase token using Firebase Admin SDK
4. **MongoDB**: Creates/updates user record
5. **Response**: Returns user data and JWT for backend auth

### API Endpoints

- `POST /api/auth/verify-token` - Verify Firebase token and create user
- `POST /api/auth/refresh-user` - Get updated user data
- `POST /api/sync` - Sync steps (now validates user exists)

## Security Improvements

### 1. **Token Validation**
- Firebase Admin SDK for server-side token verification
- Proper error handling for invalid tokens
- JWT generation for backend authentication

### 2. **Input Validation**
- Comprehensive validation for all API inputs
- Rate limiting to prevent abuse
- Device ID validation for security

### 3. **Database Security**
- Proper indexing for performance
- Data validation and sanitization
- Error handling for database operations

## MongoDB Schema

```javascript
{
  uid: String (unique, indexed),
  name: String,
  email: String (unique, indexed),
  photoUrl: String,
  balance: Number (default: 0),
  lifetimeSteps: Number (default: 0),
  lifetimeCoins: Number (default: 0),
  createdAt: Date,
  lastSync: Date,
  lastLoginAt: Date,
  isActive: Boolean (default: true)
}
```

## Environment Configuration

### Backend (.env)
```bash
# MongoDB Connection
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/database

# JWT Secret (CHANGE IN PRODUCTION)
JWT_SECRET=your_jwt_secret_key_here_change_this_in_production

# Server
PORT=5000
NODE_ENV=development
```

### Flutter (.env)
```bash
# Backend API URL
API_BASE_URL=https://your-backend-url.com

# Firebase Config
FIREBASE_API_KEY=your_api_key
FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
# ... other Firebase config
```

## Testing the Fix

### 1. **Backend Testing**
```bash
# Start backend
cd backend
npm install
npm run dev

# Test authentication endpoint
curl -X POST http://localhost:5001/api/auth/verify-token \
  -H "Content-Type: application/json" \
  -d '{"idToken": "your_firebase_id_token"}'
```

### 2. **Database Verification**
```javascript
// Check if users are being created
db.users.find().pretty()

// Check user count
db.users.countDocuments()
```

### 3. **Flutter App Testing**
1. Sign in with Google
2. Check console logs for authentication flow
3. Verify user data appears in MongoDB Atlas
4. Test step syncing functionality

## Monitoring & Debugging

### Backend Logs
- Token verification success/failure
- User creation/updates
- Database connection status
- API request/response logging

### Flutter Logs
- Authentication flow steps
- Network request/response
- Error handling
- Database operations

### MongoDB Atlas Monitoring
- Connection status
- Query performance
- User collection growth
- Error rates

## Performance Optimizations

### 1. **Database Indexes**
- Email and UID indexes for fast lookups
- CreatedAt index for time-based queries
- LastSync index for sync operations

### 2. **Connection Pooling**
- MongoDB connection reuse
- Proper connection management
- Error recovery mechanisms

### 3. **Caching**
- Consider adding Redis for session management
- Cache frequently accessed user data
- Implement rate limiting

## Troubleshooting Common Issues

### 1. **User Not Found in MongoDB**
- Check Firebase token verification
- Verify database connection
- Check for errors in auth flow

### 2. **Authentication Failures**
- Verify Firebase project configuration
- Check server client ID
- Ensure proper OAuth consent screen setup

### 3. **Database Connection Issues**
- Verify MongoDB Atlas connection string
- Check IP whitelist settings
- Ensure proper network access

### 4. **Step Sync Failures**
- Verify user exists in database
- Check rate limiting
- Validate input parameters

## Next Steps

1. **Production Deployment**
   - Set up proper environment variables
   - Configure SSL certificates
   - Implement monitoring and alerting

2. **Security Hardening**
   - Change JWT secret in production
   - Implement rate limiting
   - Add request validation middleware

3. **Performance Monitoring**
   - Set up application monitoring
   - Monitor database performance
   - Implement caching strategies

4. **Additional Features**
   - Email verification
   - Password reset functionality
   - Social media integration
   - Advanced analytics

## Support

For issues related to:
- Authentication flow: Check backend logs and Firebase configuration
- Database issues: Verify MongoDB Atlas connection and permissions
- Flutter integration: Check network requests and error handling
- Performance: Monitor database queries and connection pooling