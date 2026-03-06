import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/router/app_router.dart';
import 'core/services/connection_service.dart';
import 'core/utils/logger.dart';
import 'features/auth/presentation/screens/auth_wrapper.dart';
import 'shared/widgets/app_loading_animation.dart';

class App extends ConsumerStatefulWidget {
  final ConnectionService connectionService;

  const App({super.key, required this.connectionService});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Delay initialization to after the first frame so we have a valid context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    try {
      AppLogger.section('APP_STARTUP');
      AppLogger.info('APP_STARTING', 'Initializing Sweatcoin app...');

      // Show connection status popup
      await widget.connectionService.initializeConnectionCheck(context);

      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      AppLogger.error('APP_INIT_ERROR', 'Error during app initialization: $e');
      if (mounted) {
        setState(() => _isInitialized = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Sweatcoin',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: _isInitialized
          ? const AuthWrapper()
          : const Scaffold(
              body: Center(
                child: AppLoadingAnimation(),
              ),
            ),
      onGenerateRoute: AppRouter.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}