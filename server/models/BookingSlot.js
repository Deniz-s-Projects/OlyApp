const mongoose = require('mongoose');

const BookingSlotSchema = new mongoose.Schema({
  time: { type: Date, required: true, unique: true },
  name: { type: String },
  userId: { type: Number }
});

module.exports = mongoose.model('BookingSlot', BookingSlotSchema);
