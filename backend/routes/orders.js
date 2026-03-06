const express = require('express');
const router = express.Router();
const Order = require('../models/Order');
const User = require('../models/User');
const authMiddleware = require('../middleware/auth');

// GET /api/orders/:userId — Get user's order history (protected)
router.get('/:userId', authMiddleware, async (req, res) => {
    try {
        const { userId } = req.params;
        const limit = parseInt(req.query.limit) || 20;
        const skip = parseInt(req.query.skip) || 0;
        const status = req.query.status; // optional filter

        // Verify the authenticated user matches
        if (req.user.userId !== userId) {
            return res.status(403).json({
                success: false,
                error: 'You can only view your own orders'
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

        // Build query
        const query = { userId };
        if (status) {
            query.status = status;
        }

        // Get orders with pagination
        const orders = await Order.find(query)
            .sort({ createdAt: -1 })
            .skip(skip)
            .limit(limit)
            .lean();

        const totalCount = await Order.countDocuments(query);

        const formattedOrders = orders.map(order => ({
            id: order._id.toString(),
            rewardId: order.rewardId,
            rewardName: order.rewardName,
            cost: order.cost,
            shippingAddress: order.shippingAddress,
            status: order.status,
            createdAt: order.createdAt.toISOString()
        }));

        res.json({
            success: true,
            data: formattedOrders,
            pagination: {
                total: totalCount,
                limit,
                skip,
                hasMore: skip + limit < totalCount
            }
        });

    } catch (error) {
        console.error('❌ [ORDERS] Get orders error:', error);
        res.status(500).json({
            success: false,
            error: 'Internal server error'
        });
    }
});

module.exports = router;
