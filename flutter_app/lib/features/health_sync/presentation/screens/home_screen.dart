import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'dart:ui';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/design_system.dart';
import '../../../../shared/widgets/animated_progress_circle.dart';
import '../../../../shared/widgets/confetti_painter.dart';
import '../widgets/weekly_trend_chart.dart';
import '../widgets/metric_card.dart';
import '../providers/health_provider.dart';
import '../providers/sync_provider.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../rewards/presentation/screens/rewards_screen.dart';
import '../../../wallet/presentation/screens/wallet_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ═══════════════════════════════════════════════════════════════════════════════
//  HOME SCREEN — Main scaffold with bottom navigation
// ═══════════════════════════════════════════════════════════════════════════════

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _PremiumBottomNav(
        currentIndex: _currentIndex,
        isDark: isDark,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  PREMIUM BOTTOM NAV — Floating pill with glassmorphism
// ═══════════════════════════════════════════════════════════════════════════════

class _PremiumBottomNav extends StatelessWidget {
  final int currentIndex;
  final bool isDark;
  final ValueChanged<int> onTap;

  const _PremiumBottomNav({
    required this.currentIndex,
    required this.isDark,
    required this.onTap,
  });

  static const _items = [
    _NavData(Icons.directions_walk_rounded, 'Steps'),
    _NavData(Icons.account_balance_wallet_rounded, 'Wallet'),
    _NavData(Icons.card_giftcard_rounded, 'Rewards'),
    _NavData(Icons.person_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: SafeArea(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(DesignSystem.radiusPill),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.65)
                    : Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(DesignSystem.radiusPill),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.06),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(_items.length, (i) {
                  final selected = i == currentIndex;
                  return _NavItemPill(
                    icon: _items[i].icon,
                    label: _items[i].label,
                    isSelected: selected,
                    isDark: isDark,
                    onTap: () => onTap(i),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavData {
  final IconData icon;
  final String label;
  const _NavData(this.icon, this.label);
}

class _NavItemPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _NavItemPill({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(DesignSystem.radiusPill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected
                  ? AppColors.primary
                  : (isDark ? AppColors.textTertiaryDark : AppColors.textTertiary),
            ),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Text(
                  label,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  DASHBOARD TAB — The main screen
// ═══════════════════════════════════════════════════════════════════════════════

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

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String get _userName =>
      FirebaseAuth.instance.currentUser?.displayName?.split(' ').first ?? 'Walker';

  @override
  void initState() {
    super.initState();
    ref.read(healthServiceProvider).requestPermissions().then((granted) {
      if (mounted) _loadData();
    });
  }

  Future<void> _loadData() async {
    try {
      final health = ref.read(healthServiceProvider);
      final now = DateTime.now();

      final steps = await health.getStepsForDate(now);

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
          if (_steps >= 15000) _showConfetti = true;
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
      if (result['success'] == true) {
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Steps synced & coins earned! 🪙'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(result['error'] ?? 'Sync failed. Try again.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Sync failed: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cs = theme.colorScheme;

    final steps = _steps;
    final calories = (steps * 0.04).toInt();
    final distanceKm = (steps * 0.762 / 1000).toStringAsFixed(1);
    final activeMinutes = (steps / 100).toInt();
    final earned = (min<num>(steps, 15000) / 100).floor();
    final progress = (steps / 15000).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: ConfettiSystem(
        shouldBlast: _showConfetti,
        child: RefreshIndicator(
          onRefresh: _sync,
          color: cs.primary,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Hero Header ────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 60, 24, 28),
                  decoration: BoxDecoration(
                    gradient: isDark
                        ? DesignSystem.heroGradientDark
                        : DesignSystem.heroGradient,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$_greeting,',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _userName,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          // Date badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(DesignSystem.radiusPill),
                            ),
                            child: Text(
                              DateFormat('d MMM').format(DateTime.now()),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Progress ring centered
                      Center(
                        child: AnimatedProgressCircle(
                          progress: progress,
                          currentSteps: steps,
                          goalSteps: 15000,
                          coinsEarned: earned,
                          size: 200,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Goal text
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(DesignSystem.radiusPill),
                          ),
                          child: Text(
                            'Goal: 15,000 steps  •  ${(progress * 100).toInt()}% done',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms),
              ),

              // ── Body Content ───────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Quick Stats Row ──────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: MetricCard(
                              icon: Icons.local_fire_department_rounded,
                              label: 'Calories',
                              value: '$calories',
                              unit: 'kcal',
                              color: AppColors.caloriesOrange,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: MetricCard(
                              icon: Icons.straighten_rounded,
                              label: 'Distance',
                              value: distanceKm,
                              unit: 'km',
                              color: AppColors.distanceBlue,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: MetricCard(
                              icon: Icons.timer_outlined,
                              label: 'Active',
                              value: '$activeMinutes',
                              unit: 'min',
                              color: AppColors.activeGreen,
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.08, end: 0),

                      const SizedBox(height: 20),

                      // ── Coin Earning Card ────────────────────────────
                      _CoinEarningCard(
                        earned: earned,
                        maxCoins: 150,
                        isDark: isDark,
                        syncing: _syncing,
                        onSync: _sync,
                      ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.08, end: 0),

                      const SizedBox(height: 20),

                      // ── Motivation Insight ───────────────────────────
                      if (steps > 0)
                        _MotivationCard(
                          steps: steps,
                          isDark: isDark,
                        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.08, end: 0),

                      if (steps > 0) const SizedBox(height: 20),

                      // ── Health Connect Help (only if 0 steps) ────────
                      if (steps == 0)
                        _PermissionHelpCard(
                          isDark: isDark,
                          onRequestPermission: () async {
                            await ref.read(healthServiceProvider).requestPermissions();
                            await _sync();
                          },
                        ).animate().fadeIn(delay: 200.ms),

                      if (steps == 0) const SizedBox(height: 20),

                      // ── Weekly Trend ─────────────────────────────────
                      _SectionHeader(title: 'This Week', isDark: isDark),
                      const SizedBox(height: 12),
                      WeeklyTrendChart(
                        weeklySteps: _weeklySteps,
                        labels: _weeklyLabels,
                        barColor: cs.primary,
                      ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.08, end: 0),

                      const SizedBox(height: 100), // Bottom padding for floating nav
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

// ═══════════════════════════════════════════════════════════════════════════════
//  SUB-COMPONENTS
// ═══════════════════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;
  final Widget? trailing;

  const _SectionHeader({required this.title, required this.isDark, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _CoinEarningCard extends StatelessWidget {
  final int earned;
  final int maxCoins;
  final bool isDark;
  final bool syncing;
  final VoidCallback onSync;

  const _CoinEarningCard({
    required this.earned,
    required this.maxCoins,
    required this.isDark,
    required this.syncing,
    required this.onSync,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final coinProgress = (earned / maxCoins).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: isDark
            ? LinearGradient(
                colors: [
                  const Color(0xFF2A1F00).withValues(alpha: 0.8),
                  const Color(0xFF1A1200).withValues(alpha: 0.6),
                ],
              )
            : const LinearGradient(
                colors: [Color(0xFFFFF8E1), Color(0xFFFFF3C4)],
              ),
        borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
        border: Border.all(
          color: AppColors.coinGold.withValues(alpha: isDark ? 0.2 : 0.3),
        ),
        boxShadow: isDark
            ? null
            : DesignSystem.glow(AppColors.coinGold, intensity: 0.08),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Coin icon with glow
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: DesignSystem.coinGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: DesignSystem.glow(AppColors.coinGold, intensity: 0.25),
                ),
                child: const Icon(Icons.monetization_on_rounded,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Coins Earned Today',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$earned',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.coinGoldDark,
                          ),
                        ),
                        Text(
                          ' / $maxCoins SWC',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Sync button
              GestureDetector(
                onTap: syncing ? null : onSync,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: syncing ? null : DesignSystem.heroGradient,
                    color: syncing
                        ? theme.colorScheme.surfaceContainerHighest
                        : null,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: syncing
                        ? null
                        : DesignSystem.glow(AppColors.primary, intensity: 0.2),
                  ),
                  child: syncing
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.primary,
                          ),
                        )
                      : const Icon(Icons.sync_rounded,
                          color: Colors.white, size: 22),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Coin progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : AppColors.coinGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  widthFactor: coinProgress,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: DesignSystem.coinGradient,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MotivationCard extends StatelessWidget {
  final int steps;
  final bool isDark;

  const _MotivationCard({required this.steps, required this.isDark});

  String get _insight {
    if (steps >= 15000) return '🏆 Goal smashed! You\'re a walking legend today!';
    if (steps >= 10000) return '🔥 Amazing progress! Just ${15000 - steps} more steps to go!';
    if (steps >= 5000) return '💪 Over halfway there! Keep the momentum going!';
    if (steps >= 1000) return '🚶 Great start! Every step earns you coins.';
    return '👟 Let\'s get moving! Walk to earn coins today.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(DesignSystem.radiusCard),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: isDark ? 0.1 : 0.1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _insight,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionHelpCard extends StatelessWidget {
  final bool isDark;
  final VoidCallback onRequestPermission;

  const _PermissionHelpCard({
    required this.isDark,
    required this.onRequestPermission,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.error.withValues(alpha: 0.08)
            : AppColors.errorLight,
        borderRadius: BorderRadius.circular(DesignSystem.radiusCard),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.info_outline_rounded,
                    color: AppColors.error, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Steps not showing?',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            Theme.of(context).platform == TargetPlatform.iOS
                ? '1. Open Apple Health → Sharing → Apps\n'
                  '2. Select Sweatcoin → Turn ON Steps'
                : '1. Install Health Connect from Play Store\n'
                  '2. Open Google Fit → Enable Health Connect sync\n'
                  '3. Grant Steps permission to this app',
            style: theme.textTheme.bodySmall?.copyWith(height: 1.6),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onRequestPermission,
              icon: const Icon(Icons.security_rounded, size: 16),
              label: const Text('Grant Permissions'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated width transition for progress bars.
class AnimatedFractionallySizedBox extends StatelessWidget {
  final double widthFactor;
  final Duration duration;
  final Curve curve;
  final Widget child;

  const AnimatedFractionallySizedBox({
    super.key,
    required this.widthFactor,
    required this.duration,
    required this.curve,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: widthFactor),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: value,
          child: child,
        );
      },
      child: child,
    );
  }
}
