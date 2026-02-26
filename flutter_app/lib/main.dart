import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'features/health_sync/data/datasources/background_service.dart';
import 'app.dart';
import 'core/services/connection_service.dart';
import 'core/utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await BackgroundService.initialize();
  await BackgroundService.registerPeriodicTask();

  // Initialize connection service
  final connectionService = ConnectionService();

  runApp(
    ProviderScope(
      child: SweatcoinApp(
        connectionService: connectionService,
      ),
    ),
  );
}

class SweatcoinApp extends StatelessWidget {
  final ConnectionService connectionService;

  const SweatcoinApp({Key? key, required this.connectionService})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sweatcoin Clone',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: ConnectionCheckWrapper(
        connectionService: connectionService,
      ),
    );
  }
}

class ConnectionCheckWrapper extends StatefulWidget {
  final ConnectionService connectionService;

  const ConnectionCheckWrapper({Key? key, required this.connectionService})
      : super(key: key);

  @override
  State<ConnectionCheckWrapper> createState() => _ConnectionCheckWrapperState();
}

class _ConnectionCheckWrapperState extends State<ConnectionCheckWrapper> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      AppLogger.section('APP_STARTUP');
      AppLogger.info('APP_STARTING', 'Initializing Sweatcoin app...');

      // Show connection status popup
      await widget.connectionService.initializeConnectionCheck(context);

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      AppLogger.error('APP_INIT_ERROR', 'Error during app initialization: $e');
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Initializing app...'),
            ],
          ),
        ),
      );
    }

    // Once initialized, show the main app
    return const App();
  }
}
