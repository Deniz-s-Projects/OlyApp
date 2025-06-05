const express = require('express');
const Event = require('../models/Event');
const auth = require('../middleware/auth');
const requireAdmin = require('../middleware/requireAdmin');

const router = express.Router();
router.use(auth);

// GET /events - list events
router.get('/', async (req, res) => {
  try {
    const events = await Event.find();
    res.json({ data: events });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /events - create event
router.post('/', requireAdmin, async (req, res) => {
  try {
    const event = await Event.create(req.body);
    res.json({ data: event });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// PUT /events/:id - update event
router.put('/:id', requireAdmin, async (req, res) => {
  try {
    const event = await Event.findByIdAndUpdate(req.params.id, req.body, {
      new: true
    });
    if (!event) return res.status(404).json({ error: 'Event not found' });
    res.json({ data: event });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// DELETE /events/:id - remove event
router.delete('/:id', requireAdmin, async (req, res) => {
  try {
    const event = await Event.findByIdAndDelete(req.params.id);
    if (!event) return res.status(404).json({ error: 'Event not found' });
    res.json({ data: event });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// POST /events/:id/rsvp - add attendee
router.post('/:id/rsvp', async (req, res) => {
  try {
    const userId = Number(req.userId);
    if (!Number.isInteger(userId)) {
      return res.status(400).json({ error: 'Invalid userId' });
    }
    const event = await Event.findById(req.params.id);
    if (!event) return res.status(404).json({ error: 'Event not found' });
    if (!event.attendees.includes(userId)) {
      event.attendees.push(userId);
      await event.save();
    }
    res.json(event);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// GET /events/:id/attendees - list attendees
router.get('/:id/attendees', async (req, res) => {
  try {
    const event = await Event.findById(req.params.id);
    if (!event) return res.status(404).json({ error: 'Event not found' });
    res.json({ data: event.attendees });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;
