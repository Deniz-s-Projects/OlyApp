const express = require('express');
const WikiArticle = require('../models/WikiArticle');
const auth = require('../middleware/auth');

const router = express.Router();
router.use(auth);

async function nextId(model) {
  const last = await model.findOne().sort('-id');
  return last ? last.id + 1 : 1;
}

// GET /wiki - list articles
router.get('/', async (req, res) => {
  try {
    const articles = await WikiArticle.find();
    res.json({ data: articles });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /wiki/:id - get single article
router.get('/:id', async (req, res) => {
  try {
    const article = await WikiArticle.findOne({ id: Number(req.params.id) });
    if (!article) return res.status(404).json({ error: 'Article not found' });
    res.json({ data: article });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// POST /wiki - create article
router.post('/', async (req, res) => {
  try {
    const article = await WikiArticle.create({
      id: await nextId(WikiArticle),
      title: req.body.title,
      content: req.body.content,
      authorId: req.userId,
      createdAt: req.body.createdAt,
    });
    res.status(201).json({ data: article });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// PUT /wiki/:id - update article
router.put('/:id', async (req, res) => {
  try {
    const article = await WikiArticle.findOneAndUpdate(
      { id: Number(req.params.id) },
      { title: req.body.title, content: req.body.content },
      { new: true }
    );
    if (!article) return res.status(404).json({ error: 'Article not found' });
    res.json({ data: article });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// DELETE /wiki/:id - delete article
router.delete('/:id', async (req, res) => {
  try {
    await WikiArticle.findOneAndDelete({ id: Number(req.params.id) });
    res.json({});
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;
