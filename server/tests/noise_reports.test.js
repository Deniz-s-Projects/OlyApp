const request = require('supertest');
const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');
const express = require('express');
const jwt = require('jsonwebtoken');
const apiRouter = require('../api');
const User = require('../models/User');

const SECRET = process.env.JWT_SECRET || 'secretkey';

function tokenFor(id) {
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

describe('NoiseReports API', () => {
  test('POST creates report and GET requires admin', async () => {
    const user = await User.create({ name: 'u', email: 'u@t.c', passwordHash: 'x' });
    const admin = await User.create({ name: 'a', email: 'a@t.c', passwordHash: 'x', isAdmin: true });

    const userToken = tokenFor(user._id);
    const adminToken = tokenFor(admin._id);

    const create = await request(app)
      .post('/api/noise_reports')
      .set('Authorization', `Bearer ${userToken}`)
      .send({ location: 'Bldg 1', description: 'Loud music' });
    expect(create.status).toBe(201);

    const nonAdminList = await request(app)
      .get('/api/noise_reports')
      .set('Authorization', `Bearer ${userToken}`);
    expect(nonAdminList.status).toBe(403);

    const list = await request(app)
      .get('/api/noise_reports')
      .set('Authorization', `Bearer ${adminToken}`);
    expect(list.status).toBe(200);
    expect(list.body.data).toHaveLength(1);
    expect(list.body.data[0].location).toBe('Bldg 1');
  });
});
