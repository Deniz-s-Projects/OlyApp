const express = require('express');
const Item = require('../models/Item');
const Message = require('../models/Message');
const auth = require('../middleware/auth');
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

// GET /items - list items
router.get('/', async (req, res) => {
  try {
    const items = await Item.find();
    res.json({ data: items });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /items - create item
router.post('/', upload.single('image'), async (req, res) => {
  try {
    const data = { ...req.body, ownerId: req.userId };
    if (req.file) {
      data.imageUrl = `/uploads/${req.file.filename}`;
    }
    const item = await Item.create(data);
    res.status(201).json({ data: item });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// GET /items/:id/messages - list messages
router.get('/:id/messages', async (req, res) => {
  try {
    const messages = await Message.find({
      requestId: req.params.id,
      requestType: 'Item'
    });
    res.json(messages);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// POST /items/:id/messages - create message
router.post('/:id/messages', async (req, res) => {
  try {
    const messageData = {
      ...req.body,
      senderId: req.userId,
      requestId: req.params.id,
      requestType: 'Item'
    };
    const message = await Message.create(messageData);
    res.status(201).json(message);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// POST /items/:id/request - mark as requested/claimed
router.post('/:id/request', async (req, res) => {
  try {
    await Item.findByIdAndUpdate(req.params.id, { requested: true });
    res.json({});
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// POST /items/:id - update item
router.post('/:id', async (req, res) => {
  try {
    const item = await Item.findByIdAndUpdate(req.params.id, req.body, {
      new: true
    });
    if (!item) return res.status(404).json({ error: 'Item not found' });
    res.json({ data: item });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// POST /items/:id/delete - delete item
router.post('/:id/delete', async (req, res) => {
  try {
    await Item.findByIdAndDelete(req.params.id);
    res.json({});
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;
