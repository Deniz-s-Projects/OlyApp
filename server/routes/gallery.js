const express = require('express');
const multer = require('multer');
const path = require('path');
const GalleryImage = require('../models/GalleryImage');
const auth = require('../middleware/auth');

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, path.join(__dirname, '../uploads'));
  },
  filename: (req, file, cb) => {
    const unique = `${Date.now()}-${Math.round(Math.random() * 1e9)}`;
    cb(null, unique + path.extname(file.originalname));
  }
});
const upload = multer({ storage });

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
