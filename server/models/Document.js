const mongoose = require('mongoose');

const DocumentSchema = new mongoose.Schema({
  uploaderId: { type: String, required: true },
  fileName: { type: String, required: true },
  url: { type: String, required: true },
}, { timestamps: true });

module.exports = mongoose.model('Document', DocumentSchema);
