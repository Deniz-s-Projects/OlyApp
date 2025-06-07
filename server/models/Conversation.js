const mongoose = require('mongoose');

const ConversationSchema = new mongoose.Schema({
  participants: {
    type: [String],
    required: true
  },
  name: String,
  isGroup: {
    type: Boolean,
    default: false
  }
});

module.exports = mongoose.model('Conversation', ConversationSchema);
