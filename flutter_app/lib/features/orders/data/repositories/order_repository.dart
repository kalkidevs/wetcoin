import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sweatcoin/core/constants/app_constants.dart';
import 'package:sweatcoin/features/auth/data/datasources/auth_remote_data_source.dart';

final orderRepositoryProvider = Provider((ref) => OrderRepository(ref));

class OrderRepository {
  final Ref _ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  OrderRepository(this._ref);

  Stream<List<Map<String, dynamic>>> getUserOrders() {
    final user = _ref.read(authServiceProvider).currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection(AppConstants.collectionOrders)
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }
}
