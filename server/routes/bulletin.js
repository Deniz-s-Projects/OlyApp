const express = require('express');
const BulletinPost = require('../models/BulletinPost');
const BulletinComment = require('../models/BulletinComment');

const router = express.Router();

// helper to get next numeric id for a model
async function nextId(model) {
  const last = await model.findOne().sort('-id');
  return last ? last.id + 1 : 1;
}

// GET /bulletin - list posts
router.get('/', async (req, res) => {
  try {
    const posts = await BulletinPost.find();
    res.json({ data: posts });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /bulletin - create post
router.post('/', async (req, res) => {
  try {
    const post = await BulletinPost.create({
      id: await nextId(BulletinPost),
      content: req.body.content,
      date: req.body.date,
    });
    res.status(201).json({ data: post });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// GET /bulletin/:id/comments - list comments for a post
router.get('/:id/comments', async (req, res) => {
  try {
    const comments = await BulletinComment.find({ postId: Number(req.params.id) });
    res.json({ data: comments });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// POST /bulletin/:id/comments - create comment for a post
router.post('/:id/comments', async (req, res) => {
  try {
    const comment = await BulletinComment.create({
      id: await nextId(BulletinComment),
      postId: Number(req.params.id),
      content: req.body.content,
      date: req.body.date,
    });
    res.status(201).json({ data: comment });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;
