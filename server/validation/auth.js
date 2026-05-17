const Joi = require('joi');

const strongPassword = Joi.string()
  .min(8)
  .pattern(/[A-Za-z]/, 'letter')
  .pattern(/\d/, 'number')
  .required()
  .messages({
    'string.min': 'Password must be at least 8 characters',
    'string.pattern.name': 'Password must contain a {#name}',
  });

const registerSchema = Joi.object({
  name: Joi.string().required(),
  email: Joi.string().email({ tlds: { allow: false } }).required(),
  password: strongPassword,
  avatarUrl: Joi.string().allow(''),
  isAdmin: Joi.boolean(),
  bio: Joi.string().allow(''),
  room: Joi.string().allow(''),
});

// Login intentionally keeps a lenient schema so legacy users (with
// pre-policy passwords) can still authenticate. New/changed passwords
// go through `strongPassword` at register and reset/confirm.
const loginSchema = Joi.object({
  email: Joi.string().email({ tlds: { allow: false } }).required(),
  password: Joi.string().min(1).required(),
});

const resetConfirmSchema = Joi.object({
  token: Joi.string().required(),
  password: strongPassword,
});

module.exports = { registerSchema, loginSchema, resetConfirmSchema };
