import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/reward_model.dart';

abstract class RewardRemoteDataSource {
  Future<List<RewardModel>> getActiveRewards();
  Future<String> redeemReward(
      {required String rewardId, required String shippingAddress});
}

class RewardRemoteDataSourceImpl implements RewardRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseFunctions functions;

  RewardRemoteDataSourceImpl(this.firestore, this.functions);

  @override
  Future<List<RewardModel>> getActiveRewards() async {
    try {
      final snapshot = await firestore
          .collection('rewards')
          .where('active', isEqualTo: true)
          .get();

      return snapshot.docs.map((doc) => RewardModel.fromSnapshot(doc)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> redeemReward(
      {required String rewardId, required String shippingAddress}) async {
    try {
      final callable = functions.httpsCallable('redeemReward');
      final result = await callable.call({
        'rewardId': rewardId,
        'shippingAddress': shippingAddress,
      });
      return result.data['orderId'];
    } catch (e) {
      if (e is FirebaseFunctionsException) {
        throw ServerException(e.message ?? 'Redemption failed');
      }
      throw ServerException(e.toString());
    }
  }
}
