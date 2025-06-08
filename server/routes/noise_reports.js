const express = require('express');
const NoiseReport = require('../models/NoiseReport');
const auth = require('../middleware/auth');
const requireAdmin = require('../middleware/requireAdmin');

const router = express.Router();
router.use(auth);

// GET /noise_reports - list reports (admin only)
router.get('/', requireAdmin, async (req, res) => {
  try {
    const reports = await NoiseReport.find();
    res.json({ data: reports });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /noise_reports - create new report
router.post('/', async (req, res) => {
  try {
    const report = await NoiseReport.create({
      reporterId: req.userId,
      location: req.body.location,
      description: req.body.description,
      timestamp: req.body.timestamp,
    });
    res.status(201).json({ data: report });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;
