import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sweatcoin/core/constants/app_constants.dart';

import '../../../auth/data/datasources/auth_remote_data_source.dart';

final walletRepositoryProvider = Provider((ref) => WalletRepository(ref));

class WalletRepository {
  final Ref _ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  WalletRepository(this._ref);

  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserStream() {
    final user = _ref.read(authServiceProvider).currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection(AppConstants.collectionUsers)
        .doc(user.uid)
        .snapshots();
  }

  Future<List<Map<String, dynamic>>> getTransactions({int limit = 20}) async {
    final user = _ref.read(authServiceProvider).currentUser;
    if (user == null) return [];

    // Prompt says "Cloud Functions only writes", but rules allow read for own wallet.
    // However, the prompt requirements section also lists `getWallet` cloud function.
    // I should probably use the Cloud Function if strictly following "Cloud Functions APIs -> Implement getWallet".
    // But direct Firestore read is more efficient for real-time history if rules allow it.
    // The prompt says "Implement: getWallet()". I implemented it in backend.
    // Let's use the Cloud Function for history to be safe and consistent with "Server calculates...".
    // Although standard practice is client reads.
    // I will use Firestore direct read for `getUserStream` (Balance) as it's critical for UI updates,
    // and Cloud Function for paginated history if complex logic is needed, but Firestore query is simple.
    // Re-reading: "Firestore rules locked. Cloud Functions only writes".
    // This implies reads are allowed.
    // I will use direct Firestore query for history as it's cleaner than a callable for simple fetch,
    // unless I want to hide the collection structure completely.
    // But I implemented `getWallet` in cloud function, so I'll use it?
    // Actually, `getWallet` in cloud function returns a list.
    // I'll support both, but use direct read for simplicity in stream.

    // For this method, let's use direct query since I wrote the rule:
    // match /wallet/{txId} { allow read: if request.auth.uid == userId; }

    final snapshot = await _firestore
        .collection(AppConstants.collectionUsers)
        .doc(user.uid)
        .collection(AppConstants.subCollectionWallet)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}
