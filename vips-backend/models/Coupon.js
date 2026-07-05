const mongoose = require('mongoose');

const couponSchema = new mongoose.Schema(
  {
    code: { type: String, required: true, unique: true },
    discountPercentage: { type: Number, required: true },
    maxDiscountAmount: { type: Number, default: null },
    expiryDate: { type: Date, required: true },
    isActive: { type: Boolean, default: true },
    merchantId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', default: null }, // Null means global coupon
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('Coupon', couponSchema);
