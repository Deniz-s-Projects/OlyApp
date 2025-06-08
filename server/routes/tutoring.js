const express = require('express');
const TutoringPost = require('../models/TutoringPost');
const auth = require('../middleware/auth');

const router = express.Router();
router.use(auth);

// GET /tutoring - list posts
router.get('/', async (req, res) => {
  try {
    const query = {};
    if (req.query.isOffering !== undefined) {
      query.isOffering = req.query.isOffering === 'true';
    }
    const posts = await TutoringPost.find(query);
    res.json({ data: posts });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /tutoring - create post
router.post('/', async (req, res) => {
  try {
    const data = {
      userId: req.userId,
      subject: req.body.subject,
      description: req.body.description,
      isOffering: req.body.isOffering,
      contactUserId: req.body.contactUserId || String(req.userId)
    };
    const post = await TutoringPost.create(data);
    res.status(201).json({ data: post });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;
