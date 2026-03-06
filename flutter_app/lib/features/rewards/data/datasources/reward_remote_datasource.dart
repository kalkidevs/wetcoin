import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/api_service.dart';
import '../models/reward_model.dart';

abstract class RewardRemoteDataSource {
  Future<List<RewardModel>> getActiveRewards();
  Future<String> redeemReward(
      {required String rewardId, required String shippingAddress});
}

class RewardRemoteDataSourceImpl implements RewardRemoteDataSource {
  final ApiService _api = ApiService();

  RewardRemoteDataSourceImpl();

  @override
  Future<List<RewardModel>> getActiveRewards() async {
    try {
      // Rewards listing is public (no auth needed)
      final result = await _api.get('/api/rewards', auth: false);

      if (result['success'] != true) {
        throw ServerException(result['error'] ?? 'Failed to fetch rewards');
      }

      final data = result['data'] as List<dynamic>? ?? [];
      return data
          .map((json) => RewardModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> redeemReward(
      {required String rewardId, required String shippingAddress}) async {
    try {
      final userId = await _api.getUserId();
      if (userId == null || userId.isEmpty) {
        throw ServerException('User not logged in');
      }

      final result = await _api.post('/api/rewards/redeem', {
        'userId': userId,
        'rewardId': rewardId,
        'shippingAddress': shippingAddress,
      });

      if (result['success'] != true) {
        throw ServerException(result['error'] ?? 'Redemption failed');
      }

      return result['orderId'] ?? '';
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }
}
