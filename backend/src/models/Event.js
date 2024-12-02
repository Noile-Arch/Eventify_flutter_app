const mongoose = require("mongoose");

const eventSchema = new mongoose.Schema({
  title: { 
    type: String, 
    required: true,
    trim: true,
    minlength: [3, 'Title must be at least 3 characters long'],
    maxlength: [100, 'Title cannot exceed 100 characters']
  },
  description: { 
    type: String, 
    required: true,
    trim: true,
    minlength: [10, 'Description must be at least 10 characters long'],
    maxlength: [2000, 'Description cannot exceed 2000 characters']
  },
  category: { 
    type: String, 
    required: true,
    enum: {
      values: ['Technology', 'Business', 'Entertainment', 'Education', 'Sports', 'Food', 'Arts', 'Music', 'Networking', 'Health', 'Community', 'Charity'],
      message: '{VALUE} is not a supported category'
    }
  },
  image: { type: String },
  date: { 
    type: Date, 
    required: true,
    validate: {
      validator: function(value) {
        return value > new Date();
      },
      message: 'Event date must be in the future'
    }
  },
  location: { 
    type: String, 
    required: true,
    trim: true,
    minlength: [3, 'Location must be at least 3 characters long'],
    maxlength: [200, 'Location cannot exceed 200 characters']
  },
  capacity: { 
    type: Number, 
    required: true, 
    min: [1, 'Capacity must be at least 1'],
    max: [1000, 'Capacity cannot exceed 1000']
  },
  price: { 
    type: Number, 
    required: true, 
    min: [0, 'Price cannot be negative'],
    max: [100000, 'Price cannot exceed 100,000']
  },
  isFree: { type: Boolean, default: false },
  paymentStatus: {
    type: String,
    enum: ['free', 'paid', 'pending'],
    default: 'free'
  },
  registeredUsers: [{
    user: { 
      type: mongoose.Schema.Types.ObjectId, 
      ref: "User",
      required: true 
    },
    registrationDate: { 
      type: Date, 
      default: Date.now 
    }
  }],
  creator: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  isAdminEvent: { type: Boolean, default: false },
});

module.exports = mongoose.model("Event", eventSchema); 