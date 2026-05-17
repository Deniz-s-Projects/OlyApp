const express = require('express');
const GalleryImage = require('../models/GalleryImage');
const auth = require('../middleware/auth');
const { imageUploader } = require('../middleware/uploads');

const upload = imageUploader();

const router = express.Router();
router.use(auth);

// GET /gallery - list images
router.get('/', async (req, res) => {
  try {
    const images = await GalleryImage.find();
    res.json({ data: images });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /gallery - upload image
router.post('/', upload.single('image'), async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ error: 'Image required' });
    const img = await GalleryImage.create({
      uploaderId: String(req.userId),
      url: `/uploads/${req.file.filename}`,
    });
    res.status(201).json({ data: img });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;
