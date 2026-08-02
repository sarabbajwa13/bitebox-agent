import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/app_config.dart';
import 'config/app_theme.dart';
import 'data/repositories/agent_repository.dart';
import 'data/repositories/firebase_agent_repository.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/orders_provider.dart';
import 'providers/products_provider.dart';
import 'providers/settings_provider.dart';
import 'services/notification_service.dart';
import 'ui/screens/home_shell.dart';
import 'ui/screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.instance.init();
  runApp(const BiteBoxAgentApp());
}

class BiteBoxAgentApp extends StatelessWidget {
  const BiteBoxAgentApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AgentRepository repository = FirebaseAgentRepository();

    return MultiProvider(
      providers: [
        Provider<AgentRepository>.value(value: repository),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (_) => OrdersProvider(repository: repository),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductsProvider(repository: repository),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(repository: repository),
        ),
      ],
      child: MaterialApp(
        title: AppConfig.businessName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const _AuthGate(),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final loggedIn = context.watch<AuthProvider>().isLoggedIn;
    return loggedIn ? const HomeShell() : const LoginScreen();
  }
}
