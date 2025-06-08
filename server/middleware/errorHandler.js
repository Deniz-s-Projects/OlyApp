function errorHandler(err, req, res, next) {
  // Log unexpected errors for debugging
  if (!err.status || err.status >= 500) {
    console.error(err);
  }
  const status = err.status || (err.name === 'ValidationError' ? 400 : 500);
  res.status(status).json({ error: err.message });
}

module.exports = errorHandler;
