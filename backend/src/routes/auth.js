const express = require("express");
const router = express.Router();
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const User = require("../models/User");
const upload = require("../config/upload");
const fs = require("fs/promises");
const path = require("path");
const { authenticateToken } = require("../middleware/auth");

router.post("/register", async (req, res) => {
  try {
    const hashedPassword = await bcrypt.hash(req.body.password, 10);
    const user = await User.create({
      email: req.body.email,
      password: hashedPassword,
      name: req.body.name,
    });
    res.json({ success: true });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

router.post("/login", async (req, res) => {
  const user = await User.findOne({ email: req.body.email });
  if (!user) return res.status(400).json({ error: "User not found" });

  const valid = await bcrypt.compare(req.body.password, user.password);
  if (!valid) return res.status(400).json({ error: "Invalid password" });

  const token = jwt.sign({ userId: user._id }, "your_jwt_secret");
  res.json({
    token,
    user: {
      _id: user._id,
      email: user.email,
      name: user.name,
      isAdmin: user.isAdmin,
      profileImage: user.profileImage ? `/uploads/${user.profileImage}` : null,
    },
  });
});

// Update profile
router.put(
  "/profile",
  authenticateToken,
  upload.single("profileImage"),
  async (req, res) => {
    try {
      const updates = {
        name: req.body.name,
        phone: req.body.phone,
        location: req.body.location,
      };

      if (req.file) {
        const user = await User.findById(req.user.id);
        if (user.profileImage) {
          const oldImagePath = path.join(
            __dirname,
            "..",
            "..",
            "public",
            user.profileImage
          );
          try {
            await fs.unlink(oldImagePath);
          } catch (error) {
            console.error("Error deleting old profile image:", error);
          }
        }
        updates.profileImage = `/uploads/${req.file.filename}`;
      }

      const updatedUser = await User.findByIdAndUpdate(req.user.id, updates, {
        new: true,
      });

      res.json({
        user: {
          id: updatedUser._id,
          email: updatedUser.email,
          name: updatedUser.name,
          phone: updatedUser.phone,
          location: updatedUser.location,
          profileImage: updatedUser.profileImage,
          isAdmin: updatedUser.isAdmin,
        },
      });
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }
);

router.get("/user/me", authenticateToken, async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    res.json({
      _id: user._id,
      email: user.email,
      name: user.name,
      phone: user.phone,
      location: user.location,
      isAdmin: user.isAdmin,
      profileImage: user.profileImage ? `/uploads/${user.profileImage}` : null,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Add this route to check uploads directory
router.get("/check-uploads", async (req, res) => {
  const uploadsPath = path.join(__dirname, "../../public/uploads");
  try {
    const files = await fs.readdir(uploadsPath);
    res.json({
      path: uploadsPath,
      files: files,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
