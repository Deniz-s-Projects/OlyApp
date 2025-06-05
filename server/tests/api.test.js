const request = require('supertest');
const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');
const express = require('express');
const apiRouter = require('../api');
const Event = require('../models/Event');
const Item = require('../models/Item');
const Message = require('../models/Message');
const MaintenanceRequest = require('../models/MaintenanceRequest');
const BulletinPost = require('../models/BulletinPost');
const BulletinComment = require('../models/BulletinComment');

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

describe('Events API', () => {
  test('GET /events returns list', async () => {
    await Event.create({ title: 'Party', date: new Date(0), location: 'loc1' });
    const token = await getToken();
    const res = await request(app)
      .get('/api/events')
      .set('Authorization', `Bearer ${token}`);
    expect(res.status).toBe(200);
    expect(res.body.data).toHaveLength(1);
    expect(res.body.data[0].title).toBe('Party');
  });

  test('POST /events creates event', async () => {
    const token = await getToken();
    const res = await request(app)
      .post('/api/events')
      .set('Authorization', `Bearer ${token}`)
      .send({ title: 'Meet', date: new Date(0), location: 'loc2' });
    expect(res.status).toBe(200);
    expect(res.body.data.title).toBe('Meet');
  });

  test('POST /events/:id updates event', async () => {
    const event = await Event.create({ title: 'Old', date: new Date(0) });
    const token = await getToken();
    const res = await request(app)
      .post(`/api/events/${event._id}`)
      .set('Authorization', `Bearer ${token}`)
      .send({ title: 'New' });
    expect(res.status).toBe(200);
    expect(res.body.data.title).toBe('New');
  });

  test('POST /events/:id/rsvp adds attendee', async () => {
    const event = await Event.create({ title: 'Party', date: new Date(0) });
    const token = await getToken();
    const res = await request(app)
      .post(`/api/events/${event._id}/rsvp`)
      .set('Authorization', `Bearer ${token}`);
    expect(res.status).toBe(200);
    const updated = await Event.findById(event._id);
    expect(updated.attendees).toContain(1);
  });

  test('GET /events/:id/attendees returns attendees', async () => {
    const event = await Event.create({
      title: 'Party',
      date: new Date(0),
      attendees: [1, 2]
    });
    const token = await getToken();
    const res = await request(app)
      .get(`/api/events/${event._id}/attendees`)
      .set('Authorization', `Bearer ${token}`);
    expect(res.status).toBe(200);
    expect(res.body.data).toEqual([1, 2]);
  });
});

