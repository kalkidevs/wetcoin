import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/design_system.dart';
import '../../../../shared/widgets/app_animated_card.dart';
import '../../../../shared/widgets/animated_coin_counter.dart';
import '../providers/wallet_provider.dart';
import '../../data/repositories/wallet_repository.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(walletNotifierProvider.notifier).loadTransactions();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(walletNotifierProvider);
    final walletRepo = ref.watch(walletRepositoryProvider);

    return Scaffold(
      backgroundColor: DesignSystem.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(walletNotifierProvider.notifier).refresh(),
          color: DesignSystem.primary,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Sticky Header with Balance
              SliverAppBar(
                backgroundColor: DesignSystem.background,
                elevation: 0,
                pinned: true,
                expandedHeight: 180,
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: const EdgeInsets.all(DesignSystem.s24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Total Balance',
                          style: TextStyle(
                            color: DesignSystem.textSecondary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: DesignSystem.s8),
                        StreamBuilder(
                          stream: walletRepo.getUserStream(),
                          builder: (context, snapshot) {
                            final balance =
                                snapshot.data?.data()?['balance'] ?? 0;
                            return AnimatedCoinCounter(
                              amount: balance is num ? balance.toInt() : 0,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Title
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: DesignSystem.s24, vertical: DesignSystem.s16),
                  child: Text(
                    'Transaction History',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: DesignSystem.textPrimary,
                    ),
                  ),
                ),
              ),

              // List
              if (state.transactions.isEmpty && !state.isLoading)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_rounded,
                            size: 64,
                            color: DesignSystem.textSecondary.withOpacity(0.3)),
                        const SizedBox(height: DesignSystem.s16),
                        const Text('No transactions yet',
                            style:
                                TextStyle(color: DesignSystem.textSecondary)),
                      ],
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == state.transactions.length) {
                        return state.isLoading
                            ? const Padding(
                                padding: EdgeInsets.all(16.0),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              )
                            : const SizedBox.shrink();
                      }

                      final tx = state.transactions[index];
                      return _buildTransactionItem(tx, index);
                    },
                    childCount: state.transactions.length + 1,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> tx, int index) {
    final isEarn = tx['type'] == 'earn';
    final amount = tx['amount'] ?? 0;
    final description = tx['description'] ?? 'Transaction';

    // Handle timestamp (Timestamp or String/ISO)
    DateTime date;
    if (tx['timestamp'] is Timestamp) {
      date = (tx['timestamp'] as Timestamp).toDate();
    } else if (tx['timestamp'] is String) {
      date = DateTime.tryParse(tx['timestamp']) ?? DateTime.now();
    } else {
      date = DateTime.now();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: DesignSystem.s16, vertical: DesignSystem.s4),
      child: AppAnimatedCard(
        color: DesignSystem.surface,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(DesignSystem.s12),
              decoration: BoxDecoration(
                color: isEarn
                    ? DesignSystem.success.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isEarn
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded,
                color: isEarn ? DesignSystem.success : Colors.red,
                size: 20,
              ),
            ),
            const SizedBox(width: DesignSystem.s16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: DesignSystem.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat.yMMMd().add_jm().format(date),
                    style: const TextStyle(
                      color: DesignSystem.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${isEarn ? '+' : ''}${amount is num ? amount.toStringAsFixed(2) : amount}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isEarn ? DesignSystem.success : Colors.red,
              ),
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(delay: (50 * (index % 10)).ms)
          .slideX(begin: 0.1, end: 0),
    );
  }
}
