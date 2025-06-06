const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  passwordHash: { type: String, required: true },
  // Path to user's avatar image under /uploads
  avatarUrl: String,
  isAdmin: { type: Boolean, default: false },
  // Whether the user opted into the public directory
  isListed: { type: Boolean, default: false },
  deviceTokens: { type: [String], default: [] },
  passwordResetToken: String,
  passwordResetExpires: Date,
});

module.exports = mongoose.model('User', UserSchema);
