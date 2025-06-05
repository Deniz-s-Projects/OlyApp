const express = require('express');
const MapPin = require('../models/MapPin');

const router = express.Router();

// GET /pins - list map pins
router.get('/', async (req, res) => {
  try {
    const pins = await MapPin.find();
    res.json({ data: pins });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /pins - create a new pin
router.post('/', async (req, res) => {
  try {
    const pin = await MapPin.create(req.body);
    res.status(201).json({ data: pin });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// POST /pins/:id - update an existing pin
router.post('/:id', async (req, res) => {
  try {
    const pin = await MapPin.findOneAndUpdate({ id: req.params.id }, req.body, {
      new: true,
    });
    if (!pin) return res.status(404).json({ error: 'Pin not found' });
    res.json({ data: pin });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;
