const express = require('express');
const router = express.Router();
const authRouter = require('../routes/auth');
const eventsRouter = require('../routes/events');
const itemsRouter = require('../routes/items');
const maintenanceRouter = require('../routes/maintenance');
const bookingsRouter = require('../routes/bookings'); 
const bulletinRouter = require('../routes/bulletin');
const pinsRouter = require('../routes/pins');
const notificationsRouter = require('../routes/notifications');
const usersRouter = require('../routes/users');

router.get('/', (req, res) => {
  res.json({ message: 'API is running' });
});

router.use('/auth', authRouter);
router.use('/events', eventsRouter);
router.use('/items', itemsRouter);
router.use('/maintenance', maintenanceRouter);
router.use('/bookings', bookingsRouter); 
router.use('/bulletin', bulletinRouter);
router.use('/pins', pinsRouter);
router.use('/notifications', notificationsRouter);
router.use('/users', usersRouter);
module.exports = router;
