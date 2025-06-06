const request = require('supertest');
const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');
const express = require('express');
const jwt = require('jsonwebtoken');
const apiRouter = require('../api');
const User = require('../models/User');
const bcrypt = require('bcryptjs');

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

describe('Users API', () => {
  test('PUT /users/me updates profile', async () => {
    const hash = await bcrypt.hash('pass', 1);
    const user = await User.create({
      name: 'Old',
      email: 'old@test.com',
      passwordHash: hash,
    });
    const token = jwt.sign({ userId: user._id.toString() }, SECRET);

    const res = await request(app)
      .put('/api/users/me')
      .set('Authorization', `Bearer ${token}`)
      .send({ name: 'New', email: 'new@test.com', avatarUrl: 'pic' });

    expect(res.status).toBe(200);
    expect(res.body.data.name).toBe('New');
    const updated = await User.findById(user._id);
    expect(updated.name).toBe('New');
    expect(updated.email).toBe('new@test.com');
    expect(updated.avatarUrl).toBe('pic');
  });

  test('DELETE /users/me removes account', async () => {
    const hash = await bcrypt.hash('pass', 1);
    const user = await User.create({
      name: 'Del',
      email: 'del@test.com',
      passwordHash: hash,
    });
    const token = jwt.sign({ userId: user._id.toString() }, SECRET);

    const res = await request(app)
      .delete('/api/users/me')
      .set('Authorization', `Bearer ${token}`);

    expect(res.status).toBe(200);
    const remaining = await User.findById(user._id);
    expect(remaining).toBeNull();
  });
});
