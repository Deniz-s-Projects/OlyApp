const request = require('supertest');
const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');
const express = require('express');
const apiRouter = require('../api');
const Event = require('../models/Event');
const Item = require('../models/Item');
const Message = require('../models/Message');
const MaintenanceRequest = require('../models/MaintenanceRequest');

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

describe('Events API', () => {
  test('GET /events returns list', async () => {
    await Event.create({ title: 'Party', date: new Date(0), location: 'loc1' });
    const res = await request(app).get('/api/events');
    expect(res.status).toBe(200);
    expect(res.body.data).toHaveLength(1);
    expect(res.body.data[0].title).toBe('Party');
  });

  test('POST /events creates event', async () => {
    const res = await request(app)
      .post('/api/events')
      .send({ title: 'Meet', date: new Date(0), location: 'loc2' });
    expect(res.status).toBe(200);
    expect(res.body.data.title).toBe('Meet');
  });

  test('POST /events/:id updates event', async () => {
    const event = await Event.create({ title: 'Old', date: new Date(0) });
    const res = await request(app)
      .post(`/api/events/${event._id}`)
      .send({ title: 'New' });
    expect(res.status).toBe(200);
    expect(res.body.title).toBe('New');
  });

  test('POST /events/:id/rsvp adds attendee', async () => {
    const event = await Event.create({ title: 'Party', date: new Date(0) });
    const res = await request(app)
      .post(`/api/events/${event._id}/rsvp`)
      .send({ userId: 2 });
    expect(res.status).toBe(200);
    const updated = await Event.findById(event._id);
    expect(updated.attendees).toContain(2);
  });

  test('GET /events/:id/attendees returns attendees', async () => {
    const event = await Event.create({
      title: 'Party',
      date: new Date(0),
      attendees: [1, 2]
    });
    const res = await request(app).get(`/api/events/${event._id}/attendees`);
    expect(res.status).toBe(200);
    expect(res.body.data).toEqual([1, 2]);
  });
});

describe('Items API', () => {
  test('GET /items returns list', async () => {
    await Item.create({ ownerId: 1, title: 'Chair' });
    const res = await request(app).get('/api/items');
    expect(res.status).toBe(200);
    expect(res.body.data).toHaveLength(1);
    expect(res.body.data[0].title).toBe('Chair');
  });

  test('POST /items creates item', async () => {
    const res = await request(app)
      .post('/api/items')
      .send({ ownerId: 1, title: 'Table' });
    expect(res.status).toBe(201);
    expect(res.body.data.title).toBe('Table');
  });

  test('GET /items/:id/messages returns messages', async () => {
    const item = await Item.create({ ownerId: 1, title: 'Chair' });
    await Message.create({ requestId: item._id, senderId: 2, content: 'Hi' });
    const res = await request(app).get(`/api/items/${item._id}/messages`);
    expect(res.status).toBe(200);
    expect(res.body).toHaveLength(1);
    expect(res.body[0].content).toBe('Hi');
  });

  test('POST /items/:id/messages creates message', async () => {
    const item = await Item.create({ ownerId: 1, title: 'Chair' });
    const res = await request(app)
      .post(`/api/items/${item._id}/messages`)
      .send({ senderId: 1, content: 'Hello' });
    expect(res.status).toBe(201);
    expect(res.body.content).toBe('Hello');
  });
});

describe('Maintenance API', () => {
  test('GET /maintenance returns list', async () => {
    await MaintenanceRequest.create({
      userId: 1,
      subject: 'Leak',
      description: 'Water'
    });
    const res = await request(app).get('/api/maintenance');
    expect(res.status).toBe(200);
    expect(res.body.data).toHaveLength(1);
    expect(res.body.data[0].subject).toBe('Leak');
  });

  test('POST /maintenance creates request', async () => {
    const res = await request(app)
      .post('/api/maintenance')
      .send({ userId: 1, subject: 'Leak', description: 'Water' });
    expect(res.status).toBe(201);
    expect(res.body.data.subject).toBe('Leak');
  });

  test('GET /maintenance/:id/messages returns messages', async () => {
    const req = await MaintenanceRequest.create({
      userId: 1,
      subject: 'Leak',
      description: 'Water'
    });
    await Message.create({ requestId: req._id, senderId: 2, content: 'Hi' });
    const res = await request(app).get(`/api/maintenance/${req._id}/messages`);
    expect(res.status).toBe(200);
    expect(res.body.data).toHaveLength(1);
    expect(res.body.data[0].content).toBe('Hi');
  });

  test('POST /maintenance/:id/messages creates message', async () => {
    const req = await MaintenanceRequest.create({
      userId: 1,
      subject: 'Leak',
      description: 'Water'
    });
    const res = await request(app)
      .post(`/api/maintenance/${req._id}/messages`)
      .send({ senderId: 1, content: 'Hello' });
    expect(res.status).toBe(201);
    expect(res.body.data.content).toBe('Hello');
  });

  test('POST /maintenance/:id updates status', async () => {
    const req = await MaintenanceRequest.create({
      userId: 1,
      subject: 'Leak',
      description: 'Water'
    });
    const res = await request(app)
      .post(`/api/maintenance/${req._id}`)
      .send({ status: 'closed' });
    expect(res.status).toBe(200);
    expect(res.body.status).toBe('closed');
  });
});
