const Joi = require('joi');

const registerSchema = Joi.object({
  name: Joi.string().required(),
  email: Joi.string().email({ tlds: { allow: false } }).required(),
  password: Joi.string().min(1).required(),
  avatarUrl: Joi.string().allow(''),
  isAdmin: Joi.boolean(),
  bio: Joi.string().allow(''),
  room: Joi.string().allow(''),
});

const loginSchema = Joi.object({
  email: Joi.string().email({ tlds: { allow: false } }).required(),
  password: Joi.string().min(1).required(),
});

module.exports = { registerSchema, loginSchema };
