import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();
const db = admin.firestore();

// Constants
const STEPS_PER_COIN = 100;
const MAX_EARNABLE_STEPS = 15000; // 150 coins max
const MAX_TOTAL_STEPS = 30000;
const MAX_BACKDATE_HOURS = 48;

/**
 * Trigger: Create user document on new auth user creation.
 */
export const onUserCreate = functions.auth.user().onCreate(async (user) => {
  const userRef = db.collection("users").doc(user.uid);
  
  await userRef.set({
    uid: user.uid,
    phoneNumber: user.phoneNumber,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    balance: 0,
    lifetimeSteps: 0,
    lifetimeCoins: 0,
  }, { merge: true });
});

/**
 * Callable: Sync steps from client.
 * Receives: { steps: number, date: string (ISO date only YYYY-MM-DD), deviceId: string }
 * Returns: { success: boolean, balance: number, earned: number }
 */
export const syncSteps = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "User must be logged in.");
  }

  const { steps, date, deviceId } = data;
  const uid = context.auth.uid;

  if (typeof steps !== "number" || typeof date !== "string" || typeof deviceId !== "string") {
    throw new functions.https.HttpsError("invalid-argument", "Invalid input data.");
  }

  // Verify date window (prevent backdating > 48h)
  const stepDate = new Date(date);
  const now = new Date();
  const diffHours = (now.getTime() - stepDate.getTime()) / (1000 * 60 * 60);

  if (diffHours > MAX_BACKDATE_HOURS) {
    throw new functions.https.HttpsError("out-of-range", "Cannot sync steps older than 48 hours.");
  }

  // Prevent future dates
  if (stepDate > now) {
     throw new functions.https.HttpsError("out-of-range", "Cannot sync future steps.");
  }

  const userRef = db.collection("users").doc(uid);
  const dateDocRef = userRef.collection("steps").doc(date);

  try {
    const result = await db.runTransaction(async (transaction) => {
      const userDoc = await transaction.get(userRef);
      if (!userDoc.exists) {
        throw new functions.https.HttpsError("not-found", "User profile not found.");
      }

      const dateDoc = await transaction.get(dateDocRef);
      let existingSteps = 0;
      let existingEarnedSteps = 0;

      if (dateDoc.exists) {
        const data = dateDoc.data();
        existingSteps = data?.steps || 0;
        existingEarnedSteps = data?.earnedSteps || 0;
      }

      // Check if new steps are actually greater than existing (incremental sync only logic, usually overwrite in MVP context but safer to verify)
      // The client sends TOTAL steps for the day from HealthKit.
      if (steps <= existingSteps) {
        return { balance: userDoc.data()?.balance || 0, earned: 0, stepsSaved: existingSteps };
      }

      // Cap checks
      const stepsToRecord = Math.min(steps, MAX_TOTAL_STEPS);
      const stepsForCoins = Math.min(stepsToRecord, MAX_EARNABLE_STEPS);
      
      const newEarnedSteps = stepsForCoins - existingEarnedSteps;
      
      if (newEarnedSteps <= 0) {
        // Just update total steps if increased, but no new coins
        if (stepsToRecord > existingSteps) {
           transaction.set(dateDocRef, {
             steps: stepsToRecord,
             lastSync: admin.firestore.FieldValue.serverTimestamp(),
             deviceId: deviceId,
           }, { merge: true });
        }
        return { balance: userDoc.data()?.balance || 0, earned: 0, stepsSaved: stepsToRecord };
      }

      // Calculate Coins
      const coinsEarned = newEarnedSteps / STEPS_PER_COIN;

      // Update Ledger
      const ledgerRef = userRef.collection("wallet").doc();
      transaction.set(ledgerRef, {
        type: "earn",
        amount: coinsEarned,
        description: `Steps for ${date}`,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        referenceId: date,
      });

      // Update Daily Steps
      transaction.set(dateDocRef, {
        steps: stepsToRecord,
        earnedSteps: stepsForCoins,
        lastSync: admin.firestore.FieldValue.serverTimestamp(),
        deviceId: deviceId,
      }, { merge: true });

      // Update User Balance
      const newBalance = (userDoc.data()?.balance || 0) + coinsEarned;
      const newLifetimeSteps = (userDoc.data()?.lifetimeSteps || 0) + (stepsToRecord - existingSteps);
      const newLifetimeCoins = (userDoc.data()?.lifetimeCoins || 0) + coinsEarned;

      transaction.update(userRef, {
        balance: newBalance,
        lifetimeSteps: newLifetimeSteps,
        lifetimeCoins: newLifetimeCoins,
      });

      return { balance: newBalance, earned: coinsEarned, stepsSaved: stepsToRecord };
    });

    return result;

  } catch (error) {
    console.error("Sync Transaction Error", error);
    throw new functions.https.HttpsError("internal", "Failed to sync steps.");
  }
});

