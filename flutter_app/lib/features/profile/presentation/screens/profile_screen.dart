import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/design_system.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../shared/widgets/app_warning_dialog.dart';
import '../../../auth/presentation/providers/auth_state_provider.dart';
import '../../../health_sync/presentation/providers/health_provider.dart';
import '../../../wallet/presentation/providers/wallet_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;
    final walletState = ref.watch(walletNotifierProvider);
    final name = user?.displayName ?? 'User';
    final email = user?.email ?? '';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Hero Header ──────────────────────────────────────────────
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
                children: [
                  // Avatar
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35),
                        width: 2.5,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      backgroundImage: user?.photoURL != null
                          ? NetworkImage(user!.photoURL!)
                          : null,
                      child: user?.photoURL == null
                          ? Text(
                              name.isNotEmpty ? name[0].toUpperCase() : 'U',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),
          ),

          // ── Stats Row ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.04),
                  ),
                  boxShadow: isDark
                      ? null
                      : DesignSystem.elevationSoft(Colors.black),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatItem(
                        icon: Icons.directions_walk_rounded,
                        color: AppColors.primary,
                        value: _formatNumber(walletState.lifetimeSteps),
                        label: 'Total Steps',
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 36,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.06),
                    ),
                    Expanded(
                      child: _StatItem(
                        icon: Icons.monetization_on_rounded,
                        color: AppColors.coinGold,
                        value: '${walletState.lifetimeCoins}',
                        label: 'Coins Earned',
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 36,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.06),
                    ),
                    Expanded(
                      child: _StatItem(
                        icon: Icons.calendar_today_rounded,
                        color: AppColors.distanceBlue,
                        value: '${walletState.lifetimeCoins > 0 ? (walletState.lifetimeSteps / 15000).ceil().clamp(1, 999) : 0}',
                        label: 'Days Active',
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05, end: 0),
            ),
          ),

          // ── Achievement Badges ───────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Achievements',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 90,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _AchievementBadge(
                          emoji: '👟',
                          title: 'First Steps',
                          subtitle: '1K steps',
                          isUnlocked: walletState.lifetimeSteps >= 1000,
                          isDark: isDark,
                        ),
                        _AchievementBadge(
                          emoji: '🏃',
                          title: 'Runner',
                          subtitle: '5K steps',
                          isUnlocked: walletState.lifetimeSteps >= 5000,
                          isDark: isDark,
                        ),
                        _AchievementBadge(
                          emoji: '🔥',
                          title: 'On Fire',
                          subtitle: '10K steps',
                          isUnlocked: walletState.lifetimeSteps >= 10000,
                          isDark: isDark,
                        ),
                        _AchievementBadge(
                          emoji: '🏆',
                          title: 'Champion',
                          subtitle: '50K steps',
                          isUnlocked: walletState.lifetimeSteps >= 50000,
                          isDark: isDark,
                        ),
                        _AchievementBadge(
                          emoji: '💎',
                          title: 'Legend',
                          subtitle: '100K steps',
                          isUnlocked: walletState.lifetimeSteps >= 100000,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.05, end: 0),
          ),

          // ── Settings Section ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Settings card group
                  Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.04)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.04),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Theme toggle
                        const _ThemeToggleTile(),
                        _SettingDivider(isDark: isDark),

                        // Health Connect
                        if (Theme.of(context).platform == TargetPlatform.android) ...[
                          _SettingTile(
                            icon: Icons.health_and_safety_rounded,
                            iconColor: AppColors.activeGreen,
                            title: 'Health Connect',
                            subtitle: 'Manage step permissions',
                            isDark: isDark,
                            onTap: () async {
                              try {
                                await ref.read(healthServiceProvider).requestPermissions();
                              } catch (e) {
                                debugPrint('Error: $e');
                              }
                            },
                          ),
                          _SettingDivider(isDark: isDark),
                        ],

                        _SettingTile(
                          icon: Icons.notifications_outlined,
                          iconColor: AppColors.warning,
                          title: 'Notifications',
                          subtitle: 'Manage push notifications',
                          isDark: isDark,
                          onTap: () {},
                        ),
                        _SettingDivider(isDark: isDark),

                        _SettingTile(
                          icon: Icons.lock_outline_rounded,
                          iconColor: AppColors.distanceBlue,
                          title: 'Privacy & Security',
                          subtitle: 'Account security settings',
                          isDark: isDark,
                          onTap: () {},
                        ),
                        _SettingDivider(isDark: isDark),

                        _SettingTile(
                          icon: Icons.help_outline_rounded,
                          iconColor: AppColors.rewardPurple,
                          title: 'Help & Support',
                          subtitle: 'FAQ, contact us',
                          isDark: isDark,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Logout button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final shouldLogout = await showAppWarningDialog(
                          context: context,
                          title: 'Confirm Logout',
                          message:
                              'Are you sure you want to log out? You will need to sign in again to sync your steps.',
                          confirmText: 'Logout',
                          cancelText: 'Cancel',
                        );
                        if (shouldLogout == true && context.mounted) {
                          ref.read(authStateProvider.notifier).signOut();
                        }
                      },
                      icon: const Icon(Icons.logout_rounded, size: 18),
                      label: const Text('Logout'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: BorderSide(
                            color: AppColors.error.withValues(alpha: 0.3)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
                        ),
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05, end: 0),
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  SUB-COMPONENTS
// ═══════════════════════════════════════════════════════════════════════════════

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final bool isUnlocked;
  final bool isDark;

  const _AchievementBadge({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.isUnlocked,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: isUnlocked
            ? (isDark
                ? AppColors.coinGold.withValues(alpha: 0.08)
                : AppColors.coinGold.withValues(alpha: 0.06))
            : (isDark
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.black.withValues(alpha: 0.03)),
        borderRadius: BorderRadius.circular(DesignSystem.radiusCard),
        border: Border.all(
          color: isUnlocked
              ? AppColors.coinGold.withValues(alpha: 0.2)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.04)),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isUnlocked ? emoji : '🔒',
            style: TextStyle(fontSize: isUnlocked ? 22 : 18),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 10,
              color: isUnlocked
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurface.withValues(alpha: 0.35),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 9,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool isDark;
  final VoidCallback onTap;

  const _SettingTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: isDark ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingDivider extends StatelessWidget {
  final bool isDark;
  const _SettingDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.04),
      ),
    );
  }
}

class _ThemeToggleTile extends ConsumerStatefulWidget {
  const _ThemeToggleTile();

  @override
  ConsumerState<_ThemeToggleTile> createState() => _ThemeToggleTileState();
}

class _ThemeToggleTileState extends ConsumerState<_ThemeToggleTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final themeMode = ref.watch(themeModeProvider);
    final isModeDark = themeMode == ThemeMode.dark;

    if (isModeDark && _controller.status != AnimationStatus.completed) {
      _controller.forward();
    } else if (!isModeDark && _controller.status != AnimationStatus.dismissed) {
      _controller.reverse();
    }

    return InkWell(
      onTap: () {
        if (isModeDark) {
          _controller.reverse();
          ref.read(themeModeProvider.notifier).state = ThemeMode.light;
        } else {
          _controller.forward();
          ref.read(themeModeProvider.notifier).state = ThemeMode.dark;
        }
      },
      borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: isDark ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.brightness_6_rounded,
                  color: cs.primary, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dark Mode',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    isModeDark ? 'Currently dark' : 'Currently light',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.45),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 56,
              height: 36,
              child: Lottie.asset(
                'assets/toogle.json',
                controller: _controller,
                fit: BoxFit.contain,
                repeat: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
