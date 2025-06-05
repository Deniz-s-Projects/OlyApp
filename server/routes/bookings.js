const express = require('express');
const BookingSlot = require('../models/BookingSlot');
const auth = require('../middleware/auth');
const requireAdmin = require('../middleware/requireAdmin');

const router = express.Router();
router.use(auth);

// GET /bookings/slots - list available booking slots
router.get('/slots', async (req, res) => {
  try {
    const slots = await BookingSlot.find({ name: { $exists: false } }).sort('time');
    res.json({ data: slots.map(s => s.time.toISOString()) });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /bookings/slots/manage - list slots with ids (admin only)
router.get('/slots/manage', requireAdmin, async (req, res) => {
  try {
    const slots = await BookingSlot.find({ name: { $exists: false } }).sort('time');
    res.json({ data: slots });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /bookings/slots - create a new booking slot (admin only)
router.post('/slots', requireAdmin, async (req, res) => {
  const { time } = req.body;
  if (!time) return res.status(400).json({ error: 'time required' });
  try {
    const slot = await BookingSlot.create({ time });
    res.status(201).json({ data: slot });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// DELETE /bookings/slots/:id - delete a booking slot (admin only)
router.delete('/slots/:id', requireAdmin, async (req, res) => {
  try {
    const slot = await BookingSlot.findByIdAndDelete(req.params.id);
    if (!slot) return res.status(404).json({ error: 'Slot not found' });
    res.json({ data: slot });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// POST /bookings - reserve a slot
router.post('/', async (req, res) => {
  const { time, name } = req.body;
  if (!time || !name) return res.status(400).json({ error: 'time and name required' });

  try {
    const slot = await BookingSlot.findOneAndUpdate(
      { time: new Date(time), name: { $exists: false } },
      { name, userId: Number(req.userId) },
      { new: true }
    );

    if (!slot) return res.status(400).json({ error: 'Slot unavailable' });
    res.json({ data: slot });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// GET /bookings/my - list current user's bookings
router.get('/my', async (req, res) => {
  try {
    const bookings = await BookingSlot.find({ userId: Number(req.userId) });
    res.json({ data: bookings });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// DELETE /bookings/:id - cancel a booking
router.delete('/:id', async (req, res) => {
  try {
    const slot = await BookingSlot.findByIdAndUpdate(
      req.params.id,
      { $unset: { name: '', userId: '' } },
      { new: true }
    );
    if (!slot) return res.status(404).json({ error: 'Slot not found' });
    res.json({ data: slot });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;
