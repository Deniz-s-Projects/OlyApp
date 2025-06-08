const mongoose = require('mongoose');

const NoiseReportSchema = new mongoose.Schema({
  reporterId: { type: String, required: true },
  location: { type: String, required: true },
  description: { type: String, required: true },
  timestamp: { type: Date, default: Date.now },
});

module.exports = mongoose.model('NoiseReport', NoiseReportSchema);
