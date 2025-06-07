const request = require('supertest');
const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');
const express = require('express');
const jwt = require('jsonwebtoken');
const apiRouter = require('../api');
const User = require('../models/User');
const Event = require('../models/Event');
const Item = require('../models/Item');
const ServiceListing = require('../models/ServiceListing');

const SECRET = process.env.JWT_SECRET || 'secretkey';

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

describe('Stats API', () => {
  test('GET /stats returns counts', async () => {
    await User.create({ name: 'u', email: 'u@a.b', passwordHash: 'x' });
    await Event.create({ title: 'e', date: new Date(0) });
    await Item.create({ ownerId: '1', title: 'i' });
    await ServiceListing.create({ userId: '1', title: 's', description: '' });
    const admin = await User.create({ name: 'a', email: 'a@b.c', passwordHash: 'x', isAdmin: true });
    const token = jwt.sign({ userId: admin._id }, SECRET);
    const res = await request(app)
      .get('/api/stats')
      .set('Authorization', `Bearer ${token}`);
    expect(res.status).toBe(200);
    expect(res.body.data.users).toBe(2);
    expect(res.body.data.events).toBe(1);
    expect(res.body.data.items).toBe(1);
    expect(res.body.data.listings).toBe(1);
  });
});
