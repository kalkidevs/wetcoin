import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_service.dart';

final orderRepositoryProvider = Provider((ref) => OrderRepository());

class OrderRepository {
  final ApiService _api = ApiService();

  /// Get user's order history from backend API
  Future<Map<String, dynamic>> getUserOrders({
    int limit = 20,
    int skip = 0,
    String? status,
  }) async {
    final userId = await _api.getUserId();
    if (userId == null || userId.isEmpty) {
      return {'success': false, 'error': 'User not logged in'};
    }

    final queryParams = <String, String>{
      'limit': limit.toString(),
      'skip': skip.toString(),
    };
    if (status != null) {
      queryParams['status'] = status;
    }

    return await _api.get('/api/orders/$userId', queryParams: queryParams);
  }

  /// Get orders as a stream-like list (for compatibility with existing UI)
  Future<List<Map<String, dynamic>>> getOrdersList() async {
    final result = await getUserOrders();
    if (result['success'] == true) {
      return List<Map<String, dynamic>>.from(result['data'] ?? []);
    }
    return [];
  }
}
