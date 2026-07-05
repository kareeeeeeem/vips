const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema(
  {
    fullName: {
      type: String,
      required: true,
      trim: true,
    },
    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
    },
    phone: {
      type: String,
      required: true,
      unique: true,
    },
    password: {
      type: String,
      required: true,
      minlength: 6,
    },
    role: {
      type: String,
      enum: ['customer', 'merchant', 'agent', 'admin'],
      default: 'customer',
    },
    // Merchant-specific fields
    storeName: { type: String, default: null },
    storeAddress: { type: String, default: null },
    storeCategory: { type: String, default: null },
    logo: { type: String, default: null },
    brandColor: { type: String, default: null }, // e.g., '0xFFDC2626'
    isTrending: { type: Boolean, default: false },
    discountPercentage: { type: Number, default: 0 },
    
    // Wallet
    walletBalance: { type: Number, default: 0 },
    walletPoints: { type: Number, default: 0 },

    // Profile
    profileImage: { type: String, default: null },
    isVerified: { type: Boolean, default: false },
    isActive: { type: Boolean, default: true },

    // Password Reset (OTP)
    resetPasswordToken: { type: String, default: null },
    resetPasswordExpires: { type: Date, default: null },
  },
  {
    timestamps: true, // createdAt, updatedAt
  }
);

// Hash password before saving
userSchema.pre('save', async function (next) {
  if (!this.isModified('password')) return next();
  this.password = await bcrypt.hash(this.password, 12);
  next();
});

// Compare password method
userSchema.methods.comparePassword = async function (candidatePassword) {
  return bcrypt.compare(candidatePassword, this.password);
};

// Remove password from JSON output
userSchema.methods.toJSON = function () {
  const obj = this.toObject();
  delete obj.password;
  return obj;
};

module.exports = mongoose.model('User', userSchema);
