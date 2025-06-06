const mongoose = require('mongoose');

const PollVoteSchema = new mongoose.Schema({
  pollId: { type: mongoose.Schema.Types.ObjectId, ref: 'Poll', required: true },
  userId: { type: String, required: true },
  option: { type: Number, required: true },
}, { timestamps: true });

PollVoteSchema.index({ pollId: 1, userId: 1 }, { unique: true });

module.exports = mongoose.model('PollVote', PollVoteSchema);
