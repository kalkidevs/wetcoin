const express = require('express');
const router = express.Router();
const Wallet = require('../models/Wallet');
const User = require('../models/User');

// GET /api/wallet/:userId
router.get('/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const limit = parseInt(req.query.limit) || 20;

    // Check if user exists
    const user = await User.findOne({ uid: userId });
    if (!user) {
      return res.status(404).json({
        success: false,
        error: 'User not found'
      });
    }

    // Get wallet transactions
    const transactions = await Wallet.find({ userId })
      .sort({ timestamp: -1 })
      .limit(limit)
      .lean();

    // Convert timestamps to ISO strings for easier client handling
    const formattedTransactions = transactions.map(transaction => ({
      ...transaction,
      timestamp: transaction.timestamp.toISOString()
    }));

    res.json({
      success: true,
      data: formattedTransactions,
      balance: user.balance
    });

  } catch (error) {
    console.error('Get wallet error:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error'
    });
  }
});

module.exports = router;