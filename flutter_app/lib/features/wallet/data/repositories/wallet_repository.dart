import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_service.dart';

final walletRepositoryProvider = Provider((ref) => WalletRepository());

class WalletRepository {
  final ApiService _api = ApiService();

  /// Get wallet balance and transaction history from backend API
  Future<Map<String, dynamic>> getWallet({int limit = 20, int skip = 0}) async {
    final userId = await _api.getUserId();
    if (userId == null || userId.isEmpty) {
      return {'success': false, 'error': 'User not logged in'};
    }

    return await _api.get(
      '/api/wallet/$userId',
      queryParams: {
        'limit': limit.toString(),
        'skip': skip.toString(),
      },
    );
  }

  /// Get just the current balance
  Future<double> getBalance() async {
    final result = await getWallet(limit: 0);
    if (result['success'] == true) {
      return (result['balance'] as num?)?.toDouble() ?? 0.0;
    }
    return 0.0;
  }
}
