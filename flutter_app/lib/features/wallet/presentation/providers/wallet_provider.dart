import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/wallet_repository.dart';

class WalletState {
  final List<Map<String, dynamic>> transactions;
  final bool isLoading;
  final bool hasMore;
  final DocumentSnapshot? lastDocument;
  final Object? error;

  WalletState({
    this.transactions = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.lastDocument,
    this.error,
  });

  WalletState copyWith({
    List<Map<String, dynamic>>? transactions,
    bool? isLoading,
    bool? hasMore,
    DocumentSnapshot? lastDocument,
    Object? error,
  }) {
    return WalletState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      lastDocument: lastDocument ?? this.lastDocument,
      error: error,
    );
  }
}

final walletNotifierProvider =
    StateNotifierProvider<WalletNotifier, WalletState>((ref) {
  return WalletNotifier(ref.watch(walletRepositoryProvider));
});

class WalletNotifier extends StateNotifier<WalletState> {
  final WalletRepository _repository;
  static const int _limit = 15;

  WalletNotifier(this._repository) : super(WalletState()) {
    loadTransactions();
  }

  Future<void> loadTransactions({bool refresh = false}) async {
    if (state.isLoading) return;
    if (!refresh && !state.hasMore) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final snapshot = await _repository.getTransactions(
        limit: _limit,
        lastDocument: refresh ? null : state.lastDocument,
      );

      final newTransactions = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Add ID
        return data;
      }).toList();

      if (refresh) {
        state = state.copyWith(
          transactions: newTransactions,
          isLoading: false,
          hasMore: newTransactions.length >= _limit,
          lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
        );
      } else {
        state = state.copyWith(
          transactions: [...state.transactions, ...newTransactions],
          isLoading: false,
          hasMore: newTransactions.length >= _limit,
          lastDocument: snapshot.docs.isNotEmpty
              ? snapshot.docs.last
              : state.lastDocument,
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
