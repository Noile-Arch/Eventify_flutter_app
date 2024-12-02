const mongoose = require("mongoose");

const userSchema = new mongoose.Schema({
  email: { type: String, unique: true },
  password: String,
  name: String,
  phone: { type: String, default: '' },
  location: { type: String, default: '' },
  profileImage: String,
  isAdmin: { type: Boolean, default: false },
  registeredEvents: [{ type: mongoose.Schema.Types.ObjectId, ref: "Event" }],
  favoriteEvents: [{ type: mongoose.Schema.Types.ObjectId, ref: "Event" }]
});

module.exports = mongoose.model("User", userSchema);
