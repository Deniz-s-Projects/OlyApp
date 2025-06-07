const mongoose = require('mongoose');

const ClubSchema = new mongoose.Schema({
  name: { type: String, required: true },
  description: String,
  members: { type: [String], default: [] },
  channelId: String,
}, { timestamps: true });

module.exports = mongoose.model('Club', ClubSchema);