/**
 * Callable: Redeem Reward
 * Receives: { rewardId: string, shippingAddress: object }
 */
export const redeemReward = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "User must be logged in.");
  }
  
  const { rewardId, shippingAddress } = data;
  const uid = context.auth.uid;

  if (!rewardId || !shippingAddress) {
    throw new functions.https.HttpsError("invalid-argument", "Missing rewardId or shipping address.");
  }

  const rewardRef = db.collection("rewards").doc(rewardId);
  const userRef = db.collection("users").doc(uid);

  try {
    const orderId = await db.runTransaction(async (transaction) => {
      const rewardDoc = await transaction.get(rewardRef);
      if (!rewardDoc.exists) {
        throw new functions.https.HttpsError("not-found", "Reward not found.");
      }
      
      const rewardData = rewardDoc.data()!;
      if (rewardData.stock <= 0) {
        throw new functions.https.HttpsError("failed-precondition", "Out of stock.");
      }

      const userDoc = await transaction.get(userRef);
      const userData = userDoc.data()!;
      
      if (userData.balance < rewardData.cost) {
        throw new functions.https.HttpsError("failed-precondition", "Insufficient balance.");
      }

      // Create Order
      const orderRef = db.collection("orders").doc();
      const orderData = {
        userId: uid,
        rewardId: rewardId,
        rewardName: rewardData.name,
        cost: rewardData.cost,
        shippingAddress: shippingAddress,
        status: "pending",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      };
      
      transaction.set(orderRef, orderData);

      // Deduct Stock
      transaction.update(rewardRef, {
        stock: admin.firestore.FieldValue.increment(-1)
      });

      // Deduct Balance
      transaction.update(userRef, {
        balance: admin.firestore.FieldValue.increment(-rewardData.cost)
      });

      // Add to Ledger
      const ledgerRef = userRef.collection("wallet").doc();
      transaction.set(ledgerRef, {
        type: "spend",
        amount: -rewardData.cost,
        description: `Redeemed ${rewardData.name}`,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        referenceId: orderRef.id,
      });

      return orderRef.id;
    });

    return { success: true, orderId };
  } catch (error) {
    console.error("Redemption Error", error);
    if (error instanceof functions.https.HttpsError) throw error;
    throw new functions.https.HttpsError("internal", "Redemption failed.");
  }
});

/**
 * Callable: Get Wallet History
 */
export const getWallet = functions.https.onCall(async (data, context) => {
    if (!context.auth) throw new functions.https.HttpsError("unauthenticated", "User must be logged in.");
    
    const uid = context.auth.uid;
    const limit = data.limit || 20;

    const snapshot = await db.collection("users").doc(uid).collection("wallet")
        .orderBy("timestamp", "desc")
        .limit(limit)
        .get();

    return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
});

/**
 * Callable: List Rewards
 */
export const listRewards = functions.https.onCall(async (data, context) => {
    const snapshot = await db.collection("rewards")
        .where("active", "==", true)
        .orderBy("cost", "asc")
        .get();

    return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
});
