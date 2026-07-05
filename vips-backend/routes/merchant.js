const express = require('express');
const { authMiddleware, requireRole } = require('../middleware/auth');
const User = require('../models/User');
const Transaction = require('../models/Transaction');

const router = express.Router();

// All merchant routes require authentication
router.use(authMiddleware);

// ─── GET /api/merchant/dashboard ──────────────────────────
router.get('/dashboard', async (req, res) => {
  try {
    const merchantId = req.user.id;

    // Get transactions summary
    const transactions = await Transaction.find({ merchantId });

    const totalSales = transactions
      .filter((t) => t.type === 'income' && t.status === 'completed')
      .reduce((sum, t) => sum + t.amount, 0);

    const totalExpenses = transactions
      .filter((t) => t.type === 'expense' && t.status === 'completed')
      .reduce((sum, t) => sum + t.amount, 0);

    const totalGiftBack = transactions
      .filter((t) => t.type === 'gift_back' && t.status === 'completed')
      .reduce((sum, t) => sum + t.amount, 0);

    const totalRewards = transactions
      .filter((t) => t.type === 'reward' && t.status === 'completed')
      .reduce((sum, t) => sum + t.amount, 0);

    const pendingTransactions = transactions.filter(
      (t) => t.status === 'pending'
    ).length;

    res.json({
      success: true,
      data: {
        totalSales,
        totalExpenses,
        totalGiftBack,
        totalRewards,
        pendingTransactions,
        netProfit: totalSales - totalExpenses,
        transactionCount: transactions.length,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

// ─── GET /api/merchant/transactions ───────────────────────
router.get('/transactions', async (req, res) => {
  try {
    const { type, status, page = 1, limit = 20 } = req.query;
    const merchantId = req.user.id;

    const filter = { merchantId };
    if (type) filter.type = type;
    if (status) filter.status = status;

    const transactions = await Transaction.find(filter)
      .sort({ createdAt: -1 })
      .skip((page - 1) * limit)
      .limit(parseInt(limit))
      .populate('userId', 'fullName email phone');

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

// ─── POST /api/merchant/transaction ───────────────────────
router.post('/transaction', async (req, res) => {
  try {
    const { userId, type, amount, currency, description } = req.body;

    const transaction = await Transaction.create({
      userId: userId || req.user.id,
      merchantId: req.user.id,
      type,
      amount,
      currency: currency || 'USD',
      description,
      status: 'completed',
      reference: `TXN-${Date.now()}`,
    });

    res.status(201).json({
      success: true,
      message: 'Transaction created successfully!',
      data: { transaction },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

// ─── GET /api/merchant/customers ──────────────────────────
router.get('/customers', async (req, res) => {
  try {
    // Get all unique customers who had transactions with this merchant
    const customerIds = await Transaction.distinct('userId', {
      merchantId: req.user.id,
    });

    const customers = await User.find({
      _id: { $in: customerIds },
    }).select('fullName email phone walletPoints createdAt');

    res.json({
      success: true,
      data: { customers, total: customers.length },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

// ─── GET /api/merchant/stats ──────────────────────────────
router.get('/stats', async (req, res) => {
  try {
    const merchantId = req.user.id;

    // Today's stats
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const todayTransactions = await Transaction.find({
      merchantId,
      createdAt: { $gte: today },
      status: 'completed',
    });

    const todaySales = todayTransactions
      .filter((t) => t.type === 'income')
      .reduce((sum, t) => sum + t.amount, 0);

    const todayExpenses = todayTransactions
      .filter((t) => t.type === 'expense')
      .reduce((sum, t) => sum + t.amount, 0);

    // This month's stats
    const monthStart = new Date(today.getFullYear(), today.getMonth(), 1);

    const monthTransactions = await Transaction.find({
      merchantId,
      createdAt: { $gte: monthStart },
      status: 'completed',
    });

    const monthlySales = monthTransactions
      .filter((t) => t.type === 'income')
      .reduce((sum, t) => sum + t.amount, 0);

    const monthlyExpenses = monthTransactions
      .filter((t) => t.type === 'expense')
      .reduce((sum, t) => sum + t.amount, 0);

    res.json({
      success: true,
      data: {
        today: {
          sales: todaySales,
          expenses: todayExpenses,
          net: todaySales - todayExpenses,
          transactionCount: todayTransactions.length,
        },
        month: {
          sales: monthlySales,
          expenses: monthlyExpenses,
          net: monthlySales - monthlyExpenses,
          transactionCount: monthTransactions.length,
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

module.exports = router;
