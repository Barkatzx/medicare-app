// lib/ui/screens/auth_wrapper.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/features/auth/pages/login_page.dart';
import '/features/auth/provider/auth_provider.dart';
import '/shared/widgets/main_navigation_scaffold.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late final AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    _authProvider = context.read<AuthProvider>();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await _authProvider.checkAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<AuthProvider, bool>(
      selector: (_, provider) => provider.isLoggedIn,
      builder: (context, isLoggedIn, child) {
        if (_authProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return isLoggedIn
            ? const MainNavigationScaffold()
            : const LoginScreen();
      },
    );
  }
}
