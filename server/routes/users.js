const express = require('express');
const multer = require('multer');
const path = require('path');
const User = require('../models/User');
const auth = require('../middleware/auth');
const requireAdmin = require('../middleware/requireAdmin');

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

// GET /users - list users (admin only)
router.get('/', requireAdmin, async (req, res) => {
  try {
    const query = {};
    if (req.query.search) {
      const regex = new RegExp(req.query.search, 'i');
      query.$or = [{ name: regex }, { email: regex }];
    }
    const users = await User.find(query).select(
      'name email avatarUrl isAdmin isListed bio room'
    );
    res.json({ data: users });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// PUT /users/me - update current user's profile
router.put('/me', async (req, res) => {
  try {
    const { name, email, avatarUrl, isListed, bio, room } = req.body;
    const updates = { name, email, avatarUrl, isListed, bio, room };
    const user = await User.findByIdAndUpdate(req.userId, updates, {
      new: true,
    });
    if (!user) return res.status(404).json({ error: 'User not found' });
    res.json({
      data: {
        id: user._id,
        name: user.name,
        email: user.email,
        avatarUrl: user.avatarUrl,
        isAdmin: user.isAdmin,
        isListed: user.isListed,
        bio: user.bio,
        room: user.room,
      },
    });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// POST /users/me/avatar - upload avatar image
router.post('/me/avatar', upload.single('avatar'), async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ error: 'No file uploaded' });
    const avatarUrl = `/uploads/${req.file.filename}`;
    await User.findByIdAndUpdate(req.userId, { avatarUrl });
    res.status(201).json({ path: avatarUrl });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// DELETE /users/me - remove current user
router.delete('/me', async (req, res) => {
  try {
    const user = await User.findByIdAndDelete(req.userId);
    if (!user) return res.status(404).json({ error: 'User not found' });
    res.json({ message: 'Account deleted' });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// PUT /users/:id - update user (admin only)
router.put('/:id', requireAdmin, async (req, res) => {
  try {
    const { name, email, avatarUrl, isAdmin, isListed, bio, room } = req.body;
    const updates = { name, email, avatarUrl, isAdmin, isListed, bio, room };
    const user = await User.findByIdAndUpdate(req.params.id, updates, {
      new: true,
    });
    if (!user) return res.status(404).json({ error: 'User not found' });
    res.json({ data: user });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// DELETE /users/:id - remove user (admin only)
router.delete('/:id', requireAdmin, async (req, res) => {
  try {
    const user = await User.findByIdAndDelete(req.params.id);
    if (!user) return res.status(404).json({ error: 'User not found' });
    res.json({ data: user });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;
