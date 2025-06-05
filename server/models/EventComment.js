const mongoose = require('mongoose');

const EventCommentSchema = new mongoose.Schema({
  eventId: { type: mongoose.Schema.Types.ObjectId, required: true, ref: 'Event' },
  content: { type: String, required: true },
  date: { type: Date, default: Date.now },
});

module.exports = mongoose.model('EventComment', EventCommentSchema);
