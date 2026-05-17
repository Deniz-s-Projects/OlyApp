const fs = require('fs');
const path = require('path');
const request = require('supertest');
const express = require('express');
const { imageUploader } = require('../middleware/uploads');
const errorHandler = require('../middleware/errorHandler');

const UPLOAD_DIR = path.join(__dirname, '..', 'uploads');
const createdFiles = [];

function rememberCreated(res) {
  if (res.body && res.body.filename) createdFiles.push(res.body.filename);
}

afterAll(() => {
  for (const name of createdFiles) {
    try {
      fs.unlinkSync(path.join(UPLOAD_DIR, name));
    } catch (_) {
      // already gone — ignore
    }
  }
});

function buildApp({ maxBytes } = {}) {
  const app = express();
  const upload = imageUploader(maxBytes ? { maxBytes } : undefined);
  app.post('/upload', upload.single('image'), (req, res) => {
    res.status(200).json({ filename: req.file && req.file.filename });
  });
  app.use(errorHandler);
  return app;
}

describe('Upload error classification', () => {
  test('accepts a valid PNG', async () => {
    const app = buildApp();
    // 8-byte PNG signature is enough for Multer to accept the part; the MIME
    // type comes from the supertest `contentType` argument, not the bytes.
    const pngHeader = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);
    const res = await request(app)
      .post('/upload')
      .attach('image', pngHeader, { filename: 'pixel.png', contentType: 'image/png' });
    expect(res.status).toBe(200);
    expect(res.body.filename).toMatch(/\.png$/);
    rememberCreated(res);
  });

  test('rejects an unsupported MIME type with 400', async () => {
    const app = buildApp();
    const res = await request(app)
      .post('/upload')
      .attach('image', Buffer.from('hello'), {
        filename: 'note.txt',
        contentType: 'text/plain',
      });
    expect(res.status).toBe(400);
    expect(res.body.error).toMatch(/Unsupported file type/);
  });

  test('rejects an oversize file with 413', async () => {
    const app = buildApp({ maxBytes: 10 });
    const res = await request(app)
      .post('/upload')
      .attach('image', Buffer.alloc(64, 0xff), {
        filename: 'big.png',
        contentType: 'image/png',
      });
    expect(res.status).toBe(413);
    expect(res.body.error).toMatch(/File too large|file size/i);
  });
});
