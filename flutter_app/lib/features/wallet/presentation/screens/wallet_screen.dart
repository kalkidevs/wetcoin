import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_loading_shimmer.dart';
import '../../data/repositories/wallet_repository.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wallet History')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: ref.read(walletRepositoryProvider).getTransactions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: 6,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, __) =>
                  const AppLoadingShimmer(width: double.infinity, height: 72),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final transactions = snapshot.data ?? [];
          if (transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.receipt_long_outlined,
                      size: 64, color: AppColors.textTertiary),
                  const SizedBox(height: 16),
                  Text('No transactions yet',
                      style: AppTypography.textTheme.bodyMedium),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: transactions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final tx = transactions[index];
              final isEarn = tx['type'] == 'earn';
              final amount = tx['amount'] ?? 0;
              final date =
                  (tx['timestamp'] as dynamic)?.toDate() ?? DateTime.now();

              return Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4)),
                  ],
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: isEarn
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.error.withOpacity(0.1),
                    child: Icon(
                      isEarn
                          ? Icons.arrow_downward_rounded
                          : Icons.arrow_upward_rounded,
                      color: isEarn ? AppColors.success : AppColors.error,
                      size: 20,
                    ),
                  ),
                  title: Text(tx['description'] ?? 'Transaction',
                      style: AppTypography.textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  subtitle: Text(DateFormat.yMMMd().add_jm().format(date),
                      style: AppTypography.textTheme.bodySmall),
                  trailing: Text(
                    '${isEarn ? '+' : ''}${amount.toStringAsFixed(2)}',
                    style: AppTypography.textTheme.titleMedium?.copyWith(
                      color: isEarn ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: (50 * index).ms)
                  .slideX(begin: 0.2, end: 0);
            },
          );
        },
      ),
    );
  }
}
