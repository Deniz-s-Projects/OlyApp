function requireEnv(name) {
  const value = process.env[name];
  if (!value || value.trim() === '') {
    throw new Error(
      `Missing required environment variable: ${name}. Refuse to start with an insecure default.`
    );
  }
  return value;
}

function parseCorsOrigins(raw) {
  if (!raw || raw.trim() === '') return [];
  if (raw.trim() === '*') return '*';
  return raw
    .split(',')
    .map((s) => s.trim())
    .filter(Boolean);
}

module.exports = {
  jwtSecret: requireEnv('JWT_SECRET'),
  corsOrigins: parseCorsOrigins(process.env.CORS_ORIGINS),
};
