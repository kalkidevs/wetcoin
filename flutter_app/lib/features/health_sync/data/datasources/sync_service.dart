import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'health_service.dart';
import 'package:intl/intl.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class SyncService {
  final HealthService _healthService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Constants
  static const int STEPS_PER_COIN = 100;
  static const int MAX_EARNABLE_STEPS = 15000; // 150 coins max
  static const int MAX_TOTAL_STEPS = 30000;

  SyncService(this._healthService);

  Future<Map<String, dynamic>> syncToday() async {
    return await syncDate(DateTime.now());
  }

  Future<Map<String, dynamic>> syncDate(DateTime date) async {
    // 1. Get Steps
    int steps = await _healthService.getStepsForDate(date);

    // 2. Get Device ID (for security/logging)
    String deviceId = await _getDeviceId();

    // 3. Execute Logic Client-Side (Transaction)
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("User not logged in");

      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final userRef = _firestore.collection('users').doc(user.uid);
      final dateDocRef = userRef.collection('steps').doc(dateStr);

      return await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);
        if (!userDoc.exists) throw Exception("User profile not found");

        final dateDoc = await transaction.get(dateDocRef);
        int existingSteps = 0;
        int existingEarnedSteps = 0;

        if (dateDoc.exists) {
          final data = dateDoc.data()!;
          existingSteps = data['steps'] ?? 0;
          existingEarnedSteps = data['earnedSteps'] ?? 0;
        }

        // Logic: Only update if steps increased
        if (steps <= existingSteps) {
          return {
            'balance': userDoc.data()?['balance'] ?? 0,
            'earned': 0,
            'stepsSaved': existingSteps
          };
        }

        // Cap checks
        final stepsToRecord = steps > MAX_TOTAL_STEPS ? MAX_TOTAL_STEPS : steps;
        final stepsForCoins = stepsToRecord > MAX_EARNABLE_STEPS
            ? MAX_EARNABLE_STEPS
            : stepsToRecord;

        final newEarnedSteps = stepsForCoins - existingEarnedSteps;

        if (newEarnedSteps <= 0) {
          // Just update total steps if increased, but no new coins
          if (stepsToRecord > existingSteps) {
            transaction.set(
                dateDocRef,
                {
                  'steps': stepsToRecord,
                  'lastSync': FieldValue.serverTimestamp(),
                  'deviceId': deviceId,
                },
                SetOptions(merge: true));
          }
          return {
            'balance': userDoc.data()?['balance'] ?? 0,
            'earned': 0,
            'stepsSaved': stepsToRecord
          };
        }

        // Calculate Coins
        final coinsEarned = newEarnedSteps / STEPS_PER_COIN;

        // Update Ledger
        final ledgerRef = userRef.collection('wallet').doc();
        transaction.set(ledgerRef, {
          'type': 'earn',
          'amount': coinsEarned,
          'description': 'Steps for $dateStr',
          'timestamp': FieldValue.serverTimestamp(),
          'referenceId': dateStr,
        });

        // Update Daily Steps
        transaction.set(
            dateDocRef,
            {
              'steps': stepsToRecord,
              'earnedSteps': stepsForCoins,
              'lastSync': FieldValue.serverTimestamp(),
              'deviceId': deviceId,
            },
            SetOptions(merge: true));

        // Update User Balance
        final currentBalance = (userDoc.data()?['balance'] ?? 0) as num;
        final newBalance = currentBalance + coinsEarned;

        // Note: Client-side increment is cleaner but we need the new value
        transaction.update(userRef, {
          'balance': FieldValue.increment(coinsEarned),
          'lifetimeSteps': FieldValue.increment(stepsToRecord - existingSteps),
          'lifetimeCoins': FieldValue.increment(coinsEarned),
        });

        return {
          'balance': newBalance,
          'earned': coinsEarned,
          'stepsSaved': stepsToRecord
        };
      });
    } catch (e) {
      debugPrint("Sync failed: $e");
      rethrow;
    }
  }

  Future<String> _getDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? 'unknown_ios';
    }
    return 'unknown';
  }
}
