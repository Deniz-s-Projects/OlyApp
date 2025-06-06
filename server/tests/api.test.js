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
const EventComment = require('../models/EventComment');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const admin = require('firebase-admin');

jest.spyOn(admin, 'messaging').mockReturnValue({
  sendEachForMulticast: jest.fn().mockResolvedValue({ successCount: 1 }),
});

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
    const admin = await User.create({ name: 'a', email: 'a@b.c', passwordHash: 'x', isAdmin: true });
    const token = jwt.sign({ userId: admin._id }, SECRET); 
    const res = await request(app)
      .post('/api/events')
      .set('Authorization', `Bearer ${token}`)
      .send({ title: 'Meet', date: new Date(0), location: 'loc2' });
    expect(res.status).toBe(200);
    expect(res.body.data.title).toBe('Meet');
  });

  test('PUT /events/:id updates event', async () => {
    const event = await Event.create({ title: 'Old', date: new Date(0) });
    const admin = await User.create({ name: 'a', email: 'a@b.c', passwordHash: 'x', isAdmin: true });
    const token = jwt.sign({ userId: admin._id }, SECRET);
    const res = await request(app)
      .put(`/api/events/${event._id}`)
      .set('Authorization', `Bearer ${token}`)
      .send({ title: 'New' });
    expect(res.status).toBe(200);
    expect(res.body.data.title).toBe('New');
  });

  test('DELETE /events/:id removes event', async () => {
    const event = await Event.create({ title: 'Temp', date: new Date(0) });
    const admin = await User.create({ name: 'a', email: 'a@b.c', passwordHash: 'x', isAdmin: true });
    const token = jwt.sign({ userId: admin._id }, SECRET);

    const res = await request(app)
      .delete(`/api/events/${event._id}`)
      .set('Authorization', `Bearer ${token}`);
    expect(res.status).toBe(200);
    const remaining = await Event.findById(event._id);
    expect(remaining).toBeNull();
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

  test('POST /events/:id/rsvp stores device tokens', async () => {
    const user = await User.create({
      name: 't',
      email: 't@test.com',
      passwordHash: 'x',
      deviceTokens: ['tok1'],
    });
    const event = await Event.create({ title: 'Party', date: new Date(0) });
    const token = jwt.sign({ userId: user._id }, SECRET);
    await request(app)
      .post(`/api/events/${event._id}/rsvp`)
      .set('Authorization', `Bearer ${token}`);
    const updated = await Event.findById(event._id);
    expect(updated.deviceTokens).toContain('tok1');
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

  test('GET /events/:id/comments returns comments', async () => {
    const event = await Event.create({ title: 'Party', date: new Date(0) });
    await EventComment.create({ eventId: event._id, content: 'c' });
    const token = await getToken();
    const res = await request(app)
      .get(`/api/events/${event._id}/comments`)
      .set('Authorization', `Bearer ${token}`);
    expect(res.status).toBe(200);
    expect(res.body.data).toHaveLength(1);
    expect(res.body.data[0].content).toBe('c');
  });

  test('POST /events/:id/comments creates comment', async () => {
    const event = await Event.create({ title: 'Party', date: new Date(0) });
    const token = await getToken();
    const res = await request(app)
      .post(`/api/events/${event._id}/comments`)
      .set('Authorization', `Bearer ${token}`)
      .send({ content: 'c' });
    expect(res.status).toBe(201);
    expect(res.body.data.content).toBe('c');
  });

  test('GET /events/:id/qr returns png', async () => {
    const event = await Event.create({ title: 'Party', date: new Date(0) });
    const token = getToken();
    const res = await request(app)
      .get(`/api/events/${event._id}/qr`)
      .set('Authorization', `Bearer ${token}`);
    expect(res.status).toBe(200);
    expect(res.headers['content-type']).toBe('image/png');
  });

  test('POST /events/:id/checkin records user', async () => {
    const event = await Event.create({ title: 'Party', date: new Date(0) });
    const token = getToken();
    const res = await request(app)
      .post(`/api/events/${event._id}/checkin`)
      .set('Authorization', `Bearer ${token}`);
    expect(res.status).toBe(200);
    const updated = await Event.findById(event._id);
    expect(updated.checkIns).toContain(1);
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

  test('POST /items/:id/ratings adds rating', async () => {
    const item = await Item.create({ ownerId: 1, title: 'Chair' });
    const token = await getToken();
    const res = await request(app)
      .post(`/api/items/${item._id}/ratings`)
      .set('Authorization', `Bearer ${token}`)
      .send({ rating: 5, review: 'Great' });
    expect(res.status).toBe(201);
    const updated = await Item.findById(item._id);
    expect(updated.ratings).toHaveLength(1);
    expect(updated.ratings[0].rating).toBe(5);
  });

  test('GET /items/:id/ratings returns list', async () => {
    const item = await Item.create({
      ownerId: 1,
      title: 'Chair',
      ratings: [{ rating: 4, review: 'Good' }],
    });
    const token = await getToken();
    const res = await request(app)
      .get(`/api/items/${item._id}/ratings`)
      .set('Authorization', `Bearer ${token}`);
    expect(res.status).toBe(200);
    expect(res.body.data).toHaveLength(1);
    expect(res.body.data[0].rating).toBe(4);
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

  test('PUT /maintenance/:id updates status', async () => {
    const req = await MaintenanceRequest.create({
      userId: 1,
      subject: 'Leak',
      description: 'Water'
    });
    const admin = await User.create({ name: 'a', email: 'a@b.c', passwordHash: 'x', isAdmin: true });
    const token = jwt.sign({ userId: admin._id }, SECRET);
    const res = await request(app)
      .put(`/api/maintenance/${req._id}`)
      .set('Authorization', `Bearer ${token}`)
      .send({ status: 'closed' });
    expect(res.status).toBe(200);
    expect(res.body.status).toBe('closed');
  });

  test('DELETE /maintenance/:id removes request', async () => {
    const reqItem = await MaintenanceRequest.create({
      userId: 1,
      subject: 'Leak',
      description: 'Water',
    });
    const admin = await User.create({ name: 'a', email: 'a@b.c', passwordHash: 'x', isAdmin: true });
    const token = jwt.sign({ userId: admin._id }, SECRET);
    const res = await request(app)
      .delete(`/api/maintenance/${reqItem._id}`)
      .set('Authorization', `Bearer ${token}`);
    expect(res.status).toBe(200);
    const remaining = await MaintenanceRequest.findById(reqItem._id);
    expect(remaining).toBeNull();
  });
});

describe('Bulletin API', () => {
  test('GET /bulletin returns list', async () => {
    await BulletinPost.create({ id: 1, userId: 1, content: 'Hello' });
    const token = getToken();
    const res = await request(app)
      .get('/api/bulletin')
      .set('Authorization', `Bearer ${token}`);
    expect(res.status).toBe(200);
    expect(res.body.data).toHaveLength(1);
    expect(res.body.data[0].content).toBe('Hello');
  });

  test('POST /bulletin creates post', async () => {
    const token = getToken();
    const res = await request(app)
      .post('/api/bulletin')
      .set('Authorization', `Bearer ${token}`)
      .send({ content: 'New' });
    expect(res.status).toBe(201);
    expect(res.body.data.content).toBe('New');
  });

  test('GET /bulletin/:id/comments returns comments', async () => {
    await BulletinPost.create({ id: 1, userId: 1, content: 'p' });
    await BulletinComment.create({ id: 1, postId: 1, userId: 1, content: 'c' });
    const token = getToken();
    const res = await request(app)
      .get('/api/bulletin/1/comments')
      .set('Authorization', `Bearer ${token}`);
    expect(res.status).toBe(200);
    expect(res.body.data).toHaveLength(1);
    expect(res.body.data[0].content).toBe('c');
  });

  test('POST /bulletin/:id/comments creates comment', async () => {
    await BulletinPost.create({ id: 1, userId: 1, content: 'p' });
    const token = getToken();
    const res = await request(app)
      .post('/api/bulletin/1/comments')
      .set('Authorization', `Bearer ${token}`)
      .send({ content: 'c' });
    expect(res.status).toBe(201);
    expect(res.body.data.content).toBe('c');
  });

  test('PUT /bulletin/:id updates post', async () => {
    await BulletinPost.create({ id: 1, userId: 1, content: 'old' });
    const token = getToken();
    const res = await request(app)
      .put('/api/bulletin/1')
      .set('Authorization', `Bearer ${token}`)
      .send({ content: 'new' });
    expect(res.status).toBe(200);
    expect(res.body.data.content).toBe('new');
  });

  test('DELETE /bulletin/:id deletes post', async () => {
    await BulletinPost.create({ id: 1, userId: 1, content: 'old' });
    const token = getToken();
    const res = await request(app)
      .delete('/api/bulletin/1')
      .set('Authorization', `Bearer ${token}`);
    expect(res.status).toBe(200);
    const posts = await BulletinPost.find();
    expect(posts).toHaveLength(0);
  });
});

describe('Notifications API', () => {
  test('POST /notifications/broadcast requires admin', async () => {
    const user = await User.create({ name: 'u', email: 'u@b.c', passwordHash: 'x' });
    const token = jwt.sign({ userId: user._id }, SECRET);
    const res = await request(app)
      .post('/api/notifications/broadcast')
      .set('Authorization', `Bearer ${token}`)
      .send({ title: 't', body: 'b' });
    expect(res.status).toBe(403);
  });

  test('POST /notifications/broadcast sends messages', async () => {
    const adminUser = await User.create({ name: 'a', email: 'a@b.c', passwordHash: 'x', isAdmin: true, deviceTokens: ['tok'] });
    const token = jwt.sign({ userId: adminUser._id }, SECRET);

    const res = await request(app)
      .post('/api/notifications/broadcast')
      .set('Authorization', `Bearer ${token}`)
      .send({ title: 't', body: 'b' });
    expect(res.status).toBe(200);
    expect(res.body.successCount).toBeDefined();
  });
});

describe('Directory API', () => {
  test('GET /directory returns listed users', async () => {
    await User.create({
      name: 'Alice',
      email: 'a@b.c',
      passwordHash: 'x',
      isListed: true
    });
    const token = getToken();
    const res = await request(app)
      .get('/api/directory')
      .set('Authorization', `Bearer ${token}`);
    expect(res.status).toBe(200);
    expect(res.body.data).toHaveLength(1);
    expect(res.body.data[0].name).toBe('Alice');
  });

  test('POST /directory/:id/messages creates conversation', async () => {
    const bob = await User.create({
      name: 'Bob',
      email: 'b@c.d',
      passwordHash: 'x',
      isListed: true
    });
    const token = getToken();
    const res = await request(app)
      .post(`/api/directory/${bob._id}/messages`)
      .set('Authorization', `Bearer ${token}`)
      .send({ content: 'Hi' });
    expect(res.status).toBe(201);
    expect(res.body.data.content).toBe('Hi');
    const convoMessages = await Message.find();
    expect(convoMessages).toHaveLength(1);
  });
});
