import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_state_provider.dart';
import '../../presentation/screens/login_screen.dart';
import '../../../health_sync/presentation/screens/home_screen.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    switch (authState.status) {
      case AuthStatus.authenticated:
        return const HomeScreen();
      case AuthStatus.unauthenticated:
        return const LoginScreen();
      case AuthStatus.loading:
      case AuthStatus.initial:
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
    }
  }
}
