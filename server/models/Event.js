const mongoose = require('mongoose');

const EventSchema = new mongoose.Schema({
  title: { type: String, required: true },
  date: { type: Date, required: true },
  description: String,
  attendees: { type: [String], default: [] },
  deviceTokens: { type: [String], default: [] },
  reminderSent: { type: Boolean, default: false },
  location: String,
}, { timestamps: true });

module.exports = mongoose.model('Event', EventSchema);
