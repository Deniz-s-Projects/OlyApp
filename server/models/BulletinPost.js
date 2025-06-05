const mongoose = require('mongoose');

const BulletinPostSchema = new mongoose.Schema({
  id: { type: Number, required: true, unique: true },
  userId: { type: Number, required: true },
  content: { type: String, required: true },
  date: { type: Date, default: Date.now },
});

module.exports = mongoose.model('BulletinPost', BulletinPostSchema);
