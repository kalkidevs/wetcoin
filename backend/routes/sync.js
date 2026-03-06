const express = require('express');
const router = express.Router();
const Step = require('../models/Step');
const User = require('../models/User');
const Wallet = require('../models/Wallet');
const authMiddleware = require('../middleware/auth');

// Constants
const STEPS_PER_COIN = 100;
const MAX_EARNABLE_STEPS = 15000; // 150 coins max per day
const MAX_TOTAL_STEPS = 30000;    // Hard limit for sanity check
const MAX_BACKDATE_HOURS = 48;
const MIN_SYNC_INTERVAL_MILLIS = 5 * 60 * 1000; // 5 minutes
const MAX_REQUEST_AGE_MILLIS = 5 * 60 * 1000;    // 5 minutes

// POST /api/sync — Sync step data (protected)
router.post('/', authMiddleware, async (req, res) => {
  try {
    const { userId, steps, date, deviceId, requestTimestamp } = req.body;

    // Input validation
    if (!userId || typeof steps !== 'number' || !date || !deviceId || !requestTimestamp) {
      return res.status(400).json({
        success: false,
        error: 'Missing required fields: userId, steps, date, deviceId, requestTimestamp'
      });
    }

    // Verify the authenticated user matches the userId in the request
    if (req.user.userId !== userId) {
      return res.status(403).json({
        success: false,
        error: 'You can only sync steps for your own account'
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
      if (process.env.NODE_ENV === 'production') {
        return res.status(400).json({
          success: false,
          error: 'Request timestamp too old or in future'
        });
      }
      console.log('⚠️  [SYNC] Request timestamp validation bypassed (dev mode)');
    }

    // Sanity check (prevent unrealistic step counts)
    if (steps > MAX_TOTAL_STEPS) {
      return res.status(400).json({
        success: false,
        error: `Steps cannot exceed ${MAX_TOTAL_STEPS} in a single day`
      });
    }

    if (steps < 0) {
      return res.status(400).json({
        success: false,
        error: 'Steps cannot be negative'
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
        error: 'Syncing too frequently. Please wait a few minutes.'
      });
    }

    // ── Query existing Step record for this (userId, date) pair ──
    const existingStep = await Step.findOne({ userId, date });
    const existingSteps = existingStep?.steps || 0;
    const existingEarnedSteps = existingStep?.earnedSteps || 0;

    // Reject duplicate / older data (idempotency)
    if (steps <= existingSteps) {
      console.log(`ℹ️  [SYNC] Duplicate/older data ignored for ${userId} on ${date}`);
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
    const coinsEarned = Math.floor(newEarnedSteps / STEPS_PER_COIN);

    // ── Upsert Step record in MongoDB ──
    await Step.findOneAndUpdate(
      { userId, date },
      {
        $set: {
          steps,
          earnedSteps: stepsToReward,
          deviceId,
          lastSync: new Date()
        }
      },
      { upsert: true, new: true }
    );
    console.log(`✅ [SYNC] Step record saved: ${userId} | ${date} | ${steps} steps`);

    // Update user balance and lifetime stats
    const stepsDelta = steps - existingSteps;
    if (coinsEarned > 0) {
      user.balance += coinsEarned;
      user.lifetimeCoins += coinsEarned;
    }
    user.lifetimeSteps += stepsDelta;
    user.lastSync = new Date();
    await user.save();
    console.log(`✅ [SYNC] User updated: balance=${user.balance}, lifetimeSteps=${user.lifetimeSteps}`);

    // ── Create wallet "earn" transaction ──
    if (coinsEarned > 0) {
      const walletEntry = new Wallet({
        userId,
        type: 'earn',
        amount: coinsEarned,
        description: `Earned ${coinsEarned} coins for ${stepsDelta} steps`,
        referenceId: `sync_${date}_${Date.now()}`
      });
      await walletEntry.save();
      console.log(`✅ [SYNC] Wallet earn entry created: +${coinsEarned} coins`);
    }

    res.json({
      success: true,
      balance: user.balance,
      earned: coinsEarned,
      stepsSaved: steps,
      lifetimeSteps: user.lifetimeSteps,
      lifetimeCoins: user.lifetimeCoins
    });

  } catch (error) {
    console.error('❌ [SYNC] Sync error:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error'
    });
  }
});

module.exports = router;