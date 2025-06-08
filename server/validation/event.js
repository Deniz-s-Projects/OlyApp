const Joi = require('joi');

const createEventSchema = Joi.object({
  title: Joi.string().required(),
  date: Joi.date().required(),
  description: Joi.string().allow(''),
  attendees: Joi.array().items(Joi.number()),
  deviceTokens: Joi.array().items(Joi.string()),
  checkIns: Joi.array().items(Joi.number()),
  reminderSent: Joi.boolean(),
  location: Joi.string().allow(''),
  category: Joi.string().allow(''),
  repeatInterval: Joi.string().valid('daily', 'weekly', 'monthly', 'yearly'),
  repeatUntil: Joi.date(),
});

const updateEventSchema = createEventSchema.fork(['title', 'date'], schema => schema.optional());

module.exports = { createEventSchema, updateEventSchema };
