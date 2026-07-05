const express = require('express');
const BillService = require('../models/BillService');
const Subscription = require('../models/Subscription');
const Transaction = require('../models/Transaction');
const User = require('../models/User');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();

// ─── GET /api/services/bills ──────────────────────────────
router.get('/bills', authMiddleware, async (req, res) => {
  try {
    const bills = await BillService.find();
    res.json({ success: true, data: bills });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// ─── POST /api/services/pay-bill ──────────────────────────
router.post('/pay-bill', authMiddleware, async (req, res) => {
  try {
    const { billServiceId, amount, referenceNumber } = req.body;
    
    const user = await User.findById(req.user.id);
    if (user.walletBalance < amount) {
      return res.status(400).json({ success: false, message: 'Insufficient balance' });
    }

    user.walletBalance -= amount;
    await user.save();

    const transaction = await Transaction.create({
      userId: req.user.id,
      type: 'expense',
      amount,
      description: `Bill Payment to service ${billServiceId} for ${referenceNumber}`,
      status: 'completed',
      reference: `BILL-${Date.now()}`
    });

    res.json({ success: true, message: 'Bill paid successfully', data: transaction });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
