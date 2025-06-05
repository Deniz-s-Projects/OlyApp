const mongoose = require('mongoose');

const MapPinSchema = new mongoose.Schema({
  id: { type: String, required: true, unique: true },
  title: { type: String, required: true },
  lat: { type: Number, required: true },
  lon: { type: Number, required: true },
  category: {
    type: String,
    enum: ['building', 'venue', 'amenity', 'recreation', 'food'],
    required: true,
  },
});

module.exports = mongoose.model('MapPin', MapPinSchema);
