import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/config/env_config.dart';
import 'features/auth/presentation/screens/auth_wrapper.dart';

class SweatcoinApp extends ConsumerWidget {
  const SweatcoinApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: EnvConfig.appName,
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(),
      onGenerateRoute: AppRouter.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
