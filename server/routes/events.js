const express = require('express');
const Event = require('../models/Event');
const EventComment = require('../models/EventComment');
const User = require('../models/User');
const auth = require('../middleware/auth');
const requireAdmin = require('../middleware/requireAdmin');
const QRCode = require('qrcode');

const router = express.Router();
router.use(auth);

// GET /events - list events
router.get('/', async (req, res) => {
  try {
    const events = await Event.find();
    const result = [];
    const addInterval = (date, interval) => {
      const d = new Date(date);
      switch (interval) {
        case 'daily':
          d.setDate(d.getDate() + 1);
          break;
        case 'weekly':
          d.setDate(d.getDate() + 7);
          break;
        case 'monthly':
          d.setMonth(d.getMonth() + 1);
          break;
        case 'yearly':
          d.setFullYear(d.getFullYear() + 1);
          break;
        default:
          return null;
      }
      return d;
    };

    for (const e of events) {
      result.push(e);
      if (e.repeatInterval && e.repeatUntil) {
        let next = addInterval(e.date, e.repeatInterval);
        while (next && next <= e.repeatUntil) {
          const obj = { ...e.toObject(), date: next };
          result.push(obj);
          next = addInterval(next, e.repeatInterval);
        }
      }
    }
    res.json({ data: result });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /events - create event
router.post('/', requireAdmin, async (req, res) => {
  try {
    const data = {
      title: req.body.title,
      date: req.body.date,
      description: req.body.description,
      attendees: req.body.attendees,
      deviceTokens: req.body.deviceTokens,
      checkIns: req.body.checkIns,
      reminderSent: req.body.reminderSent,
      location: req.body.location,
      category: req.body.category, 
      repeatInterval: req.body.repeatInterval,
      repeatUntil: req.body.repeatUntil, 
    };
    const event = await Event.create(data);
    res.json({ data: event });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// PUT /events/:id - update event
router.put('/:id', requireAdmin, async (req, res) => {
  try {
    const data = {
      title: req.body.title,
      date: req.body.date,
      description: req.body.description,
      attendees: req.body.attendees,
      deviceTokens: req.body.deviceTokens,
      checkIns: req.body.checkIns,
      reminderSent: req.body.reminderSent,
      location: req.body.location,
      category: req.body.category, 
      repeatInterval: req.body.repeatInterval,
      repeatUntil: req.body.repeatUntil, 
    };
    const event = await Event.findByIdAndUpdate(req.params.id, data, {
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
    const event = await Event.findById(req.params.id);
    if (!event) return res.status(404).json({ error: 'Event not found' });
    const numericId = Number(req.userId);
    if (!Number.isNaN(numericId)) {
      if (!event.attendees.includes(numericId)) {
        event.attendees.push(numericId);
      }
    }
    try {
      const user = await User.findById(req.userId);
      if (user) {
        for (const token of user.deviceTokens) {
          if (!event.deviceTokens.includes(token)) {
            event.deviceTokens.push(token);
          }
        }
      }
    } catch (_) {
      // ignore invalid user id
    }
    await event.save();
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

// GET /events/:id/comments - list comments
router.get('/:id/comments', async (req, res) => {
  try {
    const comments = await EventComment.find({ eventId: req.params.id });
    res.json({ data: comments });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// POST /events/:id/comments - create comment
router.post('/:id/comments', async (req, res) => {
  try {
    const comment = await EventComment.create({
      eventId: req.params.id,
      content: req.body.content,
      date: req.body.date,
    });
    res.status(201).json({ data: comment });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// GET /events/:id/qr - return QR code image
router.get('/:id/qr', async (req, res) => {
  try {
    const event = await Event.findById(req.params.id);
    if (!event) return res.status(404).json({ error: 'Event not found' });
    const data = `event:${event._id}`;
    const buffer = await QRCode.toBuffer(data, { type: 'png' });
    res.set('Content-Type', 'image/png');
    res.send(buffer);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /events/:id/checkin - record user check-in
router.post('/:id/checkin', async (req, res) => {
  try {
    const numericId = Number(req.userId);
    const event = await Event.findById(req.params.id);
    if (!event) return res.status(404).json({ error: 'Event not found' });
    if (!Number.isNaN(numericId) && !event.checkIns.includes(numericId)) {
      event.checkIns.push(numericId);
      await event.save();
    }
    res.json({ data: event.checkIns });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;
