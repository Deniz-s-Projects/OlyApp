const mongoose = require("mongoose");

const SuggestionSchema = new mongoose.Schema({
  userId: { type: String, required: true },
  content: { type: String, required: true },
  createdAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model("Suggestion", SuggestionSchema);
