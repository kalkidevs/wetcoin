import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_loading_shimmer.dart';
import '../../data/repositories/rewards_repository.dart';

class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rewards')),
      body: StreamBuilder(
        stream: ref.read(rewardsRepositoryProvider).getRewardsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: 6,
              itemBuilder: (_, __) => const AppLoadingShimmer(
                  width: double.infinity, height: double.infinity),
            );
          }
          final rewards = snapshot.data ?? [];
          if (rewards.isEmpty) {
            return Center(
                child: Text('No rewards available',
                    style: AppTypography.textTheme.bodyMedium));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: rewards.length,
            itemBuilder: (context, index) {
              final reward = rewards[index];
              return _RewardCard(reward: reward, index: index);
            },
          );
        },
      ),
    );
  }
}

class _RewardCard extends ConsumerWidget {
  final Map<String, dynamic> reward;
  final int index;

  const _RewardCard({required this.reward, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stock = reward['stock'] ?? 0;
    final isOutOfStock = stock <= 0;

    return AppCard(
      padding: EdgeInsets.zero,
      onTap:
          isOutOfStock ? null : () => _showRedeemDialog(context, ref, reward),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Hero(
                  tag: 'reward_${reward['id']}',
                  child: reward['imageUrl'] != null
                      ? CachedNetworkImage(
                          imageUrl: reward['imageUrl'],
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (_, __, ___) => Container(
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.broken_image)),
                        )
                      : Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.card_giftcard,
                              size: 48, color: Colors.grey)),
                ),
                if (isOutOfStock)
                  Container(
                    color: Colors.black54,
                    alignment: Alignment.center,
                    child: Text('OUT OF STOCK',
                        style: AppTypography.textTheme.labelLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(reward['name'] ?? 'Reward',
                          style: AppTypography.textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text('${reward['cost']} SWC',
                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Text('Stock: $stock',
                      style: AppTypography.textTheme.bodySmall),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (100 * index).ms).slideY(begin: 0.2, end: 0);
  }

  void _showRedeemDialog(
      BuildContext context, WidgetRef ref, Map<String, dynamic> reward) {
    final addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Redeem ${reward['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (reward['imageUrl'] != null)
              Hero(
                tag: 'reward_${reward['id']}_dialog',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                      imageUrl: reward['imageUrl'],
                      height: 150,
                      fit: BoxFit.cover),
                ),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: 'Shipping Address',
                hintText: 'Enter full address...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel')),
          AppButton(
            label: 'Confirm',
            onPressed: () async {
              Navigator.pop(dialogContext);
              if (!context.mounted) return;

              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Processing...')));

              try {
                await ref.read(rewardsRepositoryProvider).redeemReward(
                    reward['id'], {'fullAddress': addressController.text});

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Redemption Successful!'),
                      backgroundColor: AppColors.success));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Failed: $e'),
                      backgroundColor: AppColors.error));
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
