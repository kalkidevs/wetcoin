const express = require('express');
const router = express.Router();
const Step = require('../models/Step');
const User = require('../models/User');
const Wallet = require('../models/Wallet');

// Constants
const STEPS_PER_COIN = 100;
const MAX_EARNABLE_STEPS = 15000; // 150 coins max
const MAX_TOTAL_STEPS = 30000; // Hard limit for sanity check
const MAX_BACKDATE_HOURS = 48;
const MIN_SYNC_INTERVAL_MILLIS = 5 * 60 * 1000; // 5 minutes
const MAX_REQUEST_AGE_MILLIS = 5 * 60 * 1000; // 5 minutes

// POST /api/sync-steps
router.post('/', async (req, res) => {
  try {
    const { userId, steps, date, deviceId, requestTimestamp } = req.body;

    // Input validation
    if (!userId || typeof steps !== 'number' || !date || !deviceId || !requestTimestamp) {
      return res.status(400).json({
        success: false,
        error: 'Missing required fields: userId, steps, date, deviceId, requestTimestamp'
      });
    }

    // Device ID validation
    if (deviceId.length < 5 || deviceId.length > 100) {
      return res.status(400).json({
        success: false,
        error: 'Invalid Device ID format'
      });
    }

    // Timestamp validation (prevent replay attacks)
    const requestTime = requestTimestamp;
    const serverTime = Date.now();
    if (Math.abs(serverTime - requestTime) > MAX_REQUEST_AGE_MILLIS) {
      // For testing, allow a wider range
      if (process.env.NODE_ENV !== 'production') {
        console.log('Warning: Request timestamp validation bypassed for testing');
      } else {
        return res.status(400).json({
          success: false,
          error: 'Request timestamp too old or in future'
        });
      }
    }

    // Sanity check (prevent unrealistic step counts)
    if (steps > MAX_TOTAL_STEPS) {
      return res.status(400).json({
        success: false,
        error: `Steps cannot exceed ${MAX_TOTAL_STEPS} in a single day`
      });
    }

    // Date validation
    const stepDate = new Date(date);
    const now = new Date();
    const diffHours = (now.getTime() - stepDate.getTime()) / (1000 * 60 * 60);

    if (isNaN(stepDate.getTime())) {
      return res.status(400).json({
        success: false,
        error: 'Invalid date format'
      });
    }

    if (diffHours > MAX_BACKDATE_HOURS) {
      return res.status(400).json({
        success: false,
        error: 'Cannot sync steps older than 48 hours'
      });
    }

    // Prevent future dates
    if (stepDate.getTime() > now.getTime() + 600000) {
      return res.status(400).json({
        success: false,
        error: 'Cannot sync future steps'
      });
    }

    // Check if user exists in MongoDB
    const user = await User.findOne({ uid: userId });
    
    if (!user) {
      return res.status(404).json({
        success: false,
        error: 'User not found. Please sign in first.'
      });
    }

    // Rate limiting check
    const lastSyncTime = user.lastSync?.getTime() || 0;
    if (Date.now() - lastSyncTime < MIN_SYNC_INTERVAL_MILLIS) {
      return res.status(429).json({
        success: false,
        error: 'Syncing too frequently. Please wait.'
      });
    }

    // Check if we already have data for this date (skip database check for now)
    // In production, this would check the database
    let existingSteps = 0;
    let existingEarnedSteps = 0;

    // Reject duplicate sync (idempotency)
    if (steps <= existingSteps) {
      return res.json({
        success: true,
        balance: user.balance,
        earned: 0,
        stepsSaved: existingSteps,
        message: 'Duplicate or older data ignored'
      });
    }

    // Calculate delta and coins earned
    const stepsToReward = Math.min(steps, MAX_EARNABLE_STEPS);
    const newEarnedSteps = Math.max(0, stepsToReward - existingEarnedSteps);
    const coinsEarned = newEarnedSteps / STEPS_PER_COIN;

    // Update or create step record
    const stepData = {
      userId,
      date,
      steps,
      earnedSteps: stepsToReward,
      deviceId,
      lastSync: new Date()
    };

    // Update user balance and lifetime stats
    if (coinsEarned > 0) {
      user.balance += coinsEarned;
      user.lifetimeCoins += coinsEarned;
    }

    user.lifetimeSteps += (steps - existingSteps);
    user.lastSync = new Date();

    // Save user updates to MongoDB
    await user.save();

    res.json({
      success: true,
      balance: user.balance,
      earned: coinsEarned,
      stepsSaved: steps
    });

  } catch (error) {
    console.error('Sync error:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error'
    });
  }
});

module.exports = router;