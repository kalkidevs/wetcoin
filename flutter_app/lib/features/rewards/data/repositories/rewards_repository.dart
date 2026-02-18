import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sweatcoin/core/constants/app_constants.dart';

final rewardsRepositoryProvider = Provider((ref) => RewardsRepository());

class RewardsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fetch rewards stream (real-time stock updates)
  Stream<List<Map<String, dynamic>>> getRewardsStream() {
    return _firestore
        .collection(AppConstants.collectionRewards)
        .where('active', isEqualTo: true)
        .orderBy('cost')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }

  Future<String> redeemReward(
      String rewardId, Map<String, dynamic> shippingAddress) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("User must be logged in");

      final rewardRef = _firestore.collection('rewards').doc(rewardId);
      final userRef = _firestore.collection('users').doc(user.uid);

      return await _firestore.runTransaction((transaction) async {
        final rewardDoc = await transaction.get(rewardRef);
        if (!rewardDoc.exists) throw Exception("Reward not found");

        final rewardData = rewardDoc.data()!;
        final stock = rewardData['stock'] ?? 0;
        final cost = rewardData['cost'] ?? 0;

        if (stock <= 0) throw Exception("Out of stock");

        final userDoc = await transaction.get(userRef);
        if (!userDoc.exists) throw Exception("User not found");

        final balance = userDoc.data()?['balance'] ?? 0;
        if (balance < cost) throw Exception("Insufficient balance");

        // Create Order
        final orderRef = _firestore.collection('orders').doc();
        transaction.set(orderRef, {
          'userId': user.uid,
          'rewardId': rewardId,
          'rewardName': rewardData['name'],
          'cost': cost,
          'shippingAddress': shippingAddress,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Deduct Stock
        transaction.update(rewardRef, {
          'stock': FieldValue.increment(-1),
        });

        // Deduct Balance
        transaction.update(userRef, {
          'balance': FieldValue.increment(-cost),
        });

        // Add to Ledger
        final ledgerRef = userRef.collection('wallet').doc();
        transaction.set(ledgerRef, {
          'type': 'spend',
          'amount': -cost,
          'description': "Redeemed ${rewardData['name']}",
          'timestamp': FieldValue.serverTimestamp(),
          'referenceId': orderRef.id,
        });

        return orderRef.id;
      });
    } catch (e) {
      rethrow;
    }
  }
}
