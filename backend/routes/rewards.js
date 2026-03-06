const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');
const Reward = require('../models/Reward');
const User = require('../models/User');
const Order = require('../models/Order');
const Wallet = require('../models/Wallet');
const authMiddleware = require('../middleware/auth');

// GET /api/rewards — List active rewards (public)
router.get('/', async (req, res) => {
  try {
    const rewards = await Reward.find({ active: true })
      .sort({ cost: 1 })
      .lean();

    // If no rewards in DB yet, return helpful message
    if (rewards.length === 0) {
      return res.json({
        success: true,
        data: [],
        message: 'No rewards available. Run "npm run db:seed" to populate rewards.'
      });
    }

    res.json({
      success: true,
      data: rewards
    });

  } catch (error) {
    console.error('❌ [REWARDS] List rewards error:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error'
    });
  }
});

// POST /api/rewards/redeem — Redeem a reward (protected, atomic)
router.post('/redeem', authMiddleware, async (req, res) => {
  // Use a MongoDB transaction for atomicity
  const session = await mongoose.startSession();

  try {
    const { userId, rewardId, shippingAddress } = req.body;

    // Input validation
    if (!userId || !rewardId || !shippingAddress) {
      return res.status(400).json({
        success: false,
        error: 'Missing required fields: userId, rewardId, shippingAddress'
      });
    }

    // Verify the authenticated user matches
    if (req.user.userId !== userId) {
      return res.status(403).json({
        success: false,
        error: 'You can only redeem rewards for your own account'
      });
    }

    if (shippingAddress.trim().length < 10) {
      return res.status(400).json({
        success: false,
        error: 'Shipping address must be at least 10 characters'
      });
    }

    let result;

    await session.withTransaction(async () => {
      // Check user exists and has sufficient balance
      const user = await User.findOne({ uid: userId }).session(session);
      if (!user) {
        throw { statusCode: 404, message: 'User not found' };
      }

      // Check reward exists and is active
      const reward = await Reward.findOne({ _id: rewardId, active: true }).session(session);
      if (!reward) {
        throw { statusCode: 404, message: 'Reward not found or inactive' };
      }

      // Check stock
      if (reward.stock <= 0) {
        throw { statusCode: 400, message: 'Reward out of stock' };
      }

      // Check balance
      if (user.balance < reward.cost) {
        throw { statusCode: 400, message: `Insufficient balance. Need ${reward.cost} coins, have ${user.balance}` };
      }

      // ── All checks passed — execute atomically ──

      // 1. Deduct user balance
      user.balance -= reward.cost;
      await user.save({ session });

      // 2. Decrement reward stock
      reward.stock -= 1;
      await reward.save({ session });

      // 3. Create order
      const order = new Order({
        userId,
        rewardId,
        rewardName: reward.name,
        cost: reward.cost,
        shippingAddress: shippingAddress.trim(),
        status: 'pending'
      });
      await order.save({ session });

      // 4. Create wallet "spend" entry
      const walletEntry = new Wallet({
        userId,
        type: 'spend',
        amount: -reward.cost,
        description: `Redeemed: ${reward.name}`,
        referenceId: order._id.toString()
      });
      await walletEntry.save({ session });

      console.log(`✅ [REWARDS] Redemption complete: ${userId} redeemed "${reward.name}" for ${reward.cost} coins`);

      result = {
        success: true,
        orderId: order._id.toString(),
        newBalance: user.balance,
        message: `Successfully redeemed "${reward.name}"`
      };
    });

    res.json(result);

  } catch (error) {
    // Handle our custom validation errors
    if (error.statusCode) {
      return res.status(error.statusCode).json({
        success: false,
        error: error.message
      });
    }

    console.error('❌ [REWARDS] Redemption error:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error during redemption'
    });
  } finally {
    session.endSession();
  }
});

module.exports = router;