const express = require('express');
const BulletinPost = require('../models/BulletinPost');
const BulletinComment = require('../models/BulletinComment');
const User = require('../models/User');
const auth = require('../middleware/auth');

const router = express.Router();
router.use(auth);

async function nextId(model) {
  const last = await model.findOne().sort('-id');
  return last ? last.id + 1 : 1;
}

async function isAdmin(userId) {
  if (userId == null) return false;
  try {
    const user = await User.findById(userId).select('isAdmin').lean();
    return Boolean(user && user.isAdmin);
  } catch (_) {
    return false;
  }
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
      userId: req.userId,
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
      userId: req.userId,
      content: req.body.content,
      date: req.body.date,
    });
    res.status(201).json({ data: comment });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// PUT /bulletin/:postId/comments/:commentId - update a comment (author only)
router.put('/:postId/comments/:commentId', async (req, res) => {
  try {
    const comment = await BulletinComment.findOne({
      id: Number(req.params.commentId),
      postId: Number(req.params.postId),
    });
    if (!comment) return res.status(404).json({ error: 'Comment not found' });
    if (String(comment.userId) !== String(req.userId)) {
      return res.status(403).json({ error: 'Forbidden' });
    }
    comment.content = req.body.content ?? comment.content;
    await comment.save();
    res.json({ data: comment });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// DELETE /bulletin/:postId/comments/:commentId - delete a comment (author or admin)
router.delete('/:postId/comments/:commentId', async (req, res) => {
  try {
    const comment = await BulletinComment.findOne({
      id: Number(req.params.commentId),
      postId: Number(req.params.postId),
    });
    if (!comment) return res.status(404).json({ error: 'Comment not found' });
    const owns = String(comment.userId) === String(req.userId);
    if (!owns && !(await isAdmin(req.userId))) {
      return res.status(403).json({ error: 'Forbidden' });
    }
    await comment.deleteOne();
    res.json({});
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// PUT /bulletin/:id - update post (author only)
router.put('/:id', async (req, res) => {
  try {
    const post = await BulletinPost.findOne({ id: Number(req.params.id) });
    if (!post) return res.status(404).json({ error: 'Post not found' });
    if (String(post.userId) !== String(req.userId)) {
      return res.status(403).json({ error: 'Forbidden' });
    }
    post.content = req.body.content ?? post.content;
    await post.save();
    res.json({ data: post });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// DELETE /bulletin/:id - delete post (author or admin)
router.delete('/:id', async (req, res) => {
  try {
    const post = await BulletinPost.findOne({ id: Number(req.params.id) });
    if (!post) return res.status(404).json({ error: 'Post not found' });
    const owns = String(post.userId) === String(req.userId);
    if (!owns && !(await isAdmin(req.userId))) {
      return res.status(403).json({ error: 'Forbidden' });
    }
    await post.deleteOne();
    await BulletinComment.deleteMany({ postId: Number(req.params.id) });
    res.json({});
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;
