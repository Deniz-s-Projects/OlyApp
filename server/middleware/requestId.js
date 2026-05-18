const { randomUUID } = require('crypto');

// Attach a stable per-request UUID for log correlation. Honors a caller-
// supplied X-Request-ID header so external systems (load balancer, CDN)
// can stitch traces across hops. Always echoes the id in the response.
function requestId(req, res, next) {
  const incoming = req.get('X-Request-ID');
  const id = incoming && /^[A-Za-z0-9_-]{1,128}$/.test(incoming)
    ? incoming
    : randomUUID();
  req.id = id;
  res.setHeader('X-Request-ID', id);
  next();
}

module.exports = requestId;
