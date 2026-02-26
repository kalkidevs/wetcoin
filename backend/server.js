const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const connectDB = require('./config/database');

// Load environment variables
dotenv.config();

// Connect to database
connectDB();

// Initialize Express app
const app = express();

// Middleware
app.use(cors());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Request logging middleware
app.use((req, res, next) => {
  console.log(`📥 [SERVER] ${req.method} ${req.path}`);
  console.log(`📥 [SERVER] Query:`, req.query);
  console.log(`📥 [SERVER] Body:`, req.body);
  next();
});

// API Routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/sync', require('./routes/sync'));
app.use('/api/wallet', require('./routes/wallet'));
app.use('/api/rewards', require('./routes/rewards'));

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    success: true,
    message: 'Sweatcoin Backend API is running',
    timestamp: new Date().toISOString()
  });
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    success: true,
    message: 'Welcome to Sweatcoin Backend API',
    endpoints: {
      'POST /api/sync': 'Sync step data',
      'GET /api/wallet/:userId': 'Get wallet transactions',
      'GET /api/rewards': 'Get available rewards',
      'POST /api/redeem-reward': 'Redeem a reward'
    }
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    success: false,
    error: 'Something went wrong!',
    message: process.env.NODE_ENV === 'production' ? 'Internal server error' : err.message
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    error: 'Endpoint not found'
  });
});

// Start server
const PORT = parseInt(process.env.PORT || 5000, 10);

function startServer(port) {
  app.listen(port, () => {
    console.log(`✅ Server running on port ${port}`);
    console.log(`📍 Health check: http://localhost:${port}/health`);
  }).on('error', (err) => {
    if (err.code === 'EADDRINUSE') {
      console.log(`❌ Port ${port} is already in use. Trying port ${port + 1}...`);
      startServer(port + 1);
    } else {
      console.error('❌ Server error:', err);
      process.exit(1);
    }
  });
}

startServer(PORT);
