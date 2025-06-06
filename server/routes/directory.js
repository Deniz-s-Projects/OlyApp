const express = require('express');
const User = require('../models/User');
const Conversation = require('../models/Conversation');
const Message = require('../models/Message');
const auth = require('../middleware/auth');

const router = express.Router();
router.use(auth);

// GET /directory - list/search opt-in residents
router.get('/', async (req, res) => {
  try {
    const query = { isListed: true };
    if (req.query.search) {
      query.name = { $regex: req.query.search, $options: 'i' };
    }
    const users = await User.find(query).select('name email avatarUrl');
    res.json({ data: users });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

async function getConversation(userId, otherId) {
  let convo = await Conversation.findOne({
    participants: { $all: [userId, otherId] }
  });
  if (!convo) {
    convo = await Conversation.create({ participants: [userId, otherId] });
  }
  return convo;
}

// GET /directory/:id/messages - fetch direct messages
router.get('/:id/messages', async (req, res) => {
  try {
    const otherId = String(req.params.id);
    const convo = await getConversation(String(req.userId), otherId);
    const messages = await Message.find({ conversationId: convo._id });
    res.json({ data: messages });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// POST /directory/:id/messages - send message
router.post('/:id/messages', async (req, res) => {
  try {
    const otherId = String(req.params.id);
    const convo = await getConversation(String(req.userId), otherId);
    const message = await Message.create({
      conversationId: convo._id,
      senderId: req.userId,
      content: req.body.content
    });
    res.status(201).json({ data: message });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;
