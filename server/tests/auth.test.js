const request = require('supertest');
const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');
const express = require('express');
const apiRouter = require('../api');

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
    expect(reg.body.user.email).toBe('a@b.c');

    const res = await request(app)
      .post('/api/auth/login')
      .send({ email: 'a@b.c', password: 'pass' });
    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty('token');
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
});
