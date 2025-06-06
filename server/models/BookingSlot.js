const mongoose = require('mongoose');

const BookingSlotSchema = new mongoose.Schema({
  time: { type: Date, required: true, unique: true },
  name: { type: String },
  // Store the id of the user who booked the slot as a number to match tests
  userId: { type: Number }
});

module.exports = mongoose.model('BookingSlot', BookingSlotSchema);
