const express = require("express");
const router = express.Router();
const { authenticateToken, isAdmin } = require("../middleware/auth");
const User = require("../models/User");
const Event = require("../models/Event");
const multer = require('multer');
const path = require('path');
const fs = require('fs/promises');

// Reuse the same multer configuration from events.js
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, path.join(__dirname, '../../public/uploads/'))
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9)
    cb(null, uniqueSuffix + path.extname(file.originalname))
  }
});

const upload = multer({ 
  storage: storage,
  limits: { fileSize: 10 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    const filetypes = /jpeg|jpg|png|gif/;
    const mimetype = filetypes.test(file.mimetype);
    const extname = filetypes.test(path.extname(file.originalname).toLowerCase());
    if (mimetype && extname) {
      return cb(null, true);
    }
    cb(new Error('Only image files are allowed!'));
  }
});

// Get all events (admin view)
router.get("/events", authenticateToken, isAdmin, async (req, res) => {
  try {
    const events = await Event.find()
      .populate("creator", "name email")
      .populate("registeredUsers", "name email");
    res.json(events);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get single event (admin view)
router.get("/events/:id", authenticateToken, isAdmin, async (req, res) => {
  try {
    const event = await Event.findById(req.params.id)
      .populate("creator", "name email")
      .populate("registeredUsers", "name email");
    if (!event) {
      return res.status(404).json({ error: "Event not found" });
    }
    res.json(event);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Create event (admin)
router.post("/events", authenticateToken, isAdmin, upload.single('image'), async (req, res) => {
  try {
    const eventData = {
      ...req.body,
      creator: req.user.id,
      isAdminEvent: true
    };

    if (req.file) {
      eventData.image = `uploads/${req.file.filename}`;
    }

    const event = await Event.create(eventData);
    res.status(201).json(event);
  } catch (error) {
    if (error.name === 'ValidationError') {
      const messages = Object.values(error.errors).map(err => err.message);
      return res.status(400).json({ error: messages.join(', ') });
    }
    res.status(400).json({ error: error.message });
  }
});

// Update event (admin)
router.put("/events/:id", authenticateToken, isAdmin, upload.single('image'), async (req, res) => {
  try {
    const event = await Event.findById(req.params.id);
    if (!event) {
      return res.status(404).json({ error: "Event not found" });
    }

    const updates = { ...req.body };
    if (req.file) {
      if (event.image) {
        const oldImagePath = path.join(__dirname, '../../public', event.image);
        try {
          await fs.unlink(oldImagePath);
        } catch (error) {
          console.error('Error deleting old image:', error);
        }
      }
      updates.image = `uploads/${req.file.filename}`;
    }

    const updatedEvent = await Event.findByIdAndUpdate(
      req.params.id,
      updates,
      { new: true, runValidators: true }
    ).populate("creator", "name email");
    
    res.json(updatedEvent);
  } catch (error) {
    if (error.name === 'ValidationError') {
      const messages = Object.values(error.errors).map(err => err.message);
      return res.status(400).json({ error: messages.join(', ') });
    }
    res.status(400).json({ error: error.message });
  }
});

// Delete event (admin)
router.delete("/events/:id", authenticateToken, isAdmin, async (req, res) => {
  try {
    const event = await Event.findById(req.params.id);
    if (!event) {
      return res.status(404).json({ error: "Event not found" });
    }

    if (event.image) {
      const imagePath = path.join(__dirname, '../../public', event.image);
      try {
        await fs.unlink(imagePath);
      } catch (error) {
        console.error('Error deleting image:', error);
      }
    }

    await event.deleteOne();
    res.json({ message: "Event deleted successfully" });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get all users
router.get("/users", authenticateToken, isAdmin, async (req, res) => {
  try {
    const users = await User.find({}, '-password')
      .populate('registeredEvents', 'title date');
    res.json(users);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Update user
router.put("/users/:id", authenticateToken, isAdmin, async (req, res) => {
  try {
    const updatedUser = await User.findByIdAndUpdate(
      req.params.id,
      { $set: req.body },
      { new: true, runValidators: true }
    ).select('-password');
    
    if (!updatedUser) {
      return res.status(404).json({ error: "User not found" });
    }
    
    res.json(updatedUser);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Delete user
router.delete("/users/:id", authenticateToken, isAdmin, async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    // Remove user from all events they're registered for
    await Event.updateMany(
      { registeredUsers: user._id },
      { $pull: { registeredUsers: user._id } }
    );

    // Delete all events created by this user
    const userEvents = await Event.find({ creator: user._id });
    for (const event of userEvents) {
      if (event.image) {
        const imagePath = path.join(__dirname, '../../public', event.image);
        try {
          await fs.unlink(imagePath);
        } catch (error) {
          console.error('Error deleting event image:', error);
        }
      }
      await event.deleteOne();
    }

    await user.deleteOne();
    res.json({ message: "User deleted successfully" });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get dashboard stats
router.get("/dashboard/stats", authenticateToken, isAdmin, async (req, res) => {
  try {
    const totalUsers = await User.countDocuments();
    const totalEvents = await Event.countDocuments();
    const upcomingEvents = await Event.countDocuments({ date: { $gt: new Date() } });
    const pastEvents = await Event.countDocuments({ date: { $lte: new Date() } });

    res.json({
      totalUsers,
      totalEvents,
      upcomingEvents,
      pastEvents
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get all registrations with full details
router.get("/registrations", authenticateToken, isAdmin, async (req, res) => {
  try {
    // First, get all events with populated user data
    const events = await Event.aggregate([
      {
        $unwind: "$registeredUsers" // Deconstruct the registeredUsers array
      },
      {
        $lookup: {
          from: 'users',
          let: { userId: "$registeredUsers.user" },
          pipeline: [
            {
              $match: {
                $expr: { $eq: ["$_id", "$$userId"] }
              }
            },
            {
              $project: {
                name: 1,
                email: 1,
                profileImage: 1
              }
            }
          ],
          as: 'userInfo'
        }
      },
      {
        $lookup: {
          from: 'users',
          let: { creatorId: "$creator" },
          pipeline: [
            {
              $match: {
                $expr: { $eq: ["$_id", "$$creatorId"] }
              }
            },
            {
              $project: {
                name: 1,
                email: 1
              }
            }
          ],
          as: 'creatorInfo'
        }
      },
      {
        $project: {
          eventId: "$_id",
          eventTitle: "$title",
          eventDate: "$date",
          eventImage: "$image",
          registrationDate: "$registeredUsers.registrationDate",
          user: { $arrayElemAt: ["$userInfo", 0] },
          creator: { $arrayElemAt: ["$creatorInfo", 0] }
        }
      }
    ]);

    // Transform the aggregation result into the expected format
    const registrations = events.map(event => ({
      eventId: event.eventId,
      eventTitle: event.eventTitle,
      eventDate: event.eventDate,
      eventImage: event.eventImage,
      userId: event.user?._id,
      userName: event.user?.name || 'Unknown User',
      userEmail: event.user?.email || '',
      userImage: event.user?.profileImage,
      registrationDate: event.registrationDate,
      eventCreator: event.creator?.name || 'Unknown'
    })).filter(reg => reg.userId); // Filter out any registrations without valid users

    console.log('Found registrations:', registrations.length);
    res.json(registrations);
  } catch (error) {
    console.error('Registration fetch error:', error);
    res.status(500).json({ error: error.message });
  }
});

module.exports = router; 