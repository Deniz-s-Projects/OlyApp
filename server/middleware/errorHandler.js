const logger = require('../logger');

// Best-effort categorisation. The client uses `error.code` (not the human
// message) to render localized strings, so adding a new category here is
// preferable to inventing new shapes downstream.
function classify(err) {
  if (err.name === 'MulterError') {
    if (err.code === 'LIMIT_FILE_SIZE' || err.code === 'LIMIT_FILE_COUNT') {
      return { status: 413, code: 'file_too_large' };
    }
    return { status: 400, code: 'upload_invalid' };
  }
  if (err.name === 'ValidationError' || err.isJoi) {
    return { status: 400, code: 'validation_failed' };
  }
  if (err.type === 'entity.too.large') {
    return { status: 413, code: 'request_too_large' };
  }
  if (err.code === 'cors_blocked' || /not allowed by CORS/.test(err.message || '')) {
    return { status: 403, code: 'cors_blocked' };
  }
  if (err.status === 401 || err.name === 'UnauthorizedError') {
    return { status: 401, code: 'unauthorized' };
  }
  if (err.status && err.status >= 400 && err.status < 500) {
    return { status: err.status, code: err.code || 'bad_request' };
  }
  return { status: err.status || 500, code: 'internal' };
}

function errorHandler(err, req, res, next) {
  const { status, code } = classify(err);
  const logPayload = {
    requestId: req.id,
    status,
    code,
    method: req.method,
    path: req.originalUrl,
  };
  if (status >= 500) {
    logger.error(err.message, { ...logPayload, stack: err.stack });
  } else {
    logger.warn(err.message, logPayload);
  }
  // Backwards-compatible shape: `error` stays a string so existing Flutter
  // clients (api_service.dart:36) keep working. `code` and `requestId` are
  // additive — newer clients can use them for localization / log search.
  res.status(status).json({
    error: err.message,
    code,
    requestId: req.id,
  });
}

module.exports = errorHandler;
