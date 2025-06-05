const express = require('express');
const BookingSlot = require('../models/BookingSlot');
const auth = require('../middleware/auth');

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

// POST /bookings - reserve a slot
router.post('/', async (req, res) => {
  const { time, name } = req.body;
  if (!time || !name) return res.status(400).json({ error: 'time and name required' });

  try {
    const slot = await BookingSlot.findOneAndUpdate(
      { time: new Date(time), name: { $exists: false } },
      { name },
      { new: true }
    );

    if (!slot) return res.status(400).json({ error: 'Slot unavailable' });
    res.json({ data: slot });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;
