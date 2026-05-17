const express = require('express');
const Document = require('../models/Document');
const auth = require('../middleware/auth');
const { documentUploader } = require('../middleware/uploads');

const upload = documentUploader();

const router = express.Router();
router.use(auth);

// GET /documents - list documents
router.get('/', async (req, res) => {
  try {
    const docs = await Document.find();
    res.json({ data: docs });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /documents - upload new file
router.post('/', upload.single('file'), async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ error: 'File required' });
    const doc = await Document.create({
      uploaderId: String(req.userId),
      fileName: req.file.originalname,
      url: `/uploads/${req.file.filename}`,
    });
    res.status(201).json({ data: doc });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;
