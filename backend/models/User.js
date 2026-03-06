const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  uid: {
    type: String,
    required: true,
    unique: true,
    index: true
  },
  name: {
    type: String,
    required: true,
    trim: true
  },
  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
    trim: true
  },
  photoUrl: {
    type: String,
    default: ''
  },
  phoneNumber: {
    type: String,
    required: false
  },
  balance: {
    type: Number,
    default: 0,
    min: 0
  },
  lifetimeSteps: {
    type: Number,
    default: 0,
    min: 0
  },
  lifetimeCoins: {
    type: Number,
    default: 0,
    min: 0
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  lastSync: {
    type: Date
  },
  lastLoginAt: {
    type: Date
  },
  isActive: {
    type: Boolean,
    default: true
  }
});

// Index for better query performance
userSchema.index({ email: 1 });
userSchema.index({ createdAt: 1 });
userSchema.index({ lastSync: 1 });

// Pre-save middleware to update lastLoginAt
userSchema.pre('save', function(next) {
  if (this.isModified('lastLoginAt') || this.isNew) {
    this.lastLoginAt = new Date();
  }
  next();
});

// Static method to find or create user
userSchema.statics.findOrCreate = async function(uid, userData) {
  console.log(`🔄 [MONGODB] Finding user with UID: ${uid}`);
  
  let user = await this.findOne({ uid });
  
  if (!user) {
    console.log(`➕ [MONGODB] User not found, creating new user: ${uid}`);
    user = new this({
      uid,
      name: userData.name || 'User',
      email: userData.email || '',
      photoUrl: userData.photoUrl || '',
      balance: 0,
      lifetimeSteps: 0,
      lifetimeCoins: 0,
      createdAt: new Date(),
      lastLoginAt: new Date()
    });
    await user.save();
    console.log(`✅ [MONGODB] New user created successfully: ${uid}`);
    
    // After saving, refresh from database to ensure all data is synced
    user = await this.findOne({ uid });
    
    console.log(`✅ [MONGODB] User data:`, {
      uid: user.uid,
      name: user.name,
      email: user.email,
      balance: user.balance,
      lifetimeSteps: user.lifetimeSteps,
      lifetimeCoins: user.lifetimeCoins,
      createdAt: user.createdAt,
      lastLoginAt: user.lastLoginAt
    });
  } else {
    console.log(`🔄 [MONGODB] User found, checking for updates: ${uid}`);
    // Update user info if needed
    const updateData = {};
    if (userData.name && user.name !== userData.name) updateData.name = userData.name;
    if (userData.email && user.email !== userData.email) updateData.email = userData.email;
    if (userData.photoUrl && user.photoUrl !== userData.photoUrl) updateData.photoUrl = userData.photoUrl;
    
    if (Object.keys(updateData).length > 0) {
      console.log(`📝 [MONGODB] Updating user data:`, updateData);
      await this.updateOne({ uid }, { $set: updateData });
      
      // Refresh user from database after update
      user = await this.findOne({ uid });
      console.log(`✅ [MONGODB] User updated successfully: ${uid}`);
    } else {
      console.log(`ℹ️  [MONGODB] No updates needed for user: ${uid}`);
    }
  }
  
  console.log(`📤 [MONGODB] Returning user data:`, {
    uid: user.uid,
    name: user.name,
    email: user.email,
    balance: user.balance,
    lifetimeSteps: user.lifetimeSteps,
    lifetimeCoins: user.lifetimeCoins,
    createdAt: user.createdAt
  });
  
  return user;
};

module.exports = mongoose.model('User', userSchema);