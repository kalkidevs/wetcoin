const admin = require('firebase-admin');

try {
  admin.initializeApp({
    projectId: 'sweatcoin-india-91fbb'
  });
  console.log('Initialized with project ID');
  
  // Create a dummy token to see if it fails due to credentials or just invalid token
  admin.auth().verifyIdToken('dummy.token.here')
    .then(() => console.log('Token verified'))
    .catch(e => {
      if (e.code === 'auth/argument-error' || e.code === 'auth/invalid-argument') {
        console.log('Success: Reached token validation stage without credential errors:', e.message);
      } else {
        console.log('Other error:', e);
      }
    });
} catch (e) {
  console.error('Init error:', e);
}
