const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const nodemailer = require('nodemailer');
const User = require('../models/User');
const validate = require('../middleware/validate');
const { registerSchema, loginSchema } = require('../validation/auth');

const SECRET = process.env.JWT_SECRET || 'secretkey';

const transporter = nodemailer.createTransport({
  jsonTransport: true,
});

const router = express.Router();

// POST /auth/register - create user
router.post('/register', validate(registerSchema), async (req, res) => {
  try {
    const { name, email, password, avatarUrl, isAdmin, bio, room } = req.body;
    const existing = await User.findOne({ email });
    if (existing) {
      return res.status(400).json({ error: 'Email already registered' });
    }
    const passwordHash = await bcrypt.hash(password, 10);
    const user = await User.create({
      name,
      email,
      passwordHash,
      avatarUrl,
      isAdmin: !!isAdmin,
      bio: bio || '',
      room: room || '',
    });
    const token = jwt.sign({ userId: user._id.toString() }, SECRET);
    res.status(201).json({
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        avatarUrl: user.avatarUrl,
        isAdmin: user.isAdmin,
        bio: user.bio,
        room: user.room,
      },
    });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// POST /auth/login - verify user
router.post('/login', validate(loginSchema), async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = await User.findOne({ email });
    if (!user) return res.status(401).json({ error: 'Invalid credentials' });
    const match = await bcrypt.compare(password, user.passwordHash);
    if (!match) return res.status(401).json({ error: 'Invalid credentials' });
    const token = jwt.sign({ userId: user._id.toString() }, SECRET);
    res.json({
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        avatarUrl: user.avatarUrl,
        isAdmin: user.isAdmin,
        bio: user.bio,
        room: user.room,
      },
    });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// POST /auth/reset - request password reset token
router.post('/reset', async (req, res) => {
  try {
    const { email } = req.body;
    if (!email) return res.status(400).json({ error: 'Email required' });
    const user = await User.findOne({ email });
    if (!user) {
      // prevent user enumeration
      return res.json({ message: 'If that email exists, a reset link has been sent' });
    }
    const token = crypto.randomBytes(20).toString('hex');
    const hashed = crypto.createHash('sha256').update(token).digest('hex');
    user.passwordResetToken = hashed;
    user.passwordResetExpires = new Date(Date.now() + 3600_000);
    await user.save();
    await transporter.sendMail({
      to: user.email,
      subject: 'Password Reset',
      text: `Your password reset token is: ${token}`,
    });
    res.json({ message: 'Reset email sent' });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// POST /auth/reset/confirm - set new password
router.post('/reset/confirm', async (req, res) => {
  try {
    const { token, password } = req.body;
    if (!token || !password) {
      return res.status(400).json({ error: 'Missing fields' });
    }
    const hashed = crypto.createHash('sha256').update(token).digest('hex');
    const user = await User.findOne({
      passwordResetToken: hashed,
      passwordResetExpires: { $gt: new Date() },
    });
    if (!user) return res.status(400).json({ error: 'Invalid or expired token' });
    user.passwordHash = await bcrypt.hash(password, 10);
    user.passwordResetToken = undefined;
    user.passwordResetExpires = undefined;
    await user.save();
    res.json({ message: 'Password updated' });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;
