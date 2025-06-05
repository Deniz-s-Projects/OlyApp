const express = require('express');
const admin = require('firebase-admin');
const auth = require('../middleware/auth');
const User = require('../models/User');

const router = express.Router();
router.use(auth);

router.post('/register', async (req, res) => {
  const { token } = req.body;
  if (!token) return res.status(400).json({ error: 'Token required' });
  try {
    await User.updateOne({ _id: req.userId }, { $addToSet: { deviceTokens: token } });
    res.json({ success: true });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

router.post('/send', async (req, res) => {
  const { tokens, notification } = req.body;
  if (!Array.isArray(tokens) || tokens.length === 0) {
    return res.status(400).json({ error: 'Tokens required' });
  }
  try {
    const response = await admin.messaging().sendEachForMulticast({
      tokens,
      notification,
    });
    res.json({ successCount: response.successCount });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
