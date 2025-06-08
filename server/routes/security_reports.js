const express = require('express');
const SecurityReport = require('../models/SecurityReport');
const auth = require('../middleware/auth');
const requireAdmin = require('../middleware/requireAdmin');

const router = express.Router();
router.use(auth);

// GET /security_reports - list reports
router.get('/', async (req, res) => {
  try {
    const reports = await SecurityReport.find();
    res.json({ data: reports });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /security_reports/:id - get one report
router.get('/:id', async (req, res) => {
  try {
    const report = await SecurityReport.findById(req.params.id);
    if (!report) return res.status(404).json({ error: 'Report not found' });
    res.json({ data: report });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// POST /security_reports - create report
router.post('/', async (req, res) => {
  try {
    const report = await SecurityReport.create({
      reporterId: req.userId,
      description: req.body.description,
      location: req.body.location,
      timestamp: req.body.timestamp,
    });
    res.status(201).json({ data: report });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// PUT /security_reports/:id - update report
router.put('/:id', requireAdmin, async (req, res) => {
  try {
    const report = await SecurityReport.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true }
    );
    if (!report) return res.status(404).json({ error: 'Report not found' });
    res.json({ data: report });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// DELETE /security_reports/:id - delete report
router.delete('/:id', requireAdmin, async (req, res) => {
  try {
    const report = await SecurityReport.findByIdAndDelete(req.params.id);
    if (!report) return res.status(404).json({ error: 'Report not found' });
    res.json({ data: report });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;
