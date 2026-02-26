const express = require('express');
const router = express.Router();
const User = require('../models/User');
const jwt = require('jsonwebtoken');
const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
if (!admin.apps.length) {
  try {
    admin.initializeApp({
      credential: admin.credential.applicationDefault()
    });
    console.log('Firebase Admin initialized successfully');
  } catch (error) {
    console.error('Firebase Admin initialization failed:', error);
  }
}

// Constants
const JWT_SECRET = process.env.JWT_SECRET || 'your_jwt_secret_key_here';

// POST /api/auth/verify-token
router.post('/verify-token', async (req, res) => {
  try {
    console.log('🔍 [BACKEND] Received verify-token request');
    console.log('🔍 [BACKEND] Request body:', JSON.stringify(req.body, null, 2));
    
    const { idToken } = req.body;

    if (!idToken) {
      console.log('❌ [BACKEND] ID token is missing from request');
      return res.status(400).json({
        success: false,
        error: 'ID token is required'
      });
    }

    console.log('✅ [BACKEND] ID token received, verifying with Firebase...');
    
    // Verify Firebase ID token
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    const { uid, email, name, picture } = decodedToken;

    console.log(`✅ [BACKEND] Token verified for user: ${uid}`);
    console.log(`✅ [BACKEND] User details: name=${name}, email=${email}, picture=${picture}`);

    // Use the new findOrCreate static method
    const userData = {
      name: name || 'User',
      email: email || '',
      photoUrl: picture || ''
    };
    
    console.log('🔄 [BACKEND] Creating/updating user in MongoDB...');
    const user = await User.findOrCreate(uid, userData);
    console.log(`✅ [BACKEND] User operation completed: ${user.uid}`);

    // Generate JWT for our backend
    const token = jwt.sign(
      { 
        userId: user.uid, 
        email: user.email,
        name: user.name 
      },
      JWT_SECRET,
      { expiresIn: '24h' }
    );

    console.log('✅ [BACKEND] JWT token generated successfully');

    const response = {
      success: true,
      user: {
        uid: user.uid,
        name: user.name,
        email: user.email,
        photoUrl: user.photoUrl,
        balance: user.balance,
        lifetimeSteps: user.lifetimeSteps,
        lifetimeCoins: user.lifetimeCoins
      },
      token
    };

    console.log('📤 [BACKEND] Sending response to client');
    console.log('📤 [BACKEND] Response:', JSON.stringify(response, null, 2));
    
    res.json(response);

  } catch (error) {
    console.error('❌ [BACKEND] Token verification error:', error);
    console.error('❌ [BACKEND] Error details:', {
      code: error.code,
      message: error.message,
      stack: error.stack
    });
    
    if (error.code === 'auth/invalid-token') {
      console.log('❌ [BACKEND] Invalid Firebase token detected');
      return res.status(401).json({
        success: false,
        error: 'Invalid Firebase token'
      });
    }

    console.log('❌ [BACKEND] Internal server error');
    res.status(500).json({
      success: false,
      error: 'Token verification failed',
      details: error.message
    });
  }
});

// POST /api/auth/refresh-user
router.post('/refresh-user', async (req, res) => {
  try {
    const { uid } = req.body;

    if (!uid) {
      return res.status(400).json({
        success: false,
        error: 'User ID is required'
      });
    }

    const user = await User.findOne({ uid });

    if (!user) {
      return res.status(404).json({
        success: false,
        error: 'User not found'
      });
    }

    res.json({
      success: true,
      user: {
        uid: user.uid,
        name: user.name,
        email: user.email,
        photoUrl: user.photoUrl,
        balance: user.balance,
        lifetimeSteps: user.lifetimeSteps,
        lifetimeCoins: user.lifetimeCoins,
        lastSync: user.lastSync
      }
    });

  } catch (error) {
    console.error('User refresh error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to refresh user data'
    });
  }
});

module.exports = router;