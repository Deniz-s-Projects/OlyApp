const mongoose = require('mongoose');

const EventSchema = new mongoose.Schema({
  title: { type: String, required: true },
  date: { type: Date, required: true },
  description: String,
  // Keep attendee ids numeric to align with server tests
  attendees: { type: [Number], default: [] },
  deviceTokens: { type: [String], default: [] },
  checkIns: { type: [Number], default: [] },
  reminderSent: { type: Boolean, default: false },
  location: String,
  category: String,
}, { timestamps: true });

module.exports = mongoose.model('Event', EventSchema);
