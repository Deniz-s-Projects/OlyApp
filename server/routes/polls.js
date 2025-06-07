const express = require('express');
const Poll = require('../models/Poll');
const PollVote = require('../models/PollVote');
const auth = require('../middleware/auth');
const requireAdmin = require('../middleware/requireAdmin');

const router = express.Router();
router.use(auth);

// GET /polls - list polls with vote counts
router.get('/', async (req, res) => {
  try {
    const polls = await Poll.find();
    const pollIds = polls.map(p => p._id);
    const agg = await PollVote.aggregate([
      { $match: { pollId: { $in: pollIds } } },
      { $group: { _id: { pollId: '$pollId', option: '$option' }, count: { $sum: 1 } } }
    ]);
    const countsMap = {};
    for (const a of agg) {
      const pid = a._id.pollId.toString();
      const opt = a._id.option;
      countsMap[pid] = countsMap[pid] || {};
      countsMap[pid][opt] = a.count;
    }
    const result = polls.map(p => {
      const map = countsMap[p._id.toString()] || {};
      const counts = p.options.map((_, i) => map[i] || 0);
      return { ...p.toObject(), counts };
    });
    res.json({ data: result });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /polls - create poll
router.post('/', requireAdmin, async (req, res) => {
  const { question, options } = req.body;
  if (!question || !Array.isArray(options) || options.length < 2) {
    return res.status(400).json({ error: 'question and options required' });
  }
  try {
    const poll = await Poll.create({ question, options });
    res.status(201).json({ data: poll });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// POST /polls/:id/vote - submit vote
router.post('/:id/vote', async (req, res) => {
  const { option } = req.body;
  try {
    const poll = await Poll.findById(req.params.id);
    if (!poll) return res.status(404).json({ error: 'Poll not found' });
    if (typeof option !== 'number' || option < 0 || option >= poll.options.length) {
      return res.status(400).json({ error: 'Invalid option' });
    }
    await PollVote.findOneAndUpdate(
      { pollId: poll._id, userId: req.userId },
      { pollId: poll._id, userId: req.userId, option },
      { upsert: true, new: true, setDefaultsOnInsert: true }
    );
    res.json({});
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// DELETE /polls/:id - remove poll and votes
router.delete('/:id', requireAdmin, async (req, res) => {
  try {
    const poll = await Poll.findByIdAndDelete(req.params.id);
    if (!poll) return res.status(404).json({ error: 'Poll not found' });
    await PollVote.deleteMany({ pollId: poll._id });
    res.json({ data: poll });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;
