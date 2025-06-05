const request = require('supertest');
const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');
const express = require('express');
const apiRouter = require('../api');
const BookingSlot = require('../models/BookingSlot');

function getToken(id = 1) {
  return Buffer.from(`${id}:${Date.now()}`).toString('base64');
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
    await BookingSlot.create([{ time: t1 }, { time: t2, name: 'Bob' }, { time: t3 }]);

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

    const second = await request(app)
      .post('/api/bookings')
      .set('Authorization', `Bearer ${token}`)
      .send({ time: time.toISOString(), name: 'Bob' });
    expect(second.status).toBe(400);

    const slot = await BookingSlot.findOne({ time });
    expect(slot.name).toBe('Alice');
  });
});
