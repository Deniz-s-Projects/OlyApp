const express = require('express');
const admin = require('firebase-admin');
const auth = require('../middleware/auth');
const requireAdmin = require('../middleware/requireAdmin');
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

// POST /notifications/broadcast - send an emergency alert to all registered tokens (admin only)
router.post('/broadcast', requireAdmin, async (req, res) => {
  const { title, body } = req.body;
  if (!title || !body) {
    return res.status(400).json({ error: 'title and body required' });
  }
  try {
    const users = await User.find({}, 'deviceTokens');
    const tokens = Array.from(new Set(
      users.flatMap((u) => u.deviceTokens)
    ));
    let successCount = 0;
    const chunkSize = 500;
    for (let i = 0; i < tokens.length; i += chunkSize) {
      const batch = tokens.slice(i, i + chunkSize);
      if (batch.length === 0) continue;
      const resp = await admin.messaging().sendEachForMulticast({
        tokens: batch,
        notification: { title, body },
      });
      successCount += resp.successCount;
    }
    res.json({ successCount });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
