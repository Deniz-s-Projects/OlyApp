const mongoose = require('mongoose');

const StudyGroupSchema = new mongoose.Schema({
  topic: { type: String, required: true },
  description: String,
  meetingTime: Date,
  creatorId: { type: String, required: true },
  memberIds: { type: [String], default: [] }
}, { timestamps: true });

module.exports = mongoose.model('StudyGroup', StudyGroupSchema);
