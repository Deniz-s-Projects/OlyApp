const express = require("express");
const Suggestion = require("../models/Suggestion");
const auth = require("../middleware/auth");

const router = express.Router();
router.use(auth);

// GET /suggestions - list suggestions
router.get("/", async (req, res) => {
  try {
    const list = await Suggestion.find();
    res.json({ data: list });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /suggestions - create suggestion
router.post("/", async (req, res) => {
  try {
    const suggestion = await Suggestion.create({
      userId: req.userId,
      content: req.body.content,
    });
    res.status(201).json({ data: suggestion });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// PUT /suggestions/:id - update suggestion
router.put("/:id", async (req, res) => {
  try {
    const suggestion = await Suggestion.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true },
    );
    if (!suggestion) return res.status(404).json({ error: "Not found" });
    res.json({ data: suggestion });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// DELETE /suggestions/:id - delete suggestion
router.delete("/:id", async (req, res) => {
  try {
    await Suggestion.findByIdAndDelete(req.params.id);
    res.json({});
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;
