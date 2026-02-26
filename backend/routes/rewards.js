const express = require('express');
const router = express.Router();
const Reward = require('../models/Reward');

// GET /api/rewards
router.get('/', async (req, res) => {
  try {
    // Return mock rewards for testing since DB is not connected
    const mockRewards = [
      {
        _id: "1",
        name: "Water Bottle",
        cost: 50,
        description: "Stay hydrated with this eco-friendly water bottle",
        imageUrl: "https://example.com/water-bottle.jpg",
        stock: 100,
        active: true,
        createdAt: new Date().toISOString()
      },
      {
        _id: "2", 
        name: "T-Shirt",
        cost: 100,
        description: "Comfortable cotton t-shirt with Sweatcoin logo",
        imageUrl: "https://example.com/tshirt.jpg",
        stock: 50,
        active: true,
        createdAt: new Date().toISOString()
      },
      {
        _id: "3",
        name: "Headphones",
        cost: 200,
        description: "Wireless bluetooth headphones",
        imageUrl: "https://example.com/headphones.jpg",
        stock: 25,
        active: true,
        createdAt: new Date().toISOString()
      }
    ];

    res.json({
      success: true,
      data: mockRewards
    });

  } catch (error) {
    console.error('List rewards error:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error'
    });
  }
});

// POST /api/redeem-reward
router.post('/redeem', async (req, res) => {
  try {
    const { userId, rewardId, shippingAddress } = req.body;

    // Input validation
    if (!userId || !rewardId || !shippingAddress) {
      return res.status(400).json({
        success: false,
        error: 'Missing required fields: userId, rewardId, shippingAddress'
      });
    }

    // Check if user exists
    const User = require('../models/User');
    const user = await User.findOne({ uid: userId });
    if (!user) {
      return res.status(404).json({
        success: false,
        error: 'User not found'
      });
    }

    // Check if reward exists and is active
    const reward = await Reward.findOne({ _id: rewardId, active: true });
    if (!reward) {
      return res.status(404).json({
        success: false,
        error: 'Reward not found or inactive'
      });
    }

    // Check stock
    if (reward.stock <= 0) {
      return res.status(400).json({
        success: false,
        error: 'Reward out of stock'
      });
    }

    // Check balance
    if (user.balance < reward.cost) {
      return res.status(400).json({
        success: false,
        error: 'Insufficient balance'
      });
    }

    // Create order
    const Order = require('../models/Order');
    const order = new Order({
      userId,
      rewardId,
      rewardName: reward.name,
      cost: reward.cost,
      shippingAddress
    });
    await order.save();

    // Update reward stock
    reward.stock -= 1;
    await reward.save();

    // Deduct coins from user
    user.balance -= reward.cost;
    await user.save();

    // Create wallet transaction
    const Wallet = require('../models/Wallet');
    const walletEntry = new Wallet({
      userId,
      type: 'spend',
      amount: -reward.cost,
      description: `Redeemed ${reward.name}`,
      referenceId: order._id.toString()
    });
    await walletEntry.save();

    res.json({
      success: true,
      orderId: order._id.toString(),
      message: 'Reward redeemed successfully'
    });

  } catch (error) {
    console.error('Redemption error:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error'
    });
  }
});

module.exports = router;