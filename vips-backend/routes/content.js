const express = require('express');
const Deal = require('../models/Deal');
const Outing = require('../models/Outing');
const User = require('../models/User');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();

// ─── INIT MOCK DATA ─────────────────────────────────────────
async function seedContent() {
  try {
    const dealCount = await Deal.countDocuments();
    if (dealCount === 0) {
      await Deal.insertMany([
        { title: 'Dream Park', description: '29% off @Dream Park', image: 'https://images.unsplash.com/photo-1569973189506-82c9b96b8e30?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80', currentPrice: 265, originalPrice: 375, discount: 29, category: 'entertainment' },
        { title: 'El Demeshky', description: 'Syrian & Egyptian dishes', image: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80', currentPrice: 99, originalPrice: 150, discount: 37, category: 'food' },
        { title: 'Mega Pizza Deal', description: 'Large Pizza + 2 Sides', image: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80', currentPrice: 150, originalPrice: 300, discount: 50, category: 'food', endTime: new Date(Date.now() + 12 * 3600000) }
      ]);
    }

    const outingCount = await Outing.countDocuments();
    if (outingCount === 0) {
      await Outing.insertMany([
        { title: 'Mall Of Egypt Offers', subtitle: 'Shopping & Entertainment', image: 'https://images.unsplash.com/photo-1555529669-e69e7aa0ba9a?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80', category: 'Shopping', location: 'New Cairo', type: 'mall' },
        { title: 'Walk of Cairo', subtitle: 'Outdoor Shopping Experience', image: 'https://images.unsplash.com/photo-1508739773434-c26b3d09e071?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80', category: 'Outdoor', location: 'New Capital', type: 'outdoor' }
      ]);
    }
  } catch (e) {
    console.log('Seeding error:', e.message);
  }
}
seedContent();

// ─── GET /api/content/hot-deals ───────────────────────────
router.get('/hot-deals', authMiddleware, async (req, res) => {
  try {
    const deals = await Deal.find({ endTime: null }).sort({ createdAt: -1 });
    res.json({ success: true, data: deals });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// ─── GET /api/content/ending-soon-deals ───────────────────
router.get('/ending-soon-deals', authMiddleware, async (req, res) => {
  try {
    const deals = await Deal.find({ endTime: { $ne: null, $gt: new Date() } }).sort({ endTime: 1 });
    res.json({ success: true, data: deals });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// ─── GET /api/content/outings ─────────────────────────────
router.get('/outings', authMiddleware, async (req, res) => {
  try {
    const outings = await Outing.find().sort({ createdAt: -1 });
    res.json({ success: true, data: outings });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// ─── GET /api/content/trending-merchants ──────────────────
router.get('/trending-merchants', authMiddleware, async (req, res) => {
  try {
    const merchants = await User.find({ role: 'merchant', isTrending: true })
      .select('storeName storeCategory logo brandColor discountPercentage')
      .sort({ createdAt: -1 });
    res.json({ success: true, data: merchants });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
