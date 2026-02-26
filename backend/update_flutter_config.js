#!/usr/bin/env node

/**
 * Auto-detect backend port and update Flutter config
 * Usage: node update_flutter_config.js
 */

const fs = require('fs');
const path = require('path');

// Read the current Flutter config
const flutterConfigPath = path.join(__dirname, '../flutter_app/lib/core/config/env_config.dart');

function updateFlutterConfig(port) {
  try {
    let content = fs.readFileSync(flutterConfigPath, 'utf8');
    
    // Replace the localBaseUrl port
    const oldPortMatch = content.match(/static const String localBaseUrl = 'http:\/\/localhost:(\d+)';/);
    
    if (oldPortMatch) {
      const oldPort = oldPortMatch[1];
      const newContent = content.replace(
        `static const String localBaseUrl = 'http://localhost:${oldPort}';`,
        `static const String localBaseUrl = 'http://localhost:${port}';`
      );
      
      fs.writeFileSync(flutterConfigPath, newContent);
      console.log(`✅ Updated Flutter config: localhost:${oldPort} → localhost:${port}`);
      console.log(`📍 Flutter app will now connect to http://localhost:${port}`);
    } else {
      console.log('❌ Could not find localBaseUrl in Flutter config');
    }
  } catch (error) {
    console.error('❌ Error updating Flutter config:', error.message);
  }
}

// Try to detect which port the backend is running on
function detectBackendPort() {
  const http = require('http');
  
  const portsToCheck = [5000, 5001, 5002, 5003, 5004];
  
  function checkPort(port, callback) {
    const options = {
      hostname: 'localhost',
      port: port,
      path: '/health',
      method: 'GET',
      timeout: 1000
    };

    const req = http.request(options, (res) => {
      if (res.statusCode === 200) {
        callback(port);
      } else {
        callback(null);
      }
    });

    req.on('error', () => {
      callback(null);
    });

    req.on('timeout', () => {
      req.destroy();
      callback(null);
    });

    req.end();
  }

  function checkNextPort(index) {
    if (index >= portsToCheck.length) {
      console.log('❌ No running backend server found on ports 5000-5004');
      console.log('💡 Make sure the backend server is running');
      return;
    }

    const port = portsToCheck[index];
    console.log(`🔍 Checking port ${port}...`);
    
    checkPort(port, (foundPort) => {
      if (foundPort) {
        console.log(`✅ Backend server found on port ${foundPort}`);
        updateFlutterConfig(foundPort);
      } else {
        checkNextPort(index + 1);
      }
    });
  }

  checkNextPort(0);
}

console.log('🔄 Auto-detecting backend server port...');
detectBackendPort();