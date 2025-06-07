const express = require('express');
const StudyGroup = require('../models/StudyGroup');
const auth = require('../middleware/auth');

const router = express.Router();
router.use(auth);

// GET /studygroups - list groups
router.get('/', async (req, res) => {
  try {
    const groups = await StudyGroup.find();
    res.json({ data: groups });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /studygroups - create group
router.post('/', async (req, res) => {
  try {
    const group = await StudyGroup.create({
      topic: req.body.topic,
      description: req.body.description,
      meetingTime: req.body.meetingTime,
      creatorId: String(req.userId),
      memberIds: [String(req.userId)]
    });
    res.status(201).json({ data: group });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// GET /studygroups/:id - get group
router.get('/:id', async (req, res) => {
  try {
    const group = await StudyGroup.findById(req.params.id);
    if (!group) return res.status(404).json({ error: 'Study group not found' });
    res.json({ data: group });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// PUT /studygroups/:id - update group
router.put('/:id', async (req, res) => {
  try {
    const data = {
      topic: req.body.topic,
      description: req.body.description,
      meetingTime: req.body.meetingTime,
      memberIds: req.body.memberIds
    };
    const group = await StudyGroup.findByIdAndUpdate(req.params.id, data, { new: true });
    if (!group) return res.status(404).json({ error: 'Study group not found' });
    res.json({ data: group });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// DELETE /studygroups/:id - delete group
router.delete('/:id', async (req, res) => {
  try {
    const group = await StudyGroup.findByIdAndDelete(req.params.id);
    if (!group) return res.status(404).json({ error: 'Study group not found' });
    res.json({ data: group });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// POST /studygroups/:id/join - join group
router.post('/:id/join', async (req, res) => {
  try {
    const group = await StudyGroup.findById(req.params.id);
    if (!group) return res.status(404).json({ error: 'Study group not found' });
    const userId = String(req.userId);
    if (!group.memberIds.includes(userId)) {
      group.memberIds.push(userId);
      await group.save();
    }
    res.json({ data: group });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// POST /studygroups/:id/leave - leave group
router.post('/:id/leave', async (req, res) => {
  try {
    const group = await StudyGroup.findById(req.params.id);
    if (!group) return res.status(404).json({ error: 'Study group not found' });
    const userId = String(req.userId);
    const index = group.memberIds.indexOf(userId);
    if (index !== -1) {
      group.memberIds.splice(index, 1);
      await group.save();
    }
    res.json({ data: group });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;
