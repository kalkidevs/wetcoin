#!/usr/bin/env node

/**
 * Seed Rewards Script
 * 
 * Populates the MongoDB rewards collection with initial reward catalog.
 * Usage: npm run db:seed
 * 
 * This is idempotent — running it multiple times won't create duplicates
 * (it checks by name before inserting).
 */

const mongoose = require('mongoose');
const dotenv = require('dotenv');
const path = require('path');

// Load environment variables
dotenv.config({ path: path.join(__dirname, '..', '.env') });

const Reward = require('../models/Reward');

const SEED_REWARDS = [
    {
        name: 'Water Bottle',
        cost: 50,
        description: 'Stay hydrated with this eco-friendly stainless steel water bottle. Perfect for your workouts.',
        imageUrl: 'https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=400',
        stock: 100,
        active: true
    },
    {
        name: 'Sports T-Shirt',
        cost: 100,
        description: 'Comfortable moisture-wicking cotton t-shirt. Available in multiple sizes.',
        imageUrl: 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400',
        stock: 50,
        active: true
    },
    {
        name: 'Wireless Earbuds',
        cost: 200,
        description: 'Premium wireless bluetooth earbuds with noise cancellation. Perfect for running.',
        imageUrl: 'https://images.unsplash.com/photo-1590658268037-6bf12f032f55?w=400',
        stock: 25,
        active: true
    },
    {
        name: 'Gift Card ₹500',
        cost: 500,
        description: 'Amazon gift card worth ₹500. Redeemable on any product.',
        imageUrl: 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=400',
        stock: 20,
        active: true
    },
    {
        name: 'Fitness Tracker Band',
        cost: 1000,
        description: 'Smart fitness tracker with heart rate monitor, step counter, and sleep tracking.',
        imageUrl: 'https://images.unsplash.com/photo-1575311373937-040b8e1fd5b6?w=400',
        stock: 10,
        active: true
    },
    {
        name: 'Running Shoes Voucher',
        cost: 2000,
        description: 'Voucher for premium running shoes from top brands. Valid for 6 months.',
        imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400',
        stock: 5,
        active: true
    }
];

async function seedRewards() {
    try {
        console.log('🌱 [SEED] Starting reward seeding...\n');

        // Connect to MongoDB
        const mongoUri = process.env.MONGODB_URI;
        if (!mongoUri) {
            console.error('❌ [SEED] MONGODB_URI not found in .env');
            process.exit(1);
        }

        await mongoose.connect(mongoUri);
        console.log('✅ [SEED] Connected to MongoDB\n');

        let inserted = 0;
        let skipped = 0;

        for (const reward of SEED_REWARDS) {
            // Check if reward already exists (by name)
            const existing = await Reward.findOne({ name: reward.name });
            if (existing) {
                console.log(`⏭️  [SEED] Skipped "${reward.name}" (already exists)`);
                skipped++;
            } else {
                await Reward.create(reward);
                console.log(`✅ [SEED] Created "${reward.name}" — ${reward.cost} coins, stock: ${reward.stock}`);
                inserted++;
            }
        }

        console.log(`\n🎉 [SEED] Done! Inserted: ${inserted}, Skipped: ${skipped}`);
        console.log(`📊 [SEED] Total rewards in DB: ${await Reward.countDocuments()}`);

    } catch (error) {
        console.error('❌ [SEED] Seeding failed:', error.message);
    } finally {
        await mongoose.disconnect();
        process.exit(0);
    }
}

seedRewards();
