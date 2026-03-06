import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/design_system.dart';
import '../providers/rewards_provider.dart';
import '../../domain/entities/reward.dart';

class RewardCard extends ConsumerStatefulWidget {
  final Reward reward;

  const RewardCard({super.key, required this.reward});

  @override
  ConsumerState<RewardCard> createState() => _RewardCardState();
}

class _RewardCardState extends ConsumerState<RewardCard> {
  bool _isLoading = false;

  Future<void> _handleRedeem(BuildContext context) async {
    final addressController = TextEditingController();

    final shouldRedeem = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Redeem ${widget.reward.title}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: DesignSystem.coinGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.monetization_on_rounded, size: 16, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    '${widget.reward.costCoins} SWC',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: 'Shipping Address',
                hintText: 'Enter your full address',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (shouldRedeem == true && addressController.text.isNotEmpty) {
      setState(() => _isLoading = true);
      try {
        final result = await ref.read(redeemRewardUseCaseProvider).call(
              rewardId: widget.reward.id,
              shippingAddress: addressController.text,
            );
        result.fold(
          (failure) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${failure.message}'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          (orderId) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Redeemed! Order #$orderId 🎉'),
                  backgroundColor: AppColors.success,
                ),
              );
              ref.invalidate(rewardsProvider);
            }
          },
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: widget.reward.isOutOfStock || _isLoading
          ? null
          : () => _handleRedeem(context),
      child: AnimatedScale(
        scale: _isLoading ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white,
            borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05),
            ),
            boxShadow: isDark
                ? null
                : DesignSystem.elevationSoft(Colors.black),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Image Section ─────────────────────────────────────
              Expanded(
                flex: 55,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: widget.reward.image,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: cs.surfaceContainerHighest,
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: cs.primary.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: cs.surfaceContainerHighest,
                        child: Icon(Icons.card_giftcard_rounded,
                            color: cs.onSurface.withValues(alpha: 0.15), size: 32),
                      ),
                    ),

                    // Price badge (top-right)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: DesignSystem.coinGradient,
                          borderRadius: BorderRadius.circular(DesignSystem.radiusPill),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.monetization_on_rounded,
                                size: 12, color: Colors.white),
                            const SizedBox(width: 3),
                            Text(
                              '${widget.reward.costCoins}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Out of stock overlay
                    if (widget.reward.isOutOfStock)
                      Container(
                        color: Colors.black.withValues(alpha: 0.55),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(DesignSystem.radiusPill),
                            ),
                            child: const Text(
                              'Sold Out',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // ── Info Section ──────────────────────────────────────
              Expanded(
                flex: 45,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.reward.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                          fontSize: 13,
                        ),
                      ),

                      // Stock indicator + Redeem
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Stock indicator
                          _StockIndicator(
                            stock: widget.reward.stock,
                            isDark: isDark,
                          ),

                          // Redeem button
                          SizedBox(
                            height: 28,
                            child: FilledButton(
                              onPressed: widget.reward.isOutOfStock || _isLoading
                                  ? null
                                  : () => _handleRedeem(context),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(DesignSystem.radiusPill)),
                                textStyle: const TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.w700),
                              ),
                              child: _isLoading
                                  ? SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: cs.onPrimary,
                                      ),
                                    )
                                  : const Text('Get'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StockIndicator extends StatelessWidget {
  final int stock;
  final bool isDark;

  const _StockIndicator({required this.stock, required this.isDark});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    if (stock <= 0) {
      color = AppColors.error;
      text = 'Sold out';
    } else if (stock <= 5) {
      color = AppColors.warning;
      text = '$stock left';
    } else {
      color = AppColors.success;
      text = 'In stock';
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
