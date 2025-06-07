const express = require('express');
const Club = require('../models/Club');
const Conversation = require('../models/Conversation');
const auth = require('../middleware/auth');

const router = express.Router();
router.use(auth);

// GET /clubs - list clubs
router.get('/', async (req, res) => {
  try {
    const clubs = await Club.find();
    res.json({ data: clubs });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /clubs - create club and chat channel
router.post('/', async (req, res) => {
  try {
    const { name, description } = req.body;
    if (!name) return res.status(400).json({ error: 'Name required' });
    const convo = await Conversation.create({
      name,
      participants: [String(req.userId)],
      isGroup: true,
    });
    const club = await Club.create({
      name,
      description,
      members: [String(req.userId)],
      channelId: convo._id.toString(),
    });
    res.status(201).json({ data: club });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// GET /clubs/:id - get club
router.get('/:id', async (req, res) => {
  try {
    const club = await Club.findById(req.params.id);
    if (!club) return res.status(404).json({ error: 'Club not found' });
    res.json({ data: club });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// PUT /clubs/:id - update club
router.put('/:id', async (req, res) => {
  try {
    const club = await Club.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!club) return res.status(404).json({ error: 'Club not found' });
    res.json({ data: club });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// DELETE /clubs/:id - delete club
router.delete('/:id', async (req, res) => {
  try {
    const club = await Club.findByIdAndDelete(req.params.id);
    if (!club) return res.status(404).json({ error: 'Club not found' });
    res.json({ data: club });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// POST /clubs/:id/join - join club and channel
router.post('/:id/join', async (req, res) => {
  try {
    const club = await Club.findById(req.params.id);
    if (!club) return res.status(404).json({ error: 'Club not found' });
    const userId = String(req.userId);
    if (!club.members.includes(userId)) {
      club.members.push(userId);
      await club.save();
      if (club.channelId) {
        await Conversation.findByIdAndUpdate(
          club.channelId,
          { $addToSet: { participants: userId } },
          { new: true }
        );
      }
    }
    res.json({ data: club });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;
