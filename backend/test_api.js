#!/usr/bin/env node

/**
 * API Test Script
 * 
 * This script tests the backend API endpoints to ensure they're working correctly.
 * Usage: node test_api.js
 */

const http = require('http');

const PORT = 5001;
const BASE_URL = `http://localhost:${PORT}`;

async function testEndpoint(path, method = 'GET', body = null) {
  return new Promise((resolve, reject) => {
    const url = new URL(path, BASE_URL);
    const options = {
      hostname: 'localhost',
      port: PORT,
      path: path,
      method: method,
      headers: {
        'Content-Type': 'application/json',
      }
    };

    const req = http.request(options, (res) => {
      let data = '';
      
      res.on('data', (chunk) => {
        data += chunk;
      });
      
      res.on('end', () => {
        try {
          const result = {
            statusCode: res.statusCode,
            headers: res.headers,
            body: data,
            parsedBody: JSON.parse(data)
          };
          resolve(result);
        } catch (e) {
          resolve({
            statusCode: res.statusCode,
            headers: res.headers,
            body: data,
            parsedBody: null,
            parseError: e.message
          });
        }
      });
    });

    req.on('error', (error) => {
      reject(error);
    });

    if (body) {
      req.write(JSON.stringify(body));
    }

    req.end();
  });
}

async function runTests() {
  console.log('🧪 Testing Sweatcoin Backend API');
  console.log('📍 Base URL:', BASE_URL);
  console.log('');

  try {
    // Test 1: Health check
    console.log('1. Testing health check endpoint...');
    const healthResult = await testEndpoint('/health');
    console.log(`   Status: ${healthResult.statusCode}`);
    console.log(`   Response: ${healthResult.body}`);
    console.log('');

    // Test 2: Root endpoint
    console.log('2. Testing root endpoint...');
    const rootResult = await testEndpoint('/');
    console.log(`   Status: ${rootResult.statusCode}`);
    console.log(`   Response: ${rootResult.body}`);
    console.log('');

    // Test 3: Auth verify-token endpoint (should return 400 since no token provided)
    console.log('3. Testing auth verify-token endpoint...');
    const authResult = await testEndpoint('/api/auth/verify-token', 'POST', {});
    console.log(`   Status: ${authResult.statusCode}`);
    console.log(`   Response: ${authResult.body}`);
    console.log('');

    // Test 4: Auth refresh-user endpoint (should return 400 since no uid provided)
    console.log('4. Testing auth refresh-user endpoint...');
    const refreshResult = await testEndpoint('/api/auth/refresh-user', 'POST', {});
    console.log(`   Status: ${refreshResult.statusCode}`);
    console.log(`   Response: ${refreshResult.body}`);
    console.log('');

    // Test 5: Sync endpoint (should return 400 since no data provided)
    console.log('5. Testing sync endpoint...');
    const syncResult = await testEndpoint('/api/sync', 'POST', {});
    console.log(`   Status: ${syncResult.statusCode}`);
    console.log(`   Response: ${syncResult.body}`);
    console.log('');

    console.log('✅ All tests completed!');

  } catch (error) {
    console.error('❌ Test failed:', error.message);
    console.log('');
    console.log('💡 Troubleshooting tips:');
    console.log('   1. Make sure the backend server is running on port 5001');
    console.log('   2. Check if MongoDB is connected');
    console.log('   3. Verify all routes are properly registered');
    console.log('   4. Check the server logs for any errors');
  }
}

runTests();