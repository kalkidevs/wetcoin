import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/reward_repository.dart';

class RedeemReward {
  final RewardRepository repository;

  RedeemReward(this.repository);

  Future<Either<Failure, String>> call({
    required String rewardId,
    required String shippingAddress,
  }) {
    return repository.redeemReward(
      rewardId: rewardId,
      shippingAddress: shippingAddress,
    );
  }
}
