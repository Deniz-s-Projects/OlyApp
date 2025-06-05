const express = require('express');
const MaintenanceRequest = require('../models/MaintenanceRequest');
const Message = require('../models/Message');

const router = express.Router();

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
router.post('/', async (req, res) => {
  try {
    const request = await MaintenanceRequest.create(req.body);
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
      requestId: req.params.id,
      requestType: 'MaintenanceRequest'
    };
    const message = await Message.create(messageData);
    res.status(201).json({ data: message });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// POST /maintenance/:id - update status
router.post('/:id', async (req, res) => {
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
