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
  const { tokens, notification, data } = req.body;
  if (!Array.isArray(tokens) || tokens.length === 0) {
    return res.status(400).json({ error: 'Tokens required' });
  }
  try {
    const response = await admin.messaging().sendEachForMulticast({
      tokens,
      notification,
      // FCM requires data values to be strings. Coerce here so callers can
      // pass numbers/booleans without surprise; reject objects.
      data: sanitizeData(data),
    });
    res.json({ successCount: response.successCount });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /notifications/broadcast - send an emergency alert to all registered tokens (admin only)
router.post('/broadcast', requireAdmin, async (req, res) => {
  const { title, body, data } = req.body;
  if (!title || !body) {
    return res.status(400).json({ error: 'title and body required' });
  }
  try {
    const users = await User.find({}, 'deviceTokens');
    const tokens = Array.from(new Set(
      users.flatMap((u) => u.deviceTokens)
    ));
    const cleanData = sanitizeData(data);
    let successCount = 0;
    const chunkSize = 500;
    for (let i = 0; i < tokens.length; i += chunkSize) {
      const batch = tokens.slice(i, i + chunkSize);
      if (batch.length === 0) continue;
      const resp = await admin.messaging().sendEachForMulticast({
        tokens: batch,
        notification: { title, body },
        data: cleanData,
      });
      successCount += resp.successCount;
    }
    res.json({ successCount });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// FCM data payloads must be `{ [key: string]: string }`. Coerce primitives,
// drop anything else, and return undefined for empty/falsey input so we
// don't send an empty data object.
function sanitizeData(data) {
  if (!data || typeof data !== 'object') return undefined;
  const out = {};
  for (const [k, v] of Object.entries(data)) {
    if (v == null) continue;
    if (typeof v === 'string') out[k] = v;
    else if (typeof v === 'number' || typeof v === 'boolean') out[k] = String(v);
  }
  return Object.keys(out).length ? out : undefined;
}

module.exports = router;
