import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/reward.dart';
import '../../domain/repositories/reward_repository.dart';
import '../datasources/reward_remote_datasource.dart';

class RewardRepositoryImpl implements RewardRepository {
  final RewardRemoteDataSource remoteDataSource;

  RewardRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Reward>>> getActiveRewards() async {
    try {
      final rewardModels = await remoteDataSource.getActiveRewards();
      return Right(rewardModels.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> redeemReward(
      {required String rewardId, required String shippingAddress}) async {
    try {
      final orderId = await remoteDataSource.redeemReward(
        rewardId: rewardId,
        shippingAddress: shippingAddress,
      );
      return Right(orderId);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
