const mongoose = require('mongoose');

const ServiceListingSchema = new mongoose.Schema({
  userId: { type: String, required: true },
  title: { type: String, required: true },
  description: String,
  contact: String,
  ratings: [
    {
      rating: { type: Number, required: true },
      review: String,
    },
  ],
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('ServiceListing', ServiceListingSchema);
