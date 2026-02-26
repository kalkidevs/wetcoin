import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../../../../core/theme/design_system.dart';
import '../../../../shared/widgets/animated_progress_circle.dart';
import '../../../../shared/widgets/confetti_painter.dart';
import '../../../../shared/widgets/animated_gradient_background.dart';
import '../../../../shared/widgets/app_loading_animation.dart';
import '../widgets/weekly_trend_chart.dart';
import '../widgets/metric_card.dart';
import '../providers/health_provider.dart';
import '../providers/sync_provider.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
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
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildCustomBottomNav(),
    );
  }

  Widget _buildCustomBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).bottomNavigationBarTheme.backgroundColor ??
            Theme.of(context).cardColor,
        boxShadow: DesignSystem.elevationMedium,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.directions_walk_rounded,
              label: 'Steps',
              isSelected: _currentIndex == 0,
              onTap: () => setState(() => _currentIndex = 0),
            ),
            _NavItem(
              icon: Icons.account_balance_wallet_rounded,
              label: 'Wallet',
              isSelected: _currentIndex == 1,
              onTap: () => setState(() => _currentIndex = 1),
            ),
            _NavItem(
              icon: Icons.card_giftcard_rounded,
              label: 'Rewards',
              isSelected: _currentIndex == 2,
              onTap: () => setState(() => _currentIndex = 2),
            ),
            _NavItem(
              icon: Icons.person_outline_rounded,
              label: 'Profile',
              isSelected: _currentIndex == 3,
              onTap: () => setState(() => _currentIndex = 3),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: DesignSystem.durationFast,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? DesignSystem.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).textTheme.bodyMedium?.color,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ).animate().fadeIn().slideX(begin: -0.2, end: 0),
            ],
          ],
        ),
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
  bool _showConfetti = false;
  List<int> _weeklySteps = [];
  List<String> _weeklyLabels = [];

  @override
  void initState() {
    super.initState();
    // Only load data after attempting to request permissions
    ref.read(healthServiceProvider).requestPermissions().then((granted) {
      if (mounted) {
        _loadData();
      }
    });
  }

  Future<void> _loadData() async {
    try {
      final health = ref.read(healthServiceProvider);
      final now = DateTime.now();

      // 1. Get Today's Steps
      final steps = await health.getStepsForDate(now);

      // 2. Get Weekly History (Last 7 days)
      final weeklySteps = <int>[];
      final weeklyLabels = <String>[];
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final daySteps = await health.getStepsForDate(date);
        weeklySteps.add(daySteps);
        weeklyLabels.add(DateFormat('E').format(date).substring(0, 1));
      }

      if (mounted) {
        setState(() {
          _steps = steps;
          _weeklySteps = weeklySteps;
          _weeklyLabels = weeklyLabels;
          if (_steps >= 15000) {
            _showConfetti = true;
          }
        });
      }
    } catch (e) {
      debugPrint("Error loading dashboard data: $e");
    }
  }

  Future<void> _sync() async {
    setState(() => _syncing = true);
    try {
      final result = await ref.read(syncServiceProvider).syncToday();

      // Check if sync was successful or if we got a fallback response
      if (result['success'] == true) {
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text('Synced successfully!'),
              backgroundColor: Theme.of(context).colorScheme.primary));
        }
      } else if (result['fallback'] == true) {
        // Handle fallback gracefully
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(result['error'] ?? 'Sync service unavailable'),
              backgroundColor: Theme.of(context).colorScheme.secondary));
        }
      } else {
        // Handle other sync failures
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text('Sync failed. Please try again later.'),
              backgroundColor: Theme.of(context).colorScheme.error));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Sync failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error));
      }
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userAsync = ref.watch(walletRepositoryProvider).getUserStream();
    final pedometerAsync = ref.watch(pedometerStreamProvider);
    final healthService = ref.watch(healthServiceProvider);
    final isFallback = healthService.isUsingPedometer;

    // Calculate metrics
    final currentSteps = isFallback && pedometerAsync.value != null
        ? (pedometerAsync.value?.steps ?? _steps)
        : _steps;

    final calories = (currentSteps * 0.04).toInt();
    final distanceKm = (currentSteps * 0.762 / 1000).toStringAsFixed(2);
    final activeMinutes = (currentSteps / 100).toInt();

    // Potential coins (1 coin per 100 steps, max 150)
    final earned = (min(currentSteps, 15000) / 100).floor();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedGradientBackground(
        child: ConfettiSystem(
          shouldBlast: _showConfetti,
          child: RefreshIndicator(
            onRefresh: _sync,
            color: theme.primaryColor,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Premium Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StreamBuilder(
                          stream: userAsync,
                          builder: (context, snapshot) {
                            final name = snapshot.data
                                    ?.data()?['name']
                                    ?.toString()
                                    .split(' ')
                                    .first ??
                                'Walker';
                            return Text(
                              'Good Morning, $name',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.bodyLarge?.color
                                    ?.withOpacity(0.8),
                              ),
                            );
                          },
                        ),
                        Text(
                          DateFormat('EEEE, d MMMM').format(DateTime.now()),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color
                                ?.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Main Dashboard Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        // Main Progress Ring Card
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              AnimatedProgressCircle(
                                steps: currentSteps,
                                goal: 15000,
                                size: 220,
                              ),
                              const SizedBox(height: 24),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer
                                      .withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.monetization_on_rounded,
                                        size: 16, color: theme.primaryColor),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Earned today: $earned SWC',
                                      style:
                                          theme.textTheme.labelLarge?.copyWith(
                                        color: theme.primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn().slideY(begin: 0.1, end: 0),

                        const SizedBox(height: 24),

                        // Metrics Grid
                        Row(
                          children: [
                            Expanded(
                              child: MetricCard(
                                label: 'Calories',
                                value: '$calories',
                                unit: 'kcal',
                                icon: Icons.local_fire_department_rounded,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: MetricCard(
                                label: 'Distance',
                                value: distanceKm,
                                unit: 'km',
                                icon: Icons.map_rounded,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        )
                            .animate()
                            .fadeIn(delay: 100.ms)
                            .slideY(begin: 0.1, end: 0),

                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: MetricCard(
                                label: 'Active Time',
                                value: '$activeMinutes',
                                unit: 'min',
                                icon: Icons.timer_rounded,
                                color: Colors.purple,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Placeholder or another metric if needed, or leave empty/full width
                            Expanded(
                              child: _syncing
                                  ? Container(
                                      height: 100,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: theme.cardColor,
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      child: const AppLoadingAnimation(
                                          width: 50, height: 50),
                                    )
                                  : GestureDetector(
                                      onTap: _sync,
                                      child: Container(
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: theme.primaryColor,
                                          borderRadius:
                                              BorderRadius.circular(24),
                                          boxShadow: [
                                            BoxShadow(
                                              color: theme.primaryColor
                                                  .withOpacity(0.3),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: const Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.sync_rounded,
                                                color: Colors.white, size: 32),
                                            SizedBox(height: 8),
                                            Text(
                                              'Sync Now',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                            ),
                          ],
                        )
                            .animate()
                            .fadeIn(delay: 150.ms)
                            .slideY(begin: 0.1, end: 0),

                        const SizedBox(height: 24),

                        // Weekly Trend
                        WeeklyTrendChart(
                          weeklySteps: _weeklySteps,
                          labels: _weeklyLabels,
                          barColor: theme.primaryColor,
                        )
                            .animate()
                            .fadeIn(delay: 200.ms)
                            .slideY(begin: 0.1, end: 0),

                        const SizedBox(height: 24),

                        // Motivation Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.primaryColor.withOpacity(0.1),
                                theme.colorScheme.secondary.withOpacity(0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: theme.primaryColor.withOpacity(0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Text(
                                '🔥',
                                style: TextStyle(fontSize: 24),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'You are doing great! Keep moving to reach your daily goal.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: theme.textTheme.bodyLarge?.color
                                        ?.withOpacity(0.8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 300.ms)
                            .slideY(begin: 0.1, end: 0),

                        const SizedBox(height: 100), // Bottom padding
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
