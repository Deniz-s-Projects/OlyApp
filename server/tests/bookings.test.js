const request = require('supertest');
const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');
const express = require('express');
const jwt = require('jsonwebtoken');
const apiRouter = require('../api');
const BookingSlot = require('../models/BookingSlot');
const User = require('../models/User');

const SECRET = process.env.JWT_SECRET || 'secretkey';

function getToken(id = 1) {
  return jwt.sign({ userId: id }, SECRET);
}

let app;
let mongo;

beforeAll(async () => {
  mongo = await MongoMemoryServer.create();
  await mongoose.connect(mongo.getUri());
  app = express();
  app.use(express.json());
  app.use('/api', apiRouter);
});

afterEach(async () => {
  await mongoose.connection.db.dropDatabase();
});

afterAll(async () => {
  await mongoose.disconnect();
  await mongo.stop();
});

describe('Bookings API', () => {
  test('GET /bookings/slots returns available slots in ISO string form', async () => {
    const t1 = new Date('2023-01-01T10:00:00Z');
    const t2 = new Date('2023-01-01T11:00:00Z');
    const t3 = new Date('2023-01-01T12:00:00Z');
    await BookingSlot.create([
      { time: t1 },
      { time: t2, name: 'Bob', userId: 2 },
      { time: t3 }
    ]);

    const token = getToken();
    const res = await request(app)
      .get('/api/bookings/slots')
      .set('Authorization', `Bearer ${token}`);
    expect(res.status).toBe(200);
    expect(res.body.data).toEqual([t1.toISOString(), t3.toISOString()]);
  });

  test('POST /bookings reserves a slot and prevents double booking', async () => {
    const time = new Date('2023-01-02T10:00:00Z');
    await BookingSlot.create({ time });

    const token = getToken();
    const first = await request(app)
      .post('/api/bookings')
      .set('Authorization', `Bearer ${token}`)
      .send({ time: time.toISOString(), name: 'Alice' });
    expect(first.status).toBe(200);
    expect(first.body.data.name).toBe('Alice');
    expect(first.body.data.userId).toBe(1);

    const second = await request(app)
      .post('/api/bookings')
      .set('Authorization', `Bearer ${token}`)
      .send({ time: time.toISOString(), name: 'Bob' });
    expect(second.status).toBe(400);

    const slot = await BookingSlot.findOne({ time });
    expect(slot.name).toBe('Alice');
    expect(slot.userId).toBe(1);
  });

  test('GET /bookings/my returns user bookings', async () => {
    const t = new Date('2023-01-03T10:00:00Z');
    const mine = await BookingSlot.create({ time: t, name: 'Me', userId: 1 });
    await BookingSlot.create({ time: new Date('2023-01-03T11:00:00Z'), name: 'Other', userId: 2 });

    const token = getToken();
    const res = await request(app)
      .get('/api/bookings/my')
      .set('Authorization', `Bearer ${token}`);
    expect(res.status).toBe(200);
    expect(res.body.data).toHaveLength(1);
    expect(res.body.data[0]._id).toBe(mine._id.toString());
  });

  test('DELETE /bookings/:id clears booking', async () => {
    const slot = await BookingSlot.create({
      time: new Date('2023-01-04T10:00:00Z'),
      name: 'Delete',
      userId: 1
    });

    const token = getToken();
    const res = await request(app)
      .delete(`/api/bookings/${slot._id}`)
      .set('Authorization', `Bearer ${token}`);
    expect(res.status).toBe(200);
    const updated = await BookingSlot.findById(slot._id);
    expect(updated.name).toBeUndefined();
    expect(updated.userId).toBeUndefined();
  });

  test('GET /bookings returns all slots for admin', async () => {
    const t1 = new Date('2023-01-05T10:00:00Z');
    const t2 = new Date('2023-01-05T11:00:00Z');
    await BookingSlot.create([
      { time: t1, name: 'Alice', userId: 1 },
      { time: t2 }
    ]);

    const admin = await User.create({
      name: 'Admin',
      email: 'admin@test.com',
      passwordHash: 'x',
      isAdmin: true
    });
    const token = jwt.sign({ userId: admin._id }, SECRET);

    const res = await request(app)
      .get('/api/bookings')
      .set('Authorization', `Bearer ${token}`);
    expect(res.status).toBe(200);
    expect(res.body.data).toHaveLength(2);
    expect(res.body.data[0].name).toBe('Alice');
  });
});
