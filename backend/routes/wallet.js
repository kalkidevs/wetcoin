const express = require('express');
const router = express.Router();
const Wallet = require('../models/Wallet');
const User = require('../models/User');
const authMiddleware = require('../middleware/auth');

// GET /api/wallet/:userId — Get wallet balance + transaction history (protected)
router.get('/:userId', authMiddleware, async (req, res) => {
  try {
    const { userId } = req.params;
    const limit = parseInt(req.query.limit) || 20;
    const skip = parseInt(req.query.skip) || 0;

    // Verify the authenticated user matches
    if (req.user.userId !== userId) {
      return res.status(403).json({
        success: false,
        error: 'You can only view your own wallet'
      });
    }

    // Check if user exists
    const user = await User.findOne({ uid: userId });
    if (!user) {
      return res.status(404).json({
        success: false,
        error: 'User not found'
      });
    }

    // Get wallet transactions with pagination
    const transactions = await Wallet.find({ userId })
      .sort({ timestamp: -1 })
      .skip(skip)
      .limit(limit)
      .lean();

    // Get total count for pagination info
    const totalCount = await Wallet.countDocuments({ userId });

    // Format timestamps
    const formattedTransactions = transactions.map(transaction => ({
      id: transaction._id.toString(),
      type: transaction.type,
      amount: transaction.amount,
      description: transaction.description,
      referenceId: transaction.referenceId || null,
      timestamp: transaction.timestamp.toISOString()
    }));

    res.json({
      success: true,
      data: formattedTransactions,
      balance: user.balance,
      lifetimeCoins: user.lifetimeCoins,
      lifetimeSteps: user.lifetimeSteps,
      pagination: {
        total: totalCount,
        limit,
        skip,
        hasMore: skip + limit < totalCount
      }
    });

  } catch (error) {
    console.error('❌ [WALLET] Get wallet error:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error'
    });
  }
});

module.exports = router;