function statusFor(err) {
  if (err.status) return err.status;
  if (err.name === 'MulterError') {
    return err.code === 'LIMIT_FILE_SIZE' || err.code === 'LIMIT_FILE_COUNT'
      ? 413
      : 400;
  }
  if (err.name === 'ValidationError') return 400;
  return 500;
}

function errorHandler(err, req, res, next) {
  const status = statusFor(err);
  if (status >= 500) {
    console.error(err);
  }
  res.status(status).json({ error: err.message });
}

module.exports = errorHandler;
