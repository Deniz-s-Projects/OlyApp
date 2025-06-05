const express = require('express');
const router = express.Router();
const authRouter = require('../routes/auth');

router.get('/', (req, res) => {
  res.json({ message: 'API is running' });
});

router.use('/auth', authRouter);

module.exports = router;
