const express = require('express');
const MaintenanceRequest = require('../models/MaintenanceRequest');
const Message = require('../models/Message');
const auth = require('../middleware/auth');
const requireAdmin = require('../middleware/requireAdmin');
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

// GET /maintenance - list maintenance requests
router.get('/', async (req, res) => {
  try {
    const requests = await MaintenanceRequest.find();
    res.json({ data: requests });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /maintenance - create maintenance request
router.post('/', upload.single('image'), async (req, res) => {
  try {
    const data = { ...req.body, userId: Number(req.userId) };
    if (req.file) {
      data.imageUrl = `/uploads/${req.file.filename}`;
    }
    const request = await MaintenanceRequest.create(data);
    res.status(201).json({ data: request });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// GET /maintenance/:id/messages - list messages for a request
router.get('/:id/messages', async (req, res) => {
  try {
    const messages = await Message.find({
      requestId: req.params.id,
      requestType: 'MaintenanceRequest'
    });
    res.json({ data: messages });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// POST /maintenance/:id/messages - create message for a request
router.post('/:id/messages', async (req, res) => {
  try {
    const messageData = {
      ...req.body,
      senderId: Number(req.userId),
      requestId: req.params.id,
      requestType: 'MaintenanceRequest'
    };
    const message = await Message.create(messageData);
    res.status(201).json({ data: message });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// PUT /maintenance/:id - update status
router.put('/:id', requireAdmin, async (req, res) => {
  try {
    const request = await MaintenanceRequest.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true }
    );
    if (!request) return res.status(404).json({ error: 'Request not found' });
    res.json(request);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;
