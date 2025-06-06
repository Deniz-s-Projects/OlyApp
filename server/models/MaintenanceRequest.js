const mongoose = require('mongoose');

const MaintenanceRequestSchema = new mongoose.Schema({
  userId: { type: String, required: true },
  subject: { type: String, required: true },
  description: { type: String, required: true },
  createdAt: { type: Date, default: Date.now },
  status: { type: String, default: 'open' },
  imageUrl: String
});

module.exports = mongoose.model('MaintenanceRequest', MaintenanceRequestSchema);
