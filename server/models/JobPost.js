const mongoose = require('mongoose');

const JobPostSchema = new mongoose.Schema({
  ownerId: { type: String, required: true },
  title: { type: String, required: true },
  description: { type: String, required: true },
  pay: { type: String },
  contact: { type: String },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('JobPost', JobPostSchema);
