const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  passwordHash: { type: String, required: true },
  avatarUrl: String,
  isAdmin: { type: Boolean, default: false }
});

module.exports = mongoose.model('User', UserSchema);
