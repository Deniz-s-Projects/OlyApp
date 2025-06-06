const express = require('express');
const ServiceListing = require('../models/ServiceListing');
const auth = require('../middleware/auth');

const router = express.Router();
router.use(auth);

// GET /services - list service listings
router.get('/', async (req, res) => {
  try {
    const listings = await ServiceListing.find();
    res.json({ data: listings });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /services - create listing
router.post('/', async (req, res) => {
  try {
    const data = { ...req.body, userId: req.userId };
    const listing = await ServiceListing.create(data);
    res.status(201).json({ data: listing });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// PUT /services/:id - update listing
router.put('/:id', async (req, res) => {
  try {
    const listing = await ServiceListing.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true }
    );
    if (!listing) return res.status(404).json({ error: 'Listing not found' });
    res.json({ data: listing });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// DELETE /services/:id - remove listing
router.delete('/:id', async (req, res) => {
  try {
    const listing = await ServiceListing.findByIdAndDelete(req.params.id);
    if (!listing) return res.status(404).json({ error: 'Listing not found' });
    res.json({ data: listing });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;
