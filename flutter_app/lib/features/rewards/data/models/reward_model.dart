import 'package:cloud_firestore/cloud_firestore.dart';
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

  factory RewardModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RewardModel(
      id: doc.id,
      title: data['title'] ?? '',
      image: data['image'] ?? '',
      costCoins: data['costCoins'] ?? 0,
      stock: data['stock'] ?? 0,
      active: data['active'] ?? false,
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
