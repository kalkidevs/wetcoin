import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/reward.dart';

abstract class RewardRepository {
  Future<Either<Failure, List<Reward>>> getActiveRewards();
  Future<Either<Failure, String>> redeemReward(
      {required String rewardId, required String shippingAddress});
}
