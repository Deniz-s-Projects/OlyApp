const express = require('express');
const request = require('supertest');
const errorHandler = require('../middleware/errorHandler');
const requestId = require('../middleware/requestId');

function makeApp(throwErr) {
  const app = express();
  app.use(requestId);
  app.use(express.json({ limit: '2mb' }));
  app.get('/boom', (req, res, next) => next(throwErr));
  app.post('/boom', (req, res) => res.json({ ok: true }));
  app.use(errorHandler);
  return app;
}

describe('errorHandler', () => {
  test('returns 400 + validation_failed code for ValidationError', async () => {
    const err = new Error('subject is required');
    err.name = 'ValidationError';
    const app = makeApp(err);

    const res = await request(app).get('/boom');
    expect(res.status).toBe(400);
    expect(res.body).toEqual(
      expect.objectContaining({
        error: 'subject is required',
        code: 'validation_failed',
      }),
    );
    expect(res.body.requestId).toMatch(/^[0-9a-f-]+$/);
    expect(res.headers['x-request-id']).toBe(res.body.requestId);
  });

  test('returns 413 + file_too_large for Multer LIMIT_FILE_SIZE', async () => {
    const err = new Error('File too large');
    err.name = 'MulterError';
    err.code = 'LIMIT_FILE_SIZE';
    const app = makeApp(err);

    const res = await request(app).get('/boom');
    expect(res.status).toBe(413);
    expect(res.body.code).toBe('file_too_large');
  });

  test('classifies CORS rejections as 403 + cors_blocked', async () => {
    const err = new Error('Origin https://bad.example not allowed by CORS');
    err.status = 403;
    const app = makeApp(err);

    const res = await request(app).get('/boom');
    expect(res.status).toBe(403);
    expect(res.body.code).toBe('cors_blocked');
  });

  test('falls back to 500 + internal for unclassified errors', async () => {
    const err = new Error('database melted');
    const app = makeApp(err);

    const res = await request(app).get('/boom');
    expect(res.status).toBe(500);
    expect(res.body.code).toBe('internal');
  });

  test('rejects oversized bodies with request_too_large (413)', async () => {
    const app = makeApp(null);
    const big = 'a'.repeat(3 * 1024 * 1024);
    const res = await request(app)
      .post('/boom')
      .set('Content-Type', 'application/json')
      .send(`{"big":"${big}"}`);
    expect(res.status).toBe(413);
    expect(res.body.code).toBe('request_too_large');
  });

  test('honors incoming X-Request-ID', async () => {
    const err = new Error('boom');
    const app = makeApp(err);

    const res = await request(app)
      .get('/boom')
      .set('X-Request-ID', 'trace-123');
    expect(res.headers['x-request-id']).toBe('trace-123');
    expect(res.body.requestId).toBe('trace-123');
  });
});
