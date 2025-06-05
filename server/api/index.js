const express = require('express');
const router = express.Router();
const authRouter = require('../routes/auth');
const eventsRouter = require('../routes/events');

router.get('/', (req, res) => {
  res.json({ message: 'API is running' });
});

router.use('/auth', authRouter);
router.use('/events', eventsRouter);

module.exports = router;
