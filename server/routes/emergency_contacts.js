const express = require('express');
const EmergencyContact = require('../models/EmergencyContact');
const auth = require('../middleware/auth');

const router = express.Router();
router.use(auth);

// GET /emergency_contacts - list contacts
router.get('/', async (req, res) => {
  try {
    const contacts = await EmergencyContact.find();
    res.json({ data: contacts });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /emergency_contacts - create contact
router.post('/', async (req, res) => {
  try {
    const contact = await EmergencyContact.create(req.body);
    res.status(201).json({ data: contact });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// PUT /emergency_contacts/:id - update contact
router.put('/:id', async (req, res) => {
  try {
    const contact = await EmergencyContact.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true }
    );
    if (!contact) return res.status(404).json({ error: 'Contact not found' });
    res.json({ data: contact });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// DELETE /emergency_contacts/:id - remove contact
router.delete('/:id', async (req, res) => {
  try {
    const contact = await EmergencyContact.findByIdAndDelete(req.params.id);
    if (!contact) return res.status(404).json({ error: 'Contact not found' });
    res.json({ data: contact });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;
