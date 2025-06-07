const mongoose = require('mongoose');

const EmergencyContactSchema = new mongoose.Schema({
  name: { type: String, required: true },
  phone: { type: String, required: true },
  description: String,
});

module.exports = mongoose.model('EmergencyContact', EmergencyContactSchema);
