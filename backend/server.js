const express = require("express");
const cors = require("cors");
const connectDB = require("./src/config/database");
const path = require('path');
const fs = require('fs');

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Create uploads directory if it doesn't exist
const uploadsDir = path.join(__dirname, 'public', 'uploads');
if (!fs.existsSync(uploadsDir)) {
    fs.mkdirSync(uploadsDir, { recursive: true });
    console.log('Created uploads directory at:', uploadsDir);
}

// Set proper permissions
fs.chmodSync(uploadsDir, '755');

// Connect to MongoDB first
connectDB()
  .then(() => {
    // Serve static files - make sure this comes before routes
    app.use('/uploads', express.static(path.join(__dirname, 'public/uploads')));
    
    // Routes
    app.use("/api", require("./src/routes/auth"));
    app.use("/api/events", require("./src/routes/events"));
    app.use("/api/admin", require("./src/routes/admin"));

    // Start server
    app.listen(5000, () => console.log("Server running on port 5000"));
  })
  .catch(error => {
    console.error("Failed to connect to MongoDB:", error);
    process.exit(1);
  });
