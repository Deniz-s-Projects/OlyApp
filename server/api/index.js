const express = require('express');
const router = express.Router();
const authRouter = require('../routes/auth');
const eventsRouter = require('../routes/events');
const itemsRouter = require('../routes/items');
const maintenanceRouter = require('../routes/maintenance');
const bookingsRouter = require('../routes/bookings');

router.get('/', (req, res) => {
  res.json({ message: 'API is running' });
});

router.use('/auth', authRouter);
router.use('/events', eventsRouter);
router.use('/items', itemsRouter);
router.use('/maintenance', maintenanceRouter);
router.use('/bookings', bookingsRouter);

module.exports = router;
