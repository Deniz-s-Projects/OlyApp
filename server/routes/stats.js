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
const mongoose = require('mongoose');

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

router.get('/monthly', async (req, res) => {
  try {
    const now = new Date();
    const months = [];
    for (let i = 11; i >= 0; i--) {
      const start = new Date(now.getFullYear(), now.getMonth() - i, 1);
      const end = new Date(start.getFullYear(), start.getMonth() + 1, 1);
      months.push({ start, end });
    }

    const data = { users: [], events: [], maintenance: [] };
    for (const { start, end } of months) {
      const startId = new mongoose.Types.ObjectId(start);
      const endId = new mongoose.Types.ObjectId(end);
      const [users, events, maintenance] = await Promise.all([
        User.countDocuments({ _id: { $gte: startId, $lt: endId } }),
        Event.countDocuments({ createdAt: { $gte: start, $lt: end } }),
        MaintenanceRequest.countDocuments({ createdAt: { $gte: start, $lt: end } }),
      ]);
      data.users.push(users);
      data.events.push(events);
      data.maintenance.push(maintenance);
    }

    res.json({ data });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
