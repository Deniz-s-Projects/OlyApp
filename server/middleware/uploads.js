const path = require('path');
const crypto = require('crypto');
const multer = require('multer');

const UPLOAD_DIR = path.join(__dirname, '..', 'uploads');

const IMAGE_MIME_WHITELIST = new Set([
  'image/jpeg',
  'image/png',
  'image/webp',
  'image/gif',
  'image/heic',
  'image/heif',
]);

const DOCUMENT_MIME_WHITELIST = new Set([
  ...IMAGE_MIME_WHITELIST,
  'application/pdf',
  'application/msword',
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  'application/vnd.ms-excel',
  'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  'text/plain',
  'text/csv',
]);

const EXT_BY_MIME = {
  'image/jpeg': '.jpg',
  'image/png': '.png',
  'image/webp': '.webp',
  'image/gif': '.gif',
  'image/heic': '.heic',
  'image/heif': '.heif',
  'application/pdf': '.pdf',
  'application/msword': '.doc',
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document': '.docx',
  'application/vnd.ms-excel': '.xls',
  'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet': '.xlsx',
  'text/plain': '.txt',
  'text/csv': '.csv',
};

function safeExtension(mime, originalName) {
  if (EXT_BY_MIME[mime]) return EXT_BY_MIME[mime];
  const fallback = path.extname(originalName || '').toLowerCase();
  if (/^\.[a-z0-9]{1,8}$/.test(fallback)) return fallback;
  return '';
}

function makeStorage() {
  return multer.diskStorage({
    destination: (req, file, cb) => cb(null, UPLOAD_DIR),
    filename: (req, file, cb) => {
      const random = crypto.randomBytes(16).toString('hex');
      cb(null, `${Date.now()}-${random}${safeExtension(file.mimetype, file.originalname)}`);
    },
  });
}

function makeFileFilter(whitelist) {
  return (req, file, cb) => {
    if (whitelist.has(file.mimetype)) return cb(null, true);
    const err = new Error(`Unsupported file type: ${file.mimetype}`);
    err.status = 400;
    cb(err);
  };
}

function imageUploader({ maxBytes = 5 * 1024 * 1024 } = {}) {
  return multer({
    storage: makeStorage(),
    limits: { fileSize: maxBytes, files: 1 },
    fileFilter: makeFileFilter(IMAGE_MIME_WHITELIST),
  });
}

function documentUploader({ maxBytes = 15 * 1024 * 1024 } = {}) {
  return multer({
    storage: makeStorage(),
    limits: { fileSize: maxBytes, files: 1 },
    fileFilter: makeFileFilter(DOCUMENT_MIME_WHITELIST),
  });
}

module.exports = {
  imageUploader,
  documentUploader,
  IMAGE_MIME_WHITELIST,
  DOCUMENT_MIME_WHITELIST,
};
