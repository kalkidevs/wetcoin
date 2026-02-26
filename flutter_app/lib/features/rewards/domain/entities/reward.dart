import 'package:equatable/equatable.dart';

class Reward extends Equatable {
  final String id;
  final String title;
  final String image;
  final int costCoins;
  final int stock;
  final bool active;

  const Reward({
    required this.id,
    required this.title,
    required this.image,
    required this.costCoins,
    required this.stock,
    required this.active,
  });

  bool get isOutOfStock => stock <= 0;

  @override
  List<Object?> get props => [id, title, image, costCoins, stock, active];
}
