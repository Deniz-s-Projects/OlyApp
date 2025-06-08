const request = require('supertest');
const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');
const express = require('express');
const jwt = require('jsonwebtoken');
const apiRouter = require('../api');
const User = require('../models/User');
const bcrypt = require('bcryptjs');
const crypto = require('crypto');

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

describe('Auth API', () => {
  test('registers and logs in a user', async () => {
    const reg = await request(app)
      .post('/api/auth/register')
      .send({ name: 'Test', email: 'a@b.c', password: 'pass' });
    expect(reg.status).toBe(201);
    expect(reg.body).toHaveProperty('token');
    expect(() => jwt.verify(reg.body.token, SECRET)).not.toThrow();
    expect(reg.body.user.email).toBe('a@b.c');

    const res = await request(app)
      .post('/api/auth/login')
      .send({ email: 'a@b.c', password: 'pass' });
    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty('token');
    expect(() => jwt.verify(res.body.token, SECRET)).not.toThrow();
    expect(res.body.user.email).toBe('a@b.c');
  });

  test('invalid credentials return HTTP 401', async () => {
    await request(app)
      .post('/api/auth/register')
      .send({ name: 'Test', email: 'x@y.z', password: 'pass' });

    const res = await request(app)
      .post('/api/auth/login')
      .send({ email: 'x@y.z', password: 'wrong' });
    expect(res.status).toBe(401);
    expect(res.body).toEqual({ error: 'Invalid credentials' });
  });

  test('POST /auth/reset stores hashed token', async () => {
    await request(app)
      .post('/api/auth/register')
      .send({ name: 'Test', email: 'reset@test.com', password: 'pass' });

    const res = await request(app)
      .post('/api/auth/reset')
      .send({ email: 'reset@test.com' });
    expect(res.status).toBe(200);

    const user = await User.findOne({ email: 'reset@test.com' });
    expect(user.passwordResetToken).toHaveLength(64);
  });

  test('POST /auth/reset/confirm accepts unhashed token', async () => {
    const token = crypto.randomBytes(20).toString('hex');
    const hashed = crypto.createHash('sha256').update(token).digest('hex');
    const hash = await bcrypt.hash('old', 1);
    const user = await User.create({
      name: 'R',
      email: 'confirm@test.com',
      passwordHash: hash,
      passwordResetToken: hashed,
      passwordResetExpires: new Date(Date.now() + 3600_000),
    });

    const res = await request(app)
      .post('/api/auth/reset/confirm')
      .send({ token, password: 'newpass' });
    expect(res.status).toBe(200);

    const updated = await User.findById(user._id);
    const match = await bcrypt.compare('newpass', updated.passwordHash);
    expect(match).toBe(true);
    expect(updated.passwordResetToken).toBeUndefined();
    expect(updated.passwordResetExpires).toBeUndefined();
  });
});
