import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/reward_remote_datasource.dart';
import '../../data/repositories/reward_repository_impl.dart';
import '../../domain/entities/reward.dart';
import '../../domain/usecases/get_active_rewards.dart';
import '../../domain/usecases/redeem_reward.dart';

final rewardRemoteDataSourceProvider = Provider<RewardRemoteDataSource>((ref) {
  return RewardRemoteDataSourceImpl();
});

final rewardRepositoryProvider = Provider<RewardRepositoryImpl>((ref) {
  return RewardRepositoryImpl(ref.watch(rewardRemoteDataSourceProvider));
});

final getActiveRewardsProvider = Provider<GetActiveRewards>((ref) {
  return GetActiveRewards(ref.watch(rewardRepositoryProvider));
});

final redeemRewardUseCaseProvider = Provider<RedeemReward>((ref) {
  return RedeemReward(ref.watch(rewardRepositoryProvider));
});

final rewardsProvider =
    AsyncNotifierProvider<RewardsNotifier, List<Reward>>(RewardsNotifier.new);

class RewardsNotifier extends AsyncNotifier<List<Reward>> {
  @override
  Future<List<Reward>> build() async {
    return _fetchRewards();
  }

  Future<List<Reward>> _fetchRewards() async {
    final result = await ref.read(getActiveRewardsProvider).call();
    return result.fold(
      (failure) => throw failure,
      (rewards) => rewards,
    );
  }
}
