import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../presentation/providers/auth_provider.dart';
import '../presentation/screens/auth/pending_approval_screen.dart';
import 'app_routes.dart';

class AuthGuard {
  static Future<bool> checkAuthentication(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Initialize if not done yet
    if (!authProvider.isInitialized) {
      await authProvider.initialize();
    }

    // Check if user is pending approval
    if (authProvider.isPendingApproval) {
      Navigator.pushReplacementNamed(context, '/pending-approval');
      return false;
    }

    // Check if user is logged in and is customer
    if (!authProvider.isLoggedIn || !authProvider.isCustomer) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
      return false;
    }

    return true;
  }

  static Widget protectRoute(Widget child) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (!authProvider.isInitialized) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Verifying account...'),
                ],
              ),
            ),
          );
        }

        // Show pending approval screen
        if (authProvider.isPendingApproval) {
          return const PendingApprovalScreen();
        }

        // Show login screen if not authenticated
        if (!authProvider.isLoggedIn || !authProvider.isCustomer) {
          return const Scaffold(body: Center(child: Text('Access Denied')));
        }

        return child;
      },
    );
  }
}
