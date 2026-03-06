import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/wallet_repository.dart';

class WalletState {
  final List<Map<String, dynamic>> transactions;
  final double balance;
  final int lifetimeCoins;
  final int lifetimeSteps;
  final bool isLoading;
  final bool hasMore;
  final int currentSkip;
  final Object? error;

  WalletState({
    this.transactions = const [],
    this.balance = 0.0,
    this.lifetimeCoins = 0,
    this.lifetimeSteps = 0,
    this.isLoading = false,
    this.hasMore = true,
    this.currentSkip = 0,
    this.error,
  });

  WalletState copyWith({
    List<Map<String, dynamic>>? transactions,
    double? balance,
    int? lifetimeCoins,
    int? lifetimeSteps,
    bool? isLoading,
    bool? hasMore,
    int? currentSkip,
    Object? error,
  }) {
    return WalletState(
      transactions: transactions ?? this.transactions,
      balance: balance ?? this.balance,
      lifetimeCoins: lifetimeCoins ?? this.lifetimeCoins,
      lifetimeSteps: lifetimeSteps ?? this.lifetimeSteps,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      currentSkip: currentSkip ?? this.currentSkip,
      error: error,
    );
  }
}

final walletNotifierProvider =
    NotifierProvider<WalletNotifier, WalletState>(WalletNotifier.new);

class WalletNotifier extends Notifier<WalletState> {
  static const int _limit = 15;

  @override
  WalletState build() {
    // Auto-load transactions when provider is first read
    Future.microtask(() => loadTransactions());
    return WalletState();
  }

  Future<void> loadTransactions({bool refresh = false}) async {
    if (state.isLoading) return;
    if (!refresh && !state.hasMore) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(walletRepositoryProvider);
      final skip = refresh ? 0 : state.currentSkip;

      final result = await repository.getWallet(limit: _limit, skip: skip);

      if (result['success'] != true) {
        state = state.copyWith(
          isLoading: false,
          error: result['error'] ?? 'Failed to load wallet',
        );
        return;
      }

      final newTransactions = List<Map<String, dynamic>>.from(result['data'] ?? []);
      final balance = (result['balance'] as num?)?.toDouble() ?? state.balance;
      final lifetimeCoins = (result['lifetimeCoins'] as num?)?.toInt() ?? state.lifetimeCoins;
      final lifetimeSteps = (result['lifetimeSteps'] as num?)?.toInt() ?? state.lifetimeSteps;
      final pagination = result['pagination'] as Map<String, dynamic>?;
      final hasMore = pagination?['hasMore'] ?? false;

      if (refresh) {
        state = state.copyWith(
          transactions: newTransactions,
          balance: balance,
          lifetimeCoins: lifetimeCoins,
          lifetimeSteps: lifetimeSteps,
          isLoading: false,
          hasMore: hasMore,
          currentSkip: skip + newTransactions.length,
        );
      } else {
        state = state.copyWith(
          transactions: [...state.transactions, ...newTransactions],
          balance: balance,
          lifetimeCoins: lifetimeCoins,
          lifetimeSteps: lifetimeSteps,
          isLoading: false,
          hasMore: hasMore,
          currentSkip: skip + newTransactions.length,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e);
    }
  }

  Future<void> refresh() async {
    await loadTransactions(refresh: true);
  }
}
