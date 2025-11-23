const express = require('express');
const Item = require('../models/Item');
const Message = require('../models/Message');
const User = require('../models/User');
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

const socket = require('../socket');
const router = express.Router();
router.use(auth);

async function requireAdmin(req, res) {
  const user = await User.findById(req.userId);
  if (!user || !user.isAdmin) {
    res.status(403).json({ error: 'Admin access required' });
    return false;
  }
  return true;
}

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
    socket.broadcast(req.params.id.toString(), message);
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
    const updates = { ...req.body };

    if (Object.prototype.hasOwnProperty.call(updates, 'notice')) {
      const isAdmin = await requireAdmin(req, res);
      if (!isAdmin) return;
    }

    const item = await Item.findByIdAndUpdate(req.params.id, updates, {
      new: true
    });
    if (!item) return res.status(404).json({ error: 'Item not found' });
    res.json({ data: item });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// POST /items/:id/notice - set or clear admin notice
router.post('/:id/notice', async (req, res) => {
  try {
    const isAdmin = await requireAdmin(req, res);
    if (!isAdmin) return;

    const { text, severity } = req.body;
    const update = text
      ? { notice: { text, severity } }
      : { $unset: { notice: '' } };

    const item = await Item.findByIdAndUpdate(req.params.id, update, {
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

// POST /items/:id/ratings - submit rating
router.post('/:id/ratings', async (req, res) => {
  try {
    const { rating, review } = req.body;
    const item = await Item.findByIdAndUpdate(
      req.params.id,
      { $push: { ratings: { rating, review } } },
      { new: true }
    );
    if (!item) return res.status(404).json({ error: 'Item not found' });
    res.status(201).json({ data: item });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// GET /items/:id/ratings - list ratings
router.get('/:id/ratings', async (req, res) => {
  try {
    const item = await Item.findById(req.params.id);
    if (!item) return res.status(404).json({ error: 'Item not found' });
    res.json({ data: item.ratings });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;
