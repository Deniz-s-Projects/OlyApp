const mongoose = require('mongoose');

const GalleryImageSchema = new mongoose.Schema({
  uploaderId: { type: String, required: true },
  url: { type: String, required: true },
  caption: String,
}, { timestamps: true });

module.exports = mongoose.model('GalleryImage', GalleryImageSchema);
