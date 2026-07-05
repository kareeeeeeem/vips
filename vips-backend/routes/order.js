const express = require('express');
const Order = require('../models/Order');
const Product = require('../models/Product');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();

// ─── POST /api/order/create ───────────────────────────────
router.post('/create', authMiddleware, async (req, res) => {
  try {
    const { merchantId, items, paymentMethod, deliveryAddress } = req.body;
    
    // Calculate total
    let totalAmount = 0;
    for (const item of items) {
      totalAmount += item.price * item.quantity;
    }

    const order = await Order.create({
      userId: req.user.id,
      merchantId,
      items,
      totalAmount,
      paymentMethod,
      deliveryAddress,
      status: 'pending',
    });

    res.status(201).json({ success: true, message: 'Order created', data: order });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// ─── GET /api/order/history ───────────────────────────────
router.get('/history', authMiddleware, async (req, res) => {
  try {
    const orders = await Order.find({ userId: req.user.id }).sort({ createdAt: -1 });
    res.json({ success: true, data: orders });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
