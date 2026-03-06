import '../../domain/entities/reward.dart';

class RewardModel extends Reward {
  const RewardModel({
    required super.id,
    required super.title,
    required super.image,
    required super.costCoins,
    required super.stock,
    required super.active,
  });

  /// Parse from backend REST API JSON response
  /// Backend returns: { _id, name, cost, description, imageUrl, stock, active }
  factory RewardModel.fromJson(Map<String, dynamic> json) {
    return RewardModel(
      id: json['_id']?.toString() ?? '',
      title: json['name'] ?? json['title'] ?? '',
      image: json['imageUrl'] ?? json['image'] ?? '',
      costCoins: (json['cost'] ?? json['costCoins'] ?? 0) as int,
      stock: (json['stock'] ?? 0) as int,
      active: json['active'] ?? false,
    );
  }

  Reward toEntity() {
    return Reward(
      id: id,
      title: title,
      image: image,
      costCoins: costCoins,
      stock: stock,
      active: active,
    );
  }
}
