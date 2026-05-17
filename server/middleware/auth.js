const jwt = require('jsonwebtoken');
const { jwtSecret: SECRET } = require('../config');

module.exports = function (req, res, next) {
  const header = req.get('Authorization');
  if (!header) {
    return res.status(401).json({ error: 'Unauthorized' });
  }
  const token = header.replace(/^Bearer\s+/i, '').trim();
  try {
    const payload = jwt.verify(token, SECRET);
    req.userId = payload.userId;
    next();
  } catch (err) {
    res.status(401).json({ error: 'Invalid token' });
  }
};
