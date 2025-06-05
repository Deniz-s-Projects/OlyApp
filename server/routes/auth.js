const express = require('express');
const router = express.Router();

// Simple in-memory user store
const users = [
  { id: 1, name: 'Test User', email: 'user@example.com', password: 'password', avatarUrl: null, isAdmin: false },
  { id: 2, name: 'Admin User', email: 'admin@example.com', password: 'admin', avatarUrl: null, isAdmin: true }
];

router.post('/login', (req, res) => {
  const { email, password } = req.body;
  const user = users.find(u => u.email === email && u.password === password);
  if (!user) return res.status(401).json({ error: 'Invalid credentials' });
  // Generate simple token (for demo purposes only)
  const token = Buffer.from(`${user.id}:${Date.now()}`).toString('base64');
  const { id, name, avatarUrl, isAdmin } = user;
  res.json({ token, user: { id, name, email, avatarUrl, isAdmin } });
});

module.exports = router;
