import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/reward.dart';
import '../repositories/reward_repository.dart';

class GetActiveRewards {
  final RewardRepository repository;

  GetActiveRewards(this.repository);

  Future<Either<Failure, List<Reward>>> call() {
    return repository.getActiveRewards();
  }
}
