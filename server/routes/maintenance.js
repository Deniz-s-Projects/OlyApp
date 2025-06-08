const express = require('express');
const MaintenanceRequest = require('../models/MaintenanceRequest');
const Message = require('../models/Message');
const auth = require('../middleware/auth');
const requireAdmin = require('../middleware/requireAdmin');
const catchAsync = require('../middleware/catchAsync');
const multer = require('multer');
const path = require('path');
const socket = require('../socket');

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
router.get('/', catchAsync(async (req, res) => {
    const requests = await MaintenanceRequest.find();
    res.json({ data: requests });
  }));

// POST /maintenance - create maintenance request
router.post('/', upload.single('image'), catchAsync(async (req, res) => {
    const data = { ...req.body, userId: req.userId };
    if (req.file) {
      data.imageUrl = `/uploads/${req.file.filename}`;
    }
    const request = await MaintenanceRequest.create(data);
    res.status(201).json({ data: request });
  }));

// GET /maintenance/:id/messages - list messages for a request
router.get('/:id/messages', catchAsync(async (req, res) => {
    const messages = await Message.find({
      requestId: req.params.id,
      requestType: 'MaintenanceRequest'
    });
    res.json({ data: messages });
  }));

// POST /maintenance/:id/messages - create message for a request
router.post('/:id/messages', catchAsync(async (req, res) => {
    const messageData = {
      ...req.body,
      senderId: req.userId,
      requestId: req.params.id,
      requestType: 'MaintenanceRequest'
    };
    const message = await Message.create(messageData);
    socket.broadcast(req.params.id.toString(), message);
    res.status(201).json({ data: message });
  }));

// PUT /maintenance/:id - update status
router.put('/:id', requireAdmin, catchAsync(async (req, res) => {
    const request = await MaintenanceRequest.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true }
    );
    if (!request) return res.status(404).json({ error: 'Request not found' });
    res.json(request);
  }));

// DELETE /maintenance/:id - remove request
router.delete('/:id', requireAdmin, catchAsync(async (req, res) => {
    const request = await MaintenanceRequest.findByIdAndDelete(req.params.id);
    if (!request) return res.status(404).json({ error: 'Request not found' });
    res.json({ data: request });
  }));

module.exports = router;
