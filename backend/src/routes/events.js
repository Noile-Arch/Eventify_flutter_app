const express = require("express");
const router = express.Router();
const Event = require("../models/Event");
const User = require("../models/User");
const { authenticateToken } = require("../middleware/auth");
const multer = require("multer");
const path = require("path");
const fs = require("fs/promises");
const mongoose = require("mongoose");

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, path.join(__dirname, "../../public/uploads/"));
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
    cb(null, uniqueSuffix + path.extname(file.originalname));
  },
});

const upload = multer({
  storage: storage,
  limits: { fileSize: 10 * 1024 * 1024 }, // 10MB limit
  fileFilter: (req, file, cb) => {
    const filetypes = /jpeg|jpg|png|gif/;
    const mimetype = filetypes.test(file.mimetype);
    const extname = filetypes.test(
      path.extname(file.originalname).toLowerCase()
    );

    if (mimetype && extname) {
      return cb(null, true);
    }
    cb(new Error("Only image files are allowed!"));
  },
});

async function migrateRegistrations(event) {
  try {
    // Filter out invalid registrations and format existing ones
    const validRegistrations = event.registeredUsers
      .filter(
        (reg) =>
          reg &&
          (reg.user ||
            typeof reg === "string" ||
            reg instanceof mongoose.Types.ObjectId)
      )
      .map((reg) => {
        if (reg.user && reg.registrationDate) {
          // Already in correct format
          return reg;
        }
        // Convert string/ObjectId to proper registration object
        return {
          user:
            typeof reg === "string" ? new mongoose.Types.ObjectId(reg) : reg,
          registrationDate: new Date(),
        };
      });

    event.registeredUsers = validRegistrations;
    await event.save();
    return event;
  } catch (error) {
    console.error("Migration error:", error);
    throw error;
  }
}

// Get user's favorite events
router.get("/favorites", authenticateToken, async (req, res) => {
  try {
    console.log("Fetching favorites for user:", req.user.id);

    const user = await User.findById(req.user.id);
    if (!user) {
      console.log("User not found:", req.user.id);
      return res.status(404).json({ error: "User not found" });
    }

    const favorites = await User.findById(req.user.id).populate({
      path: "favoriteEvents",
      select:
        "title description date image category location capacity price registeredUsers",
    });

    console.log("Favorites found:", favorites.favoriteEvents?.length || 0);
    res.json(favorites.favoriteEvents || []);
  } catch (error) {
    console.error("Error in /favorites:", error);
    res.status(500).json({
      error: "Failed to fetch favorites",
      details: error.message,
    });
  }
});

// Add to favorites
router.post("/favorites/:id", authenticateToken, async (req, res) => {
  try {
    const eventId = req.params.id;
    const userId = req.user.id;

    console.log("Adding to favorites:", { userId, eventId });

    // Check if event exists
    const event = await Event.findById(eventId);
    if (!event) {
      return res.status(404).json({ error: "Event not found" });
    }

    // Add to favorites
    const user = await User.findByIdAndUpdate(
      userId,
      { $addToSet: { favoriteEvents: eventId } },
      { new: true }
    ).populate({
      path: "favoriteEvents",
      select:
        "title description date image category location capacity price registeredUsers",
    });

    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    console.log("Successfully added to favorites");
    res.json(user.favoriteEvents);
  } catch (error) {
    console.error("Error in add to favorites:", error);
    res.status(500).json({
      error: "Failed to add to favorites",
      details: error.message,
    });
  }
});

// Remove from favorites
router.delete("/favorites/:id", authenticateToken, async (req, res) => {
  try {
    const eventId = req.params.id;
    const userId = req.user.id;

    console.log("Removing from favorites:", { userId, eventId });

    const user = await User.findByIdAndUpdate(
      userId,
      { $pull: { favoriteEvents: eventId } },
      { new: true }
    ).populate({
      path: "favoriteEvents",
      select:
        "title description date image category location capacity price registeredUsers",
    });

    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    console.log("Successfully removed from favorites");
    res.json(user.favoriteEvents);
  } catch (error) {
    console.error("Error in remove from favorites:", error);
    res.status(500).json({
      error: "Failed to remove from favorites",
      details: error.message,
    });
  }
});

// Get all events
router.get("/", async (req, res) => {
  try {
    console.log("Fetching events");
    const events = await Event.find()
      .populate("creator", "name email phone")
      .sort({ date: 1 })
      .lean();
    console.log(
      "Events found:",
      events.map((e) => ({
        title: e.name,
        description: e.description,
      }))
    );
    res.json(events);
  } catch (error) {
    console.error("Error fetching events:", error);
    res.status(500).json({ error: error.message });
  }
});

