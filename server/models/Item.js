const mongoose = require('mongoose');

const ItemSchema = new mongoose.Schema({
  ownerId: { type: String, required: true },
  title: { type: String, required: true },
  description: String,
  imageUrl: String,
  price: Number,
  isFree: { type: Boolean, default: false },
  category: {
    type: String,
    enum: ['furniture', 'books', 'electronics', 'other', 'appliances', 'clothing'],
    default: 'other'
  },
  createdAt: { type: Date, default: Date.now },
  requested: { type: Boolean, default: false }
});

module.exports = mongoose.model('Item', ItemSchema);
