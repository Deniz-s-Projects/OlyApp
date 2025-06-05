const request = require('supertest');
const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');
const express = require('express');
const apiRouter = require('../api');
const MapPin = require('../models/MapPin');

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

describe('Pins API', () => {
  test('GET /pins returns list', async () => {
    await MapPin.create({
      id: '1',
      title: 'Dorm',
      lat: 0,
      lon: 0,
      category: 'building',
    });
    const res = await request(app).get('/api/pins');
    expect(res.status).toBe(200);
    expect(res.body.data).toHaveLength(1);
    expect(res.body.data[0].title).toBe('Dorm');
  });

  test('POST /pins creates pin', async () => {
    const res = await request(app)
      .post('/api/pins')
      .send({ id: '2', title: 'Cafe', lat: 1, lon: 1, category: 'food' });
    expect(res.status).toBe(201);
    expect(res.body.data.title).toBe('Cafe');
  });

  test('DELETE /pins/:id removes pin', async () => {
    await MapPin.create({
      id: '3',
      title: 'Hall',
      lat: 2,
      lon: 2,
      category: 'venue',
    });
    const res = await request(app).delete('/api/pins/3');
    expect(res.status).toBe(200);
    const remaining = await MapPin.find();
    expect(remaining).toHaveLength(0);
  });
});
