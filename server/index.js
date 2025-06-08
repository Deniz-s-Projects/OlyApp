require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const { MongoMemoryServer } = require('mongodb-memory-server');
const path = require('path');
const admin = require('firebase-admin');
const cron = require('node-cron');
const Event = require('./models/Event');
const http = require('http');
const websocket = require('./socket');

const app = express();
app.use(cors());
app.use(helmet());
app.use(express.json());
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));
admin.initializeApp();

async function connectToDatabase() {
  if (process.env.MONGODB_URI) {
    await mongoose.connect(process.env.MONGODB_URI);
  } else {
    const memoryServer = await MongoMemoryServer.create();
    await mongoose.connect(memoryServer.getUri());
    console.log('Using in-memory MongoDB instance');
  }
}

connectToDatabase().catch((err) => {
  console.error('MongoDB connection error:', err);
  process.exit(1);
});

const apiRouter = require('./api');
const authLimiter = rateLimit({ windowMs: 15 * 60 * 1000, max: 100 });
app.use('/api/auth', authLimiter);
app.use('/api', apiRouter);

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
        console.error('Failed to send reminder', err);
      }
    }
  } catch (err) {
    console.error('Reminder check failed', err);
  }
});

const PORT = process.env.PORT || 3000;
const server = http.createServer(app);
websocket.init(server);
server.listen(PORT, () => {
  console.log(`Server listening on port ${PORT}`);
});

module.exports = app;
