import 'package:flutter/material.dart';
import 'package:medicare_app/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../../../routes/app_routes.dart';

class PendingApprovalScreen extends StatelessWidget {
  const PendingApprovalScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.pending_actions,
                size: 100,
                color: Colors.orange.shade700,
              ),
              const SizedBox(height: 32),
              Text(
                'Account Pending Approval',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 32,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      authProvider.pendingApprovalMessage ??
                          'Your account is pending approval from the administrator.',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.orange,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'You will be notified once your account is approved.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () async {
                  // Try to check approval status again
                  await authProvider.initialize();
                  if (authProvider.isLoggedIn && authProvider.isCustomer) {
                    // Use context directly - it's always mounted in StatelessWidget
                    Navigator.pushReplacementNamed(context, AppRoutes.home);
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Check Status'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () async {
                  await authProvider.logout();
                  // Use context directly - it's always mounted in StatelessWidget
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                },
                child: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
