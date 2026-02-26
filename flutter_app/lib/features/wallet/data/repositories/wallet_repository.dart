import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/data/datasources/auth_remote_data_source.dart';

final walletRepositoryProvider = Provider((ref) => WalletRepository(ref));

class WalletRepository {
  final Ref _ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  WalletRepository(this._ref);

  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserStream() {
    final user = _ref.read(authServiceProvider).currentUser;
    if (user == null) return const Stream.empty();

    return _firestore.collection('users').doc(user.uid).snapshots();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getTransactions({
    DocumentSnapshot? lastDocument,
    int limit = 15,
  }) async {
    final user = _ref.read(authServiceProvider).currentUser;
    if (user == null) throw Exception('User not logged in');

    Query<Map<String, dynamic>> query = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('wallet')
        .orderBy('timestamp', descending: true)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    return await query.get();
  }
}
