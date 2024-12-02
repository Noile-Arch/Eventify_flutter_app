import express from 'express';
import cors from 'cors';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();

app.use(cors({
  origin: ['http://localhost:3000', 'http://localhost:5000'],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));
app.use(express.json());

// Important: Serve the entire public directory
app.use('/public', express.static(path.join(__dirname, '../public')));

// Also keep the specific routes for backward compatibility
app.use('/uploads', express.static(path.join(__dirname, '../public/uploads')));
app.use('/profiles', express.static(path.join(__dirname, '../public/profiles'))); 