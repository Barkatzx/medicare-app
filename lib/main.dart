import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import '/core/style/app_theme.dart';
import '/features/auth/pages/login_page.dart';
import '/features/auth/provider/auth_provider.dart';
import '/features/auth/provider/auth_wrapper.dart';
import '/features/cart/cart_provider.dart';
import '/features/myaccount/account_provider.dart';
import '/features/orders/order_provider.dart';
import '/shared/widgets/main_navigation_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize secure storage (remove deleteAll in production)
  const storage = FlutterSecureStorage();
  await storage.deleteAll(); // Development only

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => AccountProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: const MediCareApp(),
    ),
  );
}

class MediCareApp extends StatelessWidget {
  const MediCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediCare',
      theme: AppTheme.lightTheme(context),
      darkTheme: AppTheme.darkTheme(context),
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
      routes: {
        '/home': (context) => const MainNavigationScaffold(selectedTab: 0),
        '/login': (context) => const LoginScreen(),
      },
      onUnknownRoute:
          (settings) => MaterialPageRoute(
            builder: (context) => const MainNavigationScaffold(selectedTab: 0),
          ),
    );
  }
}
