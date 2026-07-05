const express = require('express');
const Coupon = require('../models/Coupon');
const GiftVoucher = require('../models/GiftVoucher');
const User = require('../models/User');
const Transaction = require('../models/Transaction');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();

// ─── GET /api/rewards/coupons ─────────────────────────
router.get('/coupons', authMiddleware, async (req, res) => {
  try {
    const coupons = await Coupon.find();
    res.json({ success: true, data: coupons });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// ─── POST /api/rewards/expense-to-reward ───────────────────────
router.post('/expense-to-reward', authMiddleware, async (req, res) => {
  try {
    const { amount, merchantId } = req.body;
    
    if (!amount || amount <= 0) {
      return res.status(400).json({ success: false, message: 'Invalid amount' });
    }

    // Give 10% of expense as reward points
    const pointsEarned = Math.floor(amount * 0.1);

    const user = await User.findById(req.user.id);
    user.walletPoints += pointsEarned;
    await user.save();

    await Transaction.create({
      userId: user._id,
      merchantId: merchantId || user._id, // fallback if merchant ID not found
      type: 'reward',
      amount: pointsEarned,
      currency: 'PTS',
      description: `Reward for expense of ${amount}`,
      status: 'completed',
      reference: `EXP-REW-${Date.now()}`
    });

    res.json({
      success: true,
      message: 'Expense successfully converted to rewards!',
      data: { pointsEarned, newBalance: user.walletPoints }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// ─── POST /api/rewards/apply-coupon ───────────────────────
router.post('/apply-coupon', authMiddleware, async (req, res) => {
  try {
    const { code } = req.body;
    
    const coupon = await Coupon.findOne({ code, isActive: true });
    if (!coupon) {
      return res.status(404).json({ success: false, message: 'Invalid or expired coupon' });
    }

    if (new Date() > coupon.expiryDate) {
      return res.status(400).json({ success: false, message: 'Coupon expired' });
    }

    res.json({ success: true, message: 'Coupon applied', data: coupon });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// ─── GET /api/rewards/gift-vouchers ─────────────────────────
router.get('/gift-vouchers', authMiddleware, async (req, res) => {
  try {
    const vouchers = [
      {
        id: '1',
        name: 'Carrefour',
        logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2d/Carrefour_Logo.svg/2560px-Carrefour_Logo.svg.png',
        minAmount: 200,
        maxAmount: 5000,
        currency: 'TN',
      },
      {
        id: '2',
        name: '2B',
        logoUrl: 'https://play-lh.googleusercontent.com/gS8DlSY7k-D6mRAHU3C3A8c0Gqg-JdP1Moz1mHMUxYg0tdpJ7HHSZSWrczk6SgcQG0Y',
        minAmount: 500,
        maxAmount: 20000,
        currency: 'TN',
      },
      {
        id: '3',
        name: 'FiT&F',
        logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8f/Fit_%26_F_logo.svg/2048px-Fit_%26_F_logo.svg.png',
        minAmount: 200,
        maxAmount: 1000,
        currency: 'TN',
      },
    ];
    res.json({ success: true, data: vouchers });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// ─── POST /api/rewards/send-gift ──────────────────────────
router.post('/send-gift', authMiddleware, async (req, res) => {
  try {
    const { recipientPhone, amount, message } = req.body;
    
    const sender = await User.findById(req.user.id);
    if (sender.walletBalance < amount) {
      return res.status(400).json({ success: false, message: 'Insufficient balance' });
    }

    // Deduct from sender
    sender.walletBalance -= amount;
    await sender.save();

    const code = 'GIFT-' + Math.random().toString(36).substr(2, 8).toUpperCase();

    const gift = await GiftVoucher.create({
      senderId: req.user.id,
      recipientPhone,
      amount,
      message,
      code
    });

    res.status(201).json({ success: true, message: 'Gift sent', data: gift });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// ─── POST /api/rewards/spin-wheel ─────────────────────────
router.post('/spin-wheel', authMiddleware, async (req, res) => {
  try {
    // Match flutter spin wheel values
    const rewards = [
      { type: 'points', amount: 100 },
      { type: 'points', amount: 200 },
      { type: 'points', amount: 50 },
      { type: 'points', amount: 500 },
      { type: 'points', amount: 150 },
      { type: 'points', amount: 300 },
      { type: 'points', amount: 75 },
      { type: 'points', amount: 1000 },
    ];
    
    const randomReward = rewards[Math.floor(Math.random() * rewards.length)];

    if (randomReward.type === 'points') {
      const user = await User.findById(req.user.id);
      user.walletBalance = (user.walletBalance || 0) + randomReward.amount;
      await user.save();
    }

    res.json({ success: true, message: 'Wheel spun', data: randomReward });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
