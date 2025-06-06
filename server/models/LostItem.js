const mongoose = require('mongoose');

const LostItemSchema = new mongoose.Schema({
  ownerId: { type: String, required: true },
  title: { type: String, required: true },
  description: String,
  imageUrl: String,
  type: { type: String, enum: ['lost', 'found'], default: 'lost' },
  createdAt: { type: Date, default: Date.now },
  resolved: { type: Boolean, default: false }
});

module.exports = mongoose.model('LostItem', LostItemSchema);