describe('Items API', () => {
  test('GET /items returns list', async () => {
    await Item.create({ ownerId: 1, title: 'Chair' });
    const token = await getToken();
    const res = await request(app)
      .get('/api/items')
      .set('Authorization', `Bearer ${token}`);
    expect(res.status).toBe(200);
    expect(res.body.data).toHaveLength(1);
    expect(res.body.data[0].title).toBe('Chair');
  });

  test('POST /items creates item', async () => {
    const token = await getToken();
    const res = await request(app)
      .post('/api/items')
      .set('Authorization', `Bearer ${token}`)
      .send({ title: 'Table' });
    expect(res.status).toBe(201);
    expect(res.body.data.title).toBe('Table');
  });

  test('GET /items/:id/messages returns messages', async () => {
    const item = await Item.create({ ownerId: 1, title: 'Chair' });
    await Message.create({
      requestType: 'Item',
      requestId: item._id,
      senderId: 2,
      content: 'Hi'
    });
    const token = await getToken();
    const res = await request(app)
      .get(`/api/items/${item._id}/messages`)
      .set('Authorization', `Bearer ${token}`);
    expect(res.status).toBe(200);
    expect(res.body).toHaveLength(1);
    expect(res.body[0].content).toBe('Hi');
  });

  test('POST /items/:id/messages creates message', async () => {
    const item = await Item.create({ ownerId: 1, title: 'Chair' });
    const token = await getToken();
    const res = await request(app)
      .post(`/api/items/${item._id}/messages`)
      .set('Authorization', `Bearer ${token}`)
      .send({ content: 'Hello' });
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
    const token = await getToken();
    const res = await request(app)
      .get('/api/maintenance')
      .set('Authorization', `Bearer ${token}`);
    expect(res.status).toBe(200);
    expect(res.body.data).toHaveLength(1);
    expect(res.body.data[0].subject).toBe('Leak');
  });

  test('POST /maintenance creates request', async () => {
    const token = await getToken();
    const res = await request(app)
      .post('/api/maintenance')
      .set('Authorization', `Bearer ${token}`)
      .send({ subject: 'Leak', description: 'Water' });
    expect(res.status).toBe(201);
    expect(res.body.data.subject).toBe('Leak');
  });

  test('GET /maintenance/:id/messages returns messages', async () => {
    const req = await MaintenanceRequest.create({
      userId: 1,
      subject: 'Leak',
      description: 'Water'
    });
    await Message.create({
      requestType: 'MaintenanceRequest',
      requestId: req._id,
      senderId: 2,
      content: 'Hi'
    });
    const token = await getToken();
    const res = await request(app)
      .get(`/api/maintenance/${req._id}/messages`)
      .set('Authorization', `Bearer ${token}`);
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
    const token = await getToken();
    const res = await request(app)
      .post(`/api/maintenance/${req._id}/messages`)
      .set('Authorization', `Bearer ${token}`)
      .send({ content: 'Hello' });
    expect(res.status).toBe(201);
    expect(res.body.data.content).toBe('Hello');
  });

  test('POST /maintenance/:id updates status', async () => {
    const req = await MaintenanceRequest.create({
      userId: 1,
      subject: 'Leak',
      description: 'Water'
    });
    const token = await getToken();
    const res = await request(app)
      .post(`/api/maintenance/${req._id}`)
      .set('Authorization', `Bearer ${token}`)
      .send({ status: 'closed' });
    expect(res.status).toBe(200);
    expect(res.body.status).toBe('closed');
  });
});

describe('Bulletin API', () => {
  test('GET /bulletin returns list', async () => {
    await BulletinPost.create({ id: 1, content: 'Hello' });
    const res = await request(app).get('/api/bulletin');
    expect(res.status).toBe(200);
    expect(res.body.data).toHaveLength(1);
    expect(res.body.data[0].content).toBe('Hello');
  });

  test('POST /bulletin creates post', async () => {
    const res = await request(app)
      .post('/api/bulletin')
      .send({ content: 'New' });
    expect(res.status).toBe(201);
    expect(res.body.data.content).toBe('New');
  });

  test('GET /bulletin/:id/comments returns comments', async () => {
    await BulletinPost.create({ id: 1, content: 'p' });
    await BulletinComment.create({ id: 1, postId: 1, content: 'c' });
    const res = await request(app).get('/api/bulletin/1/comments');
    expect(res.status).toBe(200);
    expect(res.body.data).toHaveLength(1);
    expect(res.body.data[0].content).toBe('c');
  });

  test('POST /bulletin/:id/comments creates comment', async () => {
    await BulletinPost.create({ id: 1, content: 'p' });
    const res = await request(app)
      .post('/api/bulletin/1/comments')
      .send({ content: 'c' });
    expect(res.status).toBe(201);
    expect(res.body.data.content).toBe('c');
  });

  test('PUT /bulletin/:id updates post', async () => {
    await BulletinPost.create({ id: 1, content: 'old' });
    const res = await request(app)
      .put('/api/bulletin/1')
      .send({ content: 'new' });
    expect(res.status).toBe(200);
    expect(res.body.data.content).toBe('new');
  });

  test('DELETE /bulletin/:id deletes post', async () => {
    await BulletinPost.create({ id: 1, content: 'old' });
    const res = await request(app).delete('/api/bulletin/1');
    expect(res.status).toBe(200);
    const posts = await BulletinPost.find();
    expect(posts).toHaveLength(0);
  });
});
