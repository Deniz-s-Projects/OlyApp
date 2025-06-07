const express = require('express');
const Conversation = require('../models/Conversation');
const Message = require('../models/Message');
const auth = require('../middleware/auth');
const socket = require('../socket');

const router = express.Router();
router.use(auth);

// POST /channels - create a new group channel
router.post('/', async (req, res) => {
  try {
    const { name, participants = [] } = req.body;
    if (!name) return res.status(400).json({ error: 'Name required' });
    const ids = Array.from(new Set([...participants.map(String), String(req.userId)]));
    const channel = await Conversation.create({
      name,
      participants: ids,
      isGroup: true,
    });
    res.status(201).json({ data: channel });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// POST /channels/:id/participants - add participant
router.post('/:id/participants', async (req, res) => {
  try {
    const { userId } = req.body;
    if (!userId) return res.status(400).json({ error: 'userId required' });
    const channel = await Conversation.findByIdAndUpdate(
      req.params.id,
      { $addToSet: { participants: String(userId) } },
      { new: true }
    );
    if (!channel) return res.status(404).json({ error: 'Channel not found' });
    res.json({ data: channel });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// DELETE /channels/:id/participants/:userId - remove participant
router.delete('/:id/participants/:userId', async (req, res) => {
  try {
    const channel = await Conversation.findByIdAndUpdate(
      req.params.id,
      { $pull: { participants: String(req.params.userId) } },
      { new: true }
    );
    if (!channel) return res.status(404).json({ error: 'Channel not found' });
    res.json({ data: channel });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// GET /channels/:id/messages - fetch group messages
router.get('/:id/messages', async (req, res) => {
  try {
    const messages = await Message.find({ conversationId: req.params.id });
    res.json({ data: messages });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// POST /channels/:id/messages - send message to channel
router.post('/:id/messages', async (req, res) => {
  try {
    const message = await Message.create({
      conversationId: req.params.id,
      senderId: req.userId,
      content: req.body.content,
    });
    socket.broadcast(req.params.id.toString(), message);
    res.status(201).json({ data: message });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;
