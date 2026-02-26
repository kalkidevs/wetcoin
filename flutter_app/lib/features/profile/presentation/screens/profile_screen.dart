import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../shared/widgets/animated_coin_counter.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../auth/presentation/providers/auth_state_provider.dart';
import '../../../wallet/data/repositories/wallet_repository.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(walletRepositoryProvider).getUserStream();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User Info & Coins
          AppCard(
            padding: const EdgeInsets.all(20),
            child: StreamBuilder(
              stream: userAsync,
              builder: (context, snapshot) {
                final userData = snapshot.data?.data();
                final name = userData?['name'] ?? 'User';
                final email = userData?['email'] ?? '';
                final balance = userData?['balance'] ?? 0;

                return Column(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.person, size: 40, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      email,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    AnimatedCoinCounter(
                        amount: balance is num ? balance.toInt() : 0),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Settings Section
          Text(
            'Settings',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),

          // Theme Toggle
          const _ThemeToggleTile(),

          const SizedBox(height: 16),

          // Other Options
          AppCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('Notifications'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 8),

          AppCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Privacy & Security'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 8),

          AppCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(Icons.help_outline_rounded),
              title: const Text('Help & Support'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () {},
            ),
          ),

          const SizedBox(height: 32),

          AppButton(
            label: 'Logout',
            // icon: Icons.logout,
            type: AppButtonType.secondary,
            onPressed: () {
              ref.read(authStateProvider.notifier).signOut();
            },
          ),
        ],
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
    // Initial state setup if needed
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    // Ensure animation state matches theme mode
    if (isDark && _controller.status != AnimationStatus.completed) {
      _controller.forward();
    } else if (!isDark && _controller.status != AnimationStatus.dismissed) {
      _controller.reverse();
    }

    return AppCard(
      padding: EdgeInsets.zero,
      child: ListTile(
        leading: const Icon(Icons.brightness_6_rounded),
        title: const Text('Dark Mode'),
        onTap: () {
          if (isDark) {
            _controller.reverse();
            ref.read(themeModeProvider.notifier).state = ThemeMode.light;
          } else {
            _controller.forward();
            ref.read(themeModeProvider.notifier).state = ThemeMode.dark;
          }
        },
        trailing: SizedBox(
          width: 60,
          height: 40,
          child: Lottie.asset(
            'assets/toogle.json',
            controller: _controller,
            fit: BoxFit.contain,
            repeat: false,
          ),
        ),
      ),
    );
  }
}
