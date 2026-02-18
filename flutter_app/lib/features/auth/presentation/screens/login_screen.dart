import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../providers/auth_state_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    // Listen for errors
    ref.listen(authStateProvider, (previous, next) {
      if (next.status == AuthStatus.unauthenticated &&
          next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.directions_run_rounded,
                      size: 80,
                      color: Colors.white,
                    ),
                  )
                      .animate()
                      .scale(duration: 600.ms, curve: Curves.easeOutBack),
                  const SizedBox(height: 24),

                  // App Name
                  Text(
                    'Sweatcoin India',
                    style: AppTypography.textTheme.displayLarge?.copyWith(
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ).animate().fadeIn().slideY(begin: 0.3, end: 0),
                  const SizedBox(height: 8),
                  Text(
                    'Walk. Earn. Redeem.',
                    style: AppTypography.textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                      letterSpacing: 0.5,
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),
                  const SizedBox(height: 60),

                  // Login Card
                  AppCard(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 32),
                    child: Column(
                      children: [
                        Text(
                          'Welcome Back',
                          style:
                              AppTypography.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sign in to continue your journey',
                          style: AppTypography.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: AppButton(
                            label: 'Sign in with Google',
                            icon: Icons.login,
                            isLoading: authState.status == AuthStatus.loading,
                            onPressed: () {
                              ref
                                  .read(authStateProvider.notifier)
                                  .signInWithGoogle();
                            },
                            type: AppButtonType.primary,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0),

                  const SizedBox(height: 24),
                  Text(
                    'By signing in, you agree to our Terms & Privacy Policy',
                    style: AppTypography.textTheme.bodySmall
                        ?.copyWith(color: Colors.white54),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
