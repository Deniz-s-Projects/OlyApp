const mongoose = require('mongoose');

const EventSchema = new mongoose.Schema({
  title: { type: String, required: true },
  date: { type: Date, required: true },
  description: String,
  attendees: { type: [Number], default: [] },
  location: String,
}, { timestamps: true });

module.exports = mongoose.model('Event', EventSchema);
