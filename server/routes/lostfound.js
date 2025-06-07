const express = require('express');
const LostItem = require('../models/LostItem');
const Message = require('../models/Message');
const auth = require('../middleware/auth');
const socket = require('../socket');
const multer = require('multer');
const path = require('path');

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, path.join(__dirname, '../uploads'));
  },
  filename: (req, file, cb) => {
    const unique = `${Date.now()}-${Math.round(Math.random() * 1e9)}`;
    cb(null, unique + path.extname(file.originalname));
  }
});
const upload = multer({ storage });

const router = express.Router();
router.use(auth);

// GET /lostfound - list lost & found posts
router.get('/', async (req, res) => {
  try {
    const query = {};
    if (req.query.type) {
      query.type = req.query.type;
    }
    if (typeof req.query.resolved !== 'undefined') {
      query.resolved = req.query.resolved === 'true';
    }
    if (req.query.search) {
      const regex = { $regex: req.query.search, $options: 'i' };
      query.$or = [{ title: regex }, { description: regex }];
    }
    const items = await LostItem.find(query);
    res.json({ data: items });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /lostfound - create lost item post
router.post('/', upload.single('image'), async (req, res) => {
  try {
    const data = { ...req.body, ownerId: req.userId };
    if (req.file) {
      data.imageUrl = `/uploads/${req.file.filename}`;
    }
    const item = await LostItem.create(data);
    res.status(201).json({ data: item });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// GET /lostfound/:id/messages - list messages
router.get('/:id/messages', async (req, res) => {
  try {
    const messages = await Message.find({
      requestId: req.params.id,
      requestType: 'LostItem'
    });
    res.json(messages);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// POST /lostfound/:id/messages - create message
router.post('/:id/messages', async (req, res) => {
  try {
    const messageData = {
      ...req.body,
      senderId: req.userId,
      requestId: req.params.id,
      requestType: 'LostItem'
    };
    const message = await Message.create(messageData);
    socket.broadcast(req.params.id.toString(), message);
    res.status(201).json(message);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// POST /lostfound/:id/resolve - mark item as resolved
router.post('/:id/resolve', async (req, res) => {
  try {
    await LostItem.findByIdAndUpdate(req.params.id, { resolved: true });
    res.json({});
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// POST /lostfound/:id - update item
router.post('/:id', async (req, res) => {
  try {
    const item = await LostItem.findByIdAndUpdate(req.params.id, req.body, {
      new: true
    });
    if (!item) return res.status(404).json({ error: 'Item not found' });
    res.json({ data: item });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// POST /lostfound/:id/delete - delete item
router.post('/:id/delete', async (req, res) => {
  try {
    await LostItem.findByIdAndDelete(req.params.id);
    res.json({});
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;
