const mongoose = require('mongoose');

const BulletinCommentSchema = new mongoose.Schema({
  id: { type: Number, required: true, unique: true },
  postId: { type: Number, required: true },
  content: { type: String, required: true },
  date: { type: Date, default: Date.now },
});

module.exports = mongoose.model('BulletinComment', BulletinCommentSchema);
