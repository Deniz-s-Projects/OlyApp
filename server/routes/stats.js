const express = require('express');
const auth = require('../middleware/auth');
const requireAdmin = require('../middleware/requireAdmin');
const User = require('../models/User');
const Event = require('../models/Event');
const Item = require('../models/Item');
const ServiceListing = require('../models/ServiceListing');
const MaintenanceRequest = require('../models/MaintenanceRequest');
const MapPin = require('../models/MapPin');
const LostItem = require('../models/LostItem');
const BookingSlot = require('../models/BookingSlot');
const BulletinPost = require('../models/BulletinPost');
const Poll = require('../models/Poll');

const router = express.Router();
router.use(auth);
router.use(requireAdmin);

router.get('/', async (req, res) => {
  try {
    const [users, events, items, listings, maintenance, pins, lostItems, bookings, bulletinPosts, polls] = await Promise.all([
      User.countDocuments(),
      Event.countDocuments(),
      Item.countDocuments(),
      ServiceListing.countDocuments(),
      MaintenanceRequest.countDocuments(),
      MapPin.countDocuments(),
      LostItem.countDocuments(),
      BookingSlot.countDocuments(),
      BulletinPost.countDocuments(),
      Poll.countDocuments(),
    ]);
    res.json({
      data: {
        users,
        events,
        items,
        listings,
        maintenance,
        pins,
        lostItems,
        bookings,
        bulletinPosts,
        polls,
      }
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
