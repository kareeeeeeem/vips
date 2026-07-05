const express = require('express');
const { authMiddleware } = require('../middleware/auth');
const User = require('../models/User');
const Transaction = require('../models/Transaction');
const Order = require('../models/Order');

const router = express.Router();

// All user routes require authentication
router.use(authMiddleware);

// ─── GET /api/user/wallet ─────────────────────────────────
router.get('/wallet', async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select(
      'walletBalance walletPoints'
    );

    const recentTransactions = await Transaction.find({
      userId: req.user.id,
    })
      .sort({ createdAt: -1 })
      .limit(10)
      .populate('merchantId', 'storeName fullName');

    res.json({
      success: true,
      data: {
        balance: user.walletBalance,
        points: user.walletPoints,
        recentTransactions,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

// ─── GET /api/user/notifications ─────────────────────────
router.get('/notifications', async (req, res) => {
  try {
    const userId = req.user.id;

    const recentOrders = await Order.find({ userId })
      .sort({ createdAt: -1 })
      .limit(3);

    const recentTransactions = await Transaction.find({ userId })
      .sort({ createdAt: -1 })
      .limit(3);

    const notifications = [];

    recentOrders.forEach((order) => {
      notifications.push({
        _id: order._id,
        title: `Order ${order._id.toString().slice(-6)} ${order.status}`,
        message: `Your order for D ${order.totalAmount.toFixed(3)} is now ${order.status}.`,
        time: order.updatedAt ? order.updatedAt.toLocaleString() : order.createdAt.toLocaleString(),
        type: order.status === 'delivered' ? 'account' : 'payment',
        isRead: order.status === 'delivered',
      });
    });

    recentTransactions.forEach((transaction) => {
      notifications.push({
        _id: transaction._id,
        title: transaction.type === 'credit' ? 'Wallet Credited' : 'Wallet Debited',
        message: transaction.description || `Your wallet was ${transaction.type} by D ${transaction.amount.toFixed(3)}.`,
        time: transaction.updatedAt ? transaction.updatedAt.toLocaleString() : transaction.createdAt.toLocaleString(),
        type: transaction.type === 'credit' ? 'payment' : 'account',
        isRead: transaction.status === 'completed',
      });
    });

    if (notifications.length === 0) {
      notifications.push({
        _id: 'welcome',
        title: 'Welcome to VIPs',
        message: 'Your account is ready. Explore new offers and start ordering today.',
        time: new Date().toLocaleString(),
        type: 'promotion',
        isRead: false,
      });
    }

    res.json({
      success: true,
      data: notifications,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

// ─── GET /api/user/transactions ───────────────────────────
router.get('/transactions', async (req, res) => {
  try {
    const { type, page = 1, limit = 20 } = req.query;

    const filter = { userId: req.user.id };
    if (type) filter.type = type;

    const transactions = await Transaction.find(filter)
      .sort({ createdAt: -1 })
      .skip((page - 1) * limit)
      .limit(parseInt(limit))
      .populate('merchantId', 'storeName fullName');

    const total = await Transaction.countDocuments(filter);

    res.json({
      success: true,
      data: {
        transactions,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total,
          pages: Math.ceil(total / limit),
        },
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

// ─── POST /api/user/transfer ──────────────────────────────
router.post('/transfer', async (req, res) => {
  try {
    const { recipientPhone, amount, description } = req.body;

    // Find recipient
    const recipient = await User.findOne({ phone: recipientPhone });
    if (!recipient) {
      return res.status(404).json({
        success: false,
        message: 'Recipient not found.',
      });
    }

    // Check balance
    const sender = await User.findById(req.user.id);
    if (sender.walletBalance < amount) {
      return res.status(400).json({
        success: false,
        message: 'Insufficient balance.',
      });
    }

    // Deduct from sender
    sender.walletBalance -= amount;
    await sender.save();

    // Add to recipient
    recipient.walletBalance += amount;
    await recipient.save();

    // Create transactions for both
    const reference = `TRF-${Date.now()}`;

    await Transaction.create({
      userId: sender._id,
      type: 'debit',
      amount,
      description: description || `Transfer to ${recipient.fullName}`,
      status: 'completed',
      reference,
    });

    await Transaction.create({
      userId: recipient._id,
      type: 'credit',
      amount,
      description: `Transfer from ${sender.fullName}`,
      status: 'completed',
      reference,
    });

    res.json({
      success: true,
      message: 'Transfer successful!',
      data: {
        newBalance: sender.walletBalance,
        reference,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

module.exports = router;
