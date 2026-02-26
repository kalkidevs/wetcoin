#!/usr/bin/env node

/**
 * Database Cleanup Script
 * 
 * This script will:
 * 1. Connect to your MongoDB database
 * 2. Drop all collections (users, rewards, steps, wallets)
 * 3. Reset the database to a fresh state
 * 
 * Usage: node scripts/cleanup_database.js
 */

const mongoose = require('mongoose');

// Load environment variables
require('dotenv').config();

const MONGODB_URI = process.env.MONGODB_URI;

if (!MONGODB_URI) {
  console.error('❌ Error: MONGODB_URI not found in .env file');
  console.error('Please set the MONGODB_URI environment variable in your .env file');
  process.exit(1);
}

async function cleanupDatabase() {
  try {
    console.log('🧹 Starting database cleanup...');
    console.log(`📍 Connecting to: ${MONGODB_URI.replace(/\/\/.*@/, '//***:***@')}`);
    
    // Connect to MongoDB
    await mongoose.connect(MONGODB_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });

    const db = mongoose.connection.db;
    const collections = await db.listCollections().toArray();
    
    console.log(`📋 Found ${collections.length} collections:`);
    collections.forEach(collection => {
      console.log(`   - ${collection.name}`);
    });

    if (collections.length === 0) {
      console.log('✅ Database is already empty!');
      await mongoose.disconnect();
      return;
    }

    // Drop all collections
    console.log('\n🗑️  Dropping all collections...');
    for (const collection of collections) {
      console.log(`   Dropping: ${collection.name}...`);
      await db.dropCollection(collection.name);
    }

    console.log('\n✅ All collections dropped successfully!');
    
    // Verify collections are gone
    const remainingCollections = await db.listCollections().toArray();
    console.log(`📊 Remaining collections: ${remainingCollections.length}`);
    
    if (remainingCollections.length === 0) {
      console.log('🎉 Database cleanup complete! Your database is now fresh and clean.');
    } else {
      console.log('⚠️  Warning: Some collections remain. This might be expected for system collections.');
    }

  } catch (error) {
    console.error('❌ Error during database cleanup:', error.message);
    process.exit(1);
  } finally {
    await mongoose.disconnect();
    console.log('🔌 Disconnected from database');
  }
}

// Run the cleanup
cleanupDatabase();