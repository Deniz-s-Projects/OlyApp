const mongoose = require('mongoose');

const PollSchema = new mongoose.Schema({
  question: { type: String, required: true },
  options: { type: [String], required: true },
}, { timestamps: true });

module.exports = mongoose.model('Poll', PollSchema);