// Get user's created events
router.get("/user/created", authenticateToken, async (req, res) => {
  try {
    const events = await Event.find({ creator: req.user.id })
      .populate("registeredUsers", "name email")
      .sort({ date: 1 });
    res.json(events);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get user's registered events
router.get("/user/registered", authenticateToken, async (req, res) => {
  try {
    const user = await User.findById(req.user.id).populate({
      path: "registeredEvents",
      populate: { path: "creator", select: "name" },
    });
    res.json(user.registeredEvents || []);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get event by id
router.get("/:id", async (req, res) => {
  try {
    const event = await Event.findById(req.params.id)
      .populate("creator", "name email phone")
      .lean();

    if (!event) {
      return res.status(404).json({ error: "Event not found" });
    }

    res.json(event);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Register for event
router.post("/:id/register", authenticateToken, async (req, res) => {
  try {
    console.log("Registration attempt:", {
      eventId: req.params.id,
      userId: req.user.id,
    });

    let event = await Event.findById(req.params.id);
    if (!event) {
      return res.status(404).json({ error: "Event not found" });
    }

    // Migrate existing registrations if needed
    event = await migrateRegistrations(event);

    console.log("Found event:", {
      eventId: event._id,
      title: event.title,
      currentRegistrations: event.registeredUsers.length,
      capacity: event.capacity,
    });

    // Check if event is in the past
    if (new Date(event.date) < new Date()) {
      return res.status(400).json({ error: "Cannot register for past events" });
    }

    // Check if event is full
    if (event.registeredUsers.length >= event.capacity) {
      return res.status(400).json({ error: "Event is full" });
    }

    // Convert user ID to ObjectId for comparison
    const userId = new mongoose.Types.ObjectId(req.user.id);

    // Check if user is already registered
    const isRegistered = event.registeredUsers.some(
      (reg) => reg.user && reg.user.toString() === userId.toString()
    );

    if (isRegistered) {
      return res
        .status(400)
        .json({ error: "Already registered for this event" });
    }

    // Add new registration
    event.registeredUsers.push({
      user: userId,
      registrationDate: new Date(),
    });

    await event.save();

    // Update user's registered events
    await User.findByIdAndUpdate(userId, {
      $addToSet: { registeredEvents: event._id },
    });

    // Return populated event
    const updatedEvent = await Event.findById(event._id)
      .populate({
        path: "registeredUsers.user",
        select: "name email profileImage",
      })
      .populate("creator", "name email");

    res.json(updatedEvent);
  } catch (error) {
    console.error("Registration error details:", {
      error: error.message,
      stack: error.stack,
      name: error.name,
    });
    res.status(500).json({
      error: "Failed to register for event",
      details: error.message,
    });
  }
});

// Create event
router.post(
  "/",
  authenticateToken,
  upload.single("image"),
  async (req, res) => {
    try {
      // Validate date first
      const eventDate = new Date(req.body.date);
      if (isNaN(eventDate.getTime())) {
        return res.status(400).json({ error: "Invalid date format" });
      }

      if (eventDate <= new Date()) {
        return res
          .status(400)
          .json({ error: "Cannot create events with past dates" });
      }

      // Validate capacity
      const capacity = parseInt(req.body.capacity);
      if (isNaN(capacity) || capacity < 1 || capacity > 1000) {
        return res
          .status(400)
          .json({ error: "Capacity must be between 1 and 1000" });
      }

      // Validate price
      const price = parseFloat(req.body.price);
      if (isNaN(price) || price < 0 || price > 100000) {
        return res
          .status(400)
          .json({ error: "Price must be between 0 and 100,000" });
      }

      // Validate title length
      if (
        !req.body.title?.trim() ||
        req.body.title.length < 3 ||
        req.body.title.length > 100
      ) {
        return res
          .status(400)
          .json({ error: "Title must be between 3 and 100 characters" });
      }

      // Validate description length
      if (
        !req.body.description?.trim() ||
        req.body.description.length < 10 ||
        req.body.description.length > 2000
      ) {
        return res
          .status(400)
          .json({
            error: "Description must be between 10 and 2000 characters",
          });
      }

      // Validate location length
      if (
        !req.body.location?.trim() ||
        req.body.location.length < 3 ||
        req.body.location.length > 200
      ) {
        return res
          .status(400)
          .json({ error: "Location must be between 3 and 200 characters" });
      }

      // Create event data object
      const newEventData = {
        ...req.body,
        creator: req.user.id,
        capacity: capacity,
        price: price,
        isFree: price === 0,
        date: eventDate,
      };

      if (req.file) {
        newEventData.image = `uploads/${req.file.filename}`;
      }

      const event = await Event.create(newEventData);
      res.status(201).json(event);
    } catch (error) {
      console.error("Event creation error:", error);
      if (error.name === "ValidationError") {
        const messages = Object.values(error.errors).map((err) => err.message);
        return res.status(400).json({ error: messages.join(", ") });
      }
      res.status(400).json({ error: error.message });
    }
  }
);

// Update event
router.put(
  "/:id",
  authenticateToken,
  upload.single("image"),
  async (req, res) => {
    try {
      const event = await Event.findById(req.params.id);
      if (!event) {
        return res.status(404).json({ error: "Event not found" });
      }

      // Check if user is creator or admin
      if (event.creator.toString() !== req.user.id && !req.user.isAdmin) {
        return res.status(403).json({ error: "Not authorized" });
      }

      // Validate date if provided
      if (req.body.date) {
        const eventDate = new Date(req.body.date);
        if (isNaN(eventDate.getTime())) {
          return res.status(400).json({ error: "Invalid date format" });
        }
        if (eventDate <= new Date()) {
          return res
            .status(400)
            .json({ error: "Event date must be in the future" });
        }
        req.body.date = eventDate;
      }

      // Validate capacity if provided
      if (req.body.capacity) {
        const capacity = parseInt(req.body.capacity);
        if (isNaN(capacity) || capacity < 1 || capacity > 1000) {
          return res
            .status(400)
            .json({ error: "Capacity must be between 1 and 1000" });
        }
        req.body.capacity = capacity;
      }

      // Apply the same validations as in the create route
      // ... (add the same validation checks as above)

      const updates = { ...req.body };
      if (req.file) {
        // Handle image update logic
        if (event.image) {
          const oldImagePath = path.join(
            __dirname,
            "../../public",
            event.image
          );
          try {
            await fs.unlink(oldImagePath);
          } catch (error) {
            console.error("Error deleting old image:", error);
          }
        }
        updates.image = `uploads/${req.file.filename}`;
      }

      const updatedEvent = await Event.findByIdAndUpdate(
        req.params.id,
        updates,
        { new: true, runValidators: true }
      );
      res.json(updatedEvent);
    } catch (error) {
      if (error.name === "ValidationError") {
        const messages = Object.values(error.errors).map((err) => err.message);
        return res.status(400).json({ error: messages.join(", ") });
      }
      res.status(400).json({ error: error.message });
    }
  }
);

// Delete event
router.delete("/:id", authenticateToken, async (req, res) => {
  try {
    const event = await Event.findById(req.params.id);
    if (!event) {
      return res.status(404).json({ error: "Event not found" });
    }

    // Check if user is creator or admin
    if (event.creator.toString() !== req.user.id && !req.user.isAdmin) {
      return res.status(403).json({ error: "Not authorized" });
    }

    // Delete event image if exists
    if (event.image) {
      const imagePath = path.join(__dirname, "..", "..", "public", event.image);
      try {
        await fs.unlink(imagePath);
      } catch (error) {
        console.error("Error deleting image:", error);
      }
    }

    await event.deleteOne();
    res.json({ message: "Event deleted" });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Add this route to check if files exist
router.get("/check-image/:filename", async (req, res) => {
  const filepath = path.join(
    __dirname,
    "../../public/uploads",
    req.params.filename
  );
  try {
    await fs.access(filepath);
    res.json({ exists: true, path: filepath });
  } catch {
    res.json({ exists: false, path: filepath });
  }
});

// Test registration endpoint (temporary)
router.post("/test-registration", authenticateToken, async (req, res) => {
  try {
    const event = await Event.findOne(); // Get first event
    if (!event) {
      return res.status(404).json({ error: "No events found" });
    }

    // Add test registration
    event.registeredUsers.push({
      user: req.user.id,
      registrationDate: new Date(),
    });

    await event.save();
    res.json({ message: "Test registration added" });
  } catch (error) {
    console.error("Test registration error:", error);
    res.status(500).json({ error: error.message });
  }
});

// Add this route near other event-related routes
router.get("/:id/register/check", authenticateToken, async (req, res) => {
  try {
    const eventId = req.params.id;
    const userId = req.user.id;

    console.log("Checking registration:", { eventId, userId });

    const event = await Event.findById(eventId);
    if (!event) {
      return res.status(404).json({ error: "Event not found" });
    }

    // Check if user is registered
    const isRegistered = event.registeredUsers.some(
      (reg) => reg.user && reg.user.toString() === userId
    );

    console.log("Registration status:", { isRegistered });
    res.json({ isRegistered });
  } catch (error) {
    console.error("Registration check error:", error);
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
