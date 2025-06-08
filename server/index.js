require('dotenv').config();
const path = require('path');
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const { createLogger, format, transports } = require('winston');
const morgan = require('morgan');
const { MongoMemoryServer } = require('mongodb-memory-server');
const admin = require('firebase-admin');
const cron = require('node-cron');
const http = require('http');

const apiRouter = require('./api');
const Event = require('./models/Event');
const websocket = require('./socket');
const errorHandler = require('./middleware/errorHandler');

const logger = createLogger({
  level: 'info',
  format: format.combine(
    format.timestamp(),
    format.printf(({ timestamp, level, message }) => `${timestamp} ${level}: ${message}`)
  ),
  transports: [new transports.Console()],
});

const app = express();
app.use(cors());
app.use(helmet());
app.use(express.json());
app.use(morgan('tiny', { stream: { write: (msg) => logger.info(msg.trim()) } }));
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

admin.initializeApp();

async function connectToDatabase() {
  if (process.env.MONGODB_URI) {
    await mongoose.connect(process.env.MONGODB_URI);
  } else {
    const memoryServer = await MongoMemoryServer.create();
    await mongoose.connect(memoryServer.getUri());
    logger.info('Using in-memory MongoDB instance');
  }
}

connectToDatabase().catch((err) => {
  logger.error(`MongoDB connection error: ${err}`);
  process.exit(1);
});

const authLimiter = rateLimit({ windowMs: 15 * 60 * 1000, max: 100 });
app.use('/api/auth', authLimiter);
app.use('/api', apiRouter);
app.use(errorHandler);

// Send event reminders 15 minutes before start
cron.schedule('* * * * *', async () => {
  const now = new Date();
  const target = new Date(now.getTime() + 15 * 60000);
  const nextMinute = new Date(target.getTime() + 60000);
  try {
    const events = await Event.find({
      date: { $gte: target, $lt: nextMinute },
      reminderSent: false,
    });
    for (const event of events) {
      if (!event.deviceTokens.length) continue;
      try {
        await admin.messaging().sendEachForMulticast({
          tokens: event.deviceTokens,
          notification: {
            title: `Upcoming event: ${event.title}`,
            body: 'Starts in 15 minutes',
          },
        });
        event.reminderSent = true;
        await event.save();
      } catch (err) {
        logger.error(`Failed to send reminder: ${err}`);
      }
    }
  } catch (err) {
    logger.error(`Reminder check failed: ${err}`);
  }
});

const PORT = process.env.PORT || 3000;
const server = http.createServer(app);
websocket.init(server);
server.listen(PORT, () => {
  logger.info(`Server listening on port ${PORT}`);
});

module.exports = app;
