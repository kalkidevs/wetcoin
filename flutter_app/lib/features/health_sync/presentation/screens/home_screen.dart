import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/animated_counter.dart';
import '../../../../shared/widgets/app_loading_shimmer.dart';
import '../../../auth/presentation/providers/auth_state_provider.dart';
import '../providers/health_provider.dart';
import '../providers/sync_provider.dart';
import '../../../orders/presentation/screens/orders_screen.dart';
import '../../../rewards/presentation/screens/rewards_screen.dart';
import '../../../wallet/data/repositories/wallet_repository.dart';
import '../../../wallet/presentation/screens/wallet_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardTab(),
    const WalletScreen(),
    const RewardsScreen(),
    const OrdersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 8,
        indicatorColor: AppColors.primary.withOpacity(0.1),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.directions_walk_outlined),
              selectedIcon:
                  Icon(Icons.directions_walk, color: AppColors.primary),
              label: 'Steps'),
          NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined),
              selectedIcon:
                  Icon(Icons.account_balance_wallet, color: AppColors.primary),
              label: 'Wallet'),
          NavigationDestination(
              icon: Icon(Icons.card_giftcard_outlined),
              selectedIcon: Icon(Icons.card_giftcard, color: AppColors.primary),
              label: 'Rewards'),
          NavigationDestination(
              icon: Icon(Icons.shopping_bag_outlined),
              selectedIcon: Icon(Icons.shopping_bag, color: AppColors.primary),
              label: 'Orders'),
        ],
      ),
    );
  }
}

class DashboardTab extends ConsumerStatefulWidget {
  const DashboardTab({super.key});

  @override
  ConsumerState<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends ConsumerState<DashboardTab> {
  int _steps = 0;
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    _loadSteps();
    ref.read(healthServiceProvider).requestPermissions().then((granted) {
      _loadSteps();
    });
  }

  Future<void> _loadSteps() async {
    final steps =
        await ref.read(healthServiceProvider).getStepsForDate(DateTime.now());
    if (mounted) setState(() => _steps = steps);
  }

  Future<void> _sync() async {
    setState(() => _syncing = true);
    try {
      await ref.read(syncServiceProvider).syncToday();
      await _loadSteps();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Synced successfully!'),
            backgroundColor: AppColors.success));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Sync failed: $e'),
            backgroundColor: AppColors.error));
      }
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(walletRepositoryProvider).getUserStream();
    final pedometerAsync = ref.watch(pedometerStreamProvider);
    final healthService = ref.watch(healthServiceProvider);
    final isFallback = healthService.isUsingPedometer;

    return Scaffold(
      appBar: AppBar(
        title:
            Text('Sweatcoin India', style: AppTypography.textTheme.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authStateProvider.notifier).signOut(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _sync,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                // Balance Card
                StreamBuilder(
                  stream: userAsync,
                  builder: (context, snapshot) {
                    final balance = snapshot.data?.data()?['balance'] ?? 0;
                    return AppCard(
                      color: AppColors.primary,
                      padding: const EdgeInsets.all(24.0),
                      elevation: 8,
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          children: [
                            Text(
                              'Balance',
                              style: AppTypography.textTheme.bodyMedium
                                  ?.copyWith(color: Colors.white70),
                            ),
                            const SizedBox(height: 8),
                            AnimatedCounter(
                              value: balance is num ? balance.toInt() : 0,
                              style: AppTypography.textTheme.displayMedium
                                  ?.copyWith(color: Colors.white),
                            ),
                            Text('SWC',
                                style: AppTypography.textTheme.labelLarge),
                          ],
                        ),
                      ),
                    ).animate().fadeIn().slideY(begin: 0.2, end: 0);
                  },
                ),
                const SizedBox(height: 40),
                // Steps Indicator
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 240,
                      height: 240,
                      child: CircularProgressIndicator(
                        value: (_steps / 15000).clamp(0.0, 1.0),
                        strokeWidth: 20,
                        backgroundColor: Colors.grey.shade100,
                        color: AppColors.secondary,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      children: [
                        const Icon(Icons.directions_run,
                            size: 48, color: AppColors.textSecondary),
                        const SizedBox(height: 8),
                        AnimatedCounter(
                          value: isFallback && pedometerAsync.value != null
                              ? (pedometerAsync.value?.steps ?? _steps)
                              : _steps,
                          style: AppTypography.textTheme.displayLarge,
                        ),
                        Text(
                          isFallback ? 'Total Steps' : 'Steps Today',
                          style: AppTypography.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),

                const SizedBox(height: 16),
                if (isFallback)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: AppColors.warning.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.info_outline,
                            size: 16, color: AppColors.warning),
                        const SizedBox(width: 8),
                        Text(
                          'Using Pedometer Mode',
                          style: AppTypography.textTheme.bodySmall?.copyWith(
                              color: AppColors.warning,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(),

                const SizedBox(height: 24),
                Text(
                  'Goal: 15,000 steps',
                  style: AppTypography.textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 40),

                if (_syncing)
                  const AppLoadingShimmer(width: 150, height: 50)
                else
                  AppButton(
                    label: 'Sync Now',
                    icon: Icons.sync,
                    onPressed: _sync,
                    type: AppButtonType.secondary,
                  ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
