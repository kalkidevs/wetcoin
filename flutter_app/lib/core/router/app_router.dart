import 'package:flutter/material.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/health_sync/presentation/screens/home_screen.dart';
import '../../features/rewards/presentation/screens/rewards_screen.dart';
import '../../features/wallet/presentation/screens/wallet_screen.dart';
import '../../features/orders/presentation/screens/orders_screen.dart';

class AppRouter {
  static const String login = '/login';
  static const String home = '/home';
  static const String rewards = '/rewards';
  static const String wallet = '/wallet';
  static const String orders = '/orders';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case rewards:
        return MaterialPageRoute(builder: (_) => const RewardsScreen());
      case wallet:
        return MaterialPageRoute(builder: (_) => const WalletScreen());
      case orders:
        return MaterialPageRoute(builder: (_) => const OrdersScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
