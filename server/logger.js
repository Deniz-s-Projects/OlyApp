const { createLogger, format, transports } = require('winston');

// Centralized Winston logger. Routes and middleware should require this
// module instead of constructing their own logger so timestamps, levels,
// and transports stay consistent.
const logger = createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: format.combine(
    format.timestamp(),
    format.errors({ stack: true }),
    format.printf((info) => {
      const { timestamp, level, message, requestId, ...rest } = info;
      const extras = Object.keys(rest).length ? ` ${JSON.stringify(rest)}` : '';
      const reqPart = requestId ? ` [${requestId}]` : '';
      return `${timestamp} ${level}${reqPart}: ${message}${extras}`;
    }),
  ),
  transports: [new transports.Console()],
});

module.exports = logger;
