module.exports = function(req, res, next) {
  const header = req.get('Authorization');
  if (!header) {
    return res.status(401).json({ error: 'Unauthorized' });
  }
  const token = header.replace(/^Bearer\s+/i, '').trim();
  try {
    const decoded = Buffer.from(token, 'base64').toString('utf8');
    const [userId] = decoded.split(':');
    if (!userId) {
      throw new Error('Invalid token');
    }
    req.userId = userId;
    next();
  } catch (err) {
    res.status(401).json({ error: 'Invalid token' });
  }
};
