const mongoose = require('mongoose');

const MessageSchema = new mongoose.Schema({
  conversationId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Conversation'
  },
  requestType: {
    type: String,
    enum: ['Item', 'MaintenanceRequest']
  },
  requestId: {
    type: mongoose.Schema.Types.ObjectId,
    refPath: 'requestType'
  },
  senderId: { type: String, required: true },
  content: { type: String, required: true },
  timestamp: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Message', MessageSchema);
