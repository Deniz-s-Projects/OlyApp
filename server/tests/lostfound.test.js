const request = require('supertest');
const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');
const express = require('express');
const jwt = require('jsonwebtoken');
const apiRouter = require('../api');
const LostItem = require('../models/LostItem');

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

describe('LostFound API', () => {
  test('GET /lostfound filters by query params', async () => {
    await LostItem.create([
      { ownerId: '1', title: 'Lost Phone', type: 'lost' },
      { ownerId: '1', title: 'Found Keys', type: 'found' },
      { ownerId: '1', title: 'Old Wallet', type: 'lost', resolved: true },
    ]);
    const token = getToken();
    const res = await request(app)
      .get('/api/lostfound?search=phone&type=lost&resolved=false')
      .set('Authorization', `Bearer ${token}`);
    expect(res.status).toBe(200);
    expect(res.body.data).toHaveLength(1);
    expect(res.body.data[0].title).toBe('Lost Phone');
  });
});
