const mongoose = require('mongoose');

const MessageSchema = new mongoose.Schema({
  requestType: {
    type: String,
    required: true,
    enum: ['Item', 'MaintenanceRequest']
  },
  requestId: {
    type: mongoose.Schema.Types.ObjectId,
    refPath: 'requestType',
    required: true
  },
  senderId: { type: Number, required: true },
  content: { type: String, required: true },
  timestamp: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Message', MessageSchema);
