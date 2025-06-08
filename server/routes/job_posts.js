const express = require('express');
const JobPost = require('../models/JobPost');
const auth = require('../middleware/auth');

const router = express.Router();
router.use(auth);

// GET /job_posts - list posts
router.get('/', async (req, res) => {
  try {
    const posts = await JobPost.find();
    res.json({ data: posts });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /job_posts - create post
router.post('/', async (req, res) => {
  try {
    const data = {
      ownerId: req.userId,
      title: req.body.title,
      description: req.body.description,
      pay: req.body.pay,
      contact: req.body.contact
    };
    const post = await JobPost.create(data);
    res.status(201).json({ data: post });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// PUT /job_posts/:id - update post
router.put('/:id', async (req, res) => {
  try {
    const post = await JobPost.findByIdAndUpdate(req.params.id, req.body, {
      new: true
    });
    if (!post) return res.status(404).json({ error: 'Post not found' });
    res.json({ data: post });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// DELETE /job_posts/:id - delete post
router.delete('/:id', async (req, res) => {
  try {
    const post = await JobPost.findByIdAndDelete(req.params.id);
    if (!post) return res.status(404).json({ error: 'Post not found' });
    res.json({ data: post });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;
