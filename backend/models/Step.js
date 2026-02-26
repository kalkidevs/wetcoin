const mongoose = require('mongoose');

const stepSchema = new mongoose.Schema({
  userId: {
    type: String,
    required: true,
    ref: 'User'
  },
  date: {
    type: String,
    required: true,
    index: true
  },
  steps: {
    type: Number,
    required: true,
    min: 0
  },
  earnedSteps: {
    type: Number,
    default: 0,
    min: 0
  },
  deviceId: {
    type: String,
    required: true
  },
  lastSync: {
    type: Date,
    default: Date.now
  }
});

// Compound index for efficient querying
stepSchema.index({ userId: 1, date: 1 }, { unique: true });

module.exports = mongoose.model('Step', stepSchema);