import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import '/core/style/app_theme.dart';
import '/features/auth/pages/login_page.dart';
import '/features/auth/provider/auth_provider.dart';
import '/features/auth/provider/auth_wrapper.dart';
import '/features/cart/cart_provider.dart';
import '/features/myaccount/account_provider.dart';
import '/shared/widgets/main_navigation_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const storage = FlutterSecureStorage();
  await storage.deleteAll(); // Optional: Clear secure storage on app start

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => AccountProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medicare',
      theme: AppTheme.lightTheme(context),
      darkTheme: AppTheme.darkTheme(context),
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
      routes: {
        '/main': (context) => const MainNavigationScaffold(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}
