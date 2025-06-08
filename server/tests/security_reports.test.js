const request = require('supertest');
const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');
const express = require('express');
const jwt = require('jsonwebtoken');
const apiRouter = require('../api');

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

describe('SecurityReports API', () => {
  test('POST creates and GET lists reports', async () => {
    const token = getToken();
    const create = await request(app)
      .post('/api/security_reports')
      .set('Authorization', `Bearer ${token}`)
      .send({ description: 'Test issue', location: 'Lobby' });
    expect(create.status).toBe(201);

    const list = await request(app)
      .get('/api/security_reports')
      .set('Authorization', `Bearer ${token}`);
    expect(list.status).toBe(200);
    expect(list.body.data).toHaveLength(1);
    expect(list.body.data[0].location).toBe('Lobby');
  });
});
