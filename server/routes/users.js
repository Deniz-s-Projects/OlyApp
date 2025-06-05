const express = require('express');
const User = require('../models/User');
const auth = require('../middleware/auth');

const router = express.Router();
router.use(auth);

// PUT /users/me - update current user's profile
router.put('/me', async (req, res) => {
  try {
    const { name, email, avatarUrl } = req.body;
    const updates = { name, email, avatarUrl };
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
      },
    });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;
