import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/core/style/app_theme.dart';
import '/features/cart/cart_provider.dart';
import 'shared/widgets/main_navigation_scaffold.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => CartProvider())],
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
      home: const MainNavigationScaffold(),
    );
  }
}
