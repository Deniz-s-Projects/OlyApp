const express = require('express');
const MaintenanceRequest = require('../models/MaintenanceRequest');
const Message = require('../models/Message');
const auth = require('../middleware/auth');
const requireAdmin = require('../middleware/requireAdmin');
const catchAsync = require('../middleware/catchAsync');
router.get('/', catchAsync(async (req, res) => {
  }));
router.post('/', upload.single('image'), catchAsync(async (req, res) => {
  }));
router.get('/:id/messages', catchAsync(async (req, res) => {
  }));

router.post('/:id/messages', catchAsync(async (req, res) => {
  }));
router.put('/:id', requireAdmin, catchAsync(async (req, res) => {
  }));
router.delete('/:id', requireAdmin, catchAsync(async (req, res) => {
  }));
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
