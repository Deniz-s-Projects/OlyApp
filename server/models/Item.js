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
  notice: {
    _id: false,
    text: String,
    severity: {
      type: String,
      enum: ['info', 'warning', 'critical']
    }
  },
  createdAt: { type: Date, default: Date.now },
  requested: { type: Boolean, default: false },
  completed: { type: Boolean, default: false },
  ratings: [
    {
      rating: { type: Number, required: true },
      review: String
    }
  ]
});

module.exports = mongoose.model('Item', ItemSchema);
