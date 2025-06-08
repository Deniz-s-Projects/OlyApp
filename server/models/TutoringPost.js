const mongoose = require('mongoose');

const TutoringPostSchema = new mongoose.Schema({
  userId: { type: String, required: true },
  subject: { type: String, required: true },
  description: { type: String, required: true },
  isOffering: { type: Boolean, required: true },
  contactUserId: { type: String, required: true },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('TutoringPost', TutoringPostSchema);
