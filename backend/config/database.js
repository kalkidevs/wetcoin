const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');

let mongoServer;

// MongoDB connection setup
const connectDB = async () => {
  try {
    let mongoUri = process.env.MONGODB_URI;
    let databaseType = 'MongoDB Atlas (Production)';

    console.log('\n🔧 [DATABASE] Initializing MongoDB connection...');

    // If no URI is provided, use an in-memory MongoDB instance
    // This allows the server to run locally without requiring MongoDB installation
    if (!mongoUri) {
      console.log('⚠️  [DATABASE] No MONGODB_URI found in .env file');
      console.log('📍 [DATABASE] Falling back to in-memory MongoDB server...');
      databaseType = 'In-Memory MongoDB (Testing Only)';
      mongoServer = await MongoMemoryServer.create();
      mongoUri = mongoServer.getUri();
    } else if (mongoUri.includes('localhost')) {
      console.log('📍 [DATABASE] Using local MongoDB instance...');
      databaseType = 'Local MongoDB';
    } else if (mongoUri.includes('mongodb+srv')) {
      console.log('📍 [DATABASE] Using MongoDB Atlas connection...');
      databaseType = 'MongoDB Atlas (Production)';
    }

    console.log(`🌐 [DATABASE] Connecting to: ${databaseType}`);
    console.log(`📝 [DATABASE] URI: ${mongoUri.substring(0, 50)}...`);
    
    const conn = await mongoose.connect(mongoUri, {
      // useNewUrlParser and useUnifiedTopology are deprecated in newer versions
      // but kept for backward compatibility
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });

    console.log(`✅ [DATABASE] MongoDB Connected: ${conn.connection.host}`);
    console.log(`✅ [DATABASE] Database Type: ${databaseType}`);
    console.log(`✅ [DATABASE] Database Name: ${conn.connection.name}`);
    console.log(`\n`);
  } catch (error) {
    console.error('\n❌ [DATABASE] Connection error: Could not connect to MongoDB.');
    console.error('❌ [DATABASE] Error details:', error.message);
    // Don't exit process - allow server to start without database for now
    console.log('⚠️  [DATABASE] Server will start without database connection.');
    console.log('📝 [DATABASE] To fix: Set MONGODB_URI environment variable in .env file or start local MongoDB server.\n');
  }
};

module.exports = connectDB;
