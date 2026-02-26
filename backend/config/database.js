const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');

let mongoServer;

// MongoDB connection setup
const connectDB = async () => {
  try {
    let mongoUri = process.env.MONGODB_URI;

    // If no URI is provided, use an in-memory MongoDB instance
    // This allows the server to run locally without requiring MongoDB installation
    if (!mongoUri || mongoUri.includes('localhost:27017')) {
      console.log('Starting in-memory MongoDB server (no MONGODB_URI provided)...');
      mongoServer = await MongoMemoryServer.create();
      mongoUri = mongoServer.getUri();
    }
    
    const conn = await mongoose.connect(mongoUri, {
      // useNewUrlParser and useUnifiedTopology are deprecated in newer versions
      // but kept for backward compatibility
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });

    console.log(`MongoDB Connected: ${conn.connection.host}`);
  } catch (error) {
    console.error('Database connection error: Could not connect to MongoDB.', error.message);
    // Don't exit process - allow server to start without database for now
    console.log('Server will start without database connection. Set MONGODB_URI environment variable or start local MongoDB to connect.');
  }
};

module.exports = connectDB;
