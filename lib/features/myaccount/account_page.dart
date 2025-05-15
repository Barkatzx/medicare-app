// lib/features/account/account_page.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/features/auth/provider/auth_provider.dart';
import '/features/myaccount/account_provider.dart';
import '/features/myaccount/user_model.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final accountProvider = context.read<AccountProvider>();

      if (authProvider.isLoggedIn) {
        accountProvider.fetchUserData(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();
    final accountProvider = context.watch<AccountProvider>();

    if (!authProvider.isLoggedIn) {
      return _buildLoginPrompt(context, theme);
    }

    if (accountProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (accountProvider.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            accountProvider.error!,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final user = accountProvider.user;
    if (user == null) {
      return _buildNoDataView(context, theme);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showUpdateDialog(context, accountProvider, user),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildProfileHeader(context, user, theme),
            const SizedBox(height: 24),
            _buildAccountDetailsCard(user, theme),
            if (user.billingDetails != null) ...[
              const SizedBox(height: 24),
              _buildBillingDetailsCard(user.billingDetails!, theme),
            ],
            const SizedBox(height: 24),
            _buildActionButtons(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginPrompt(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_circle, size: 80, color: theme.disabledColor),
          const SizedBox(height: 16),
          Text(
            'Please login to view your account',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Navigate to login screen
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataView(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: theme.disabledColor),
          const SizedBox(height: 16),
          Text('No user data available', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('Try refreshing your profile', style: theme.textTheme.bodyLarge),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
              final accountProvider = context.read<AccountProvider>();
              accountProvider.fetchUserData(context);
            },
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    UserModel user,
    ThemeData theme,
  ) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
          child:
              user.avatarUrl != null
                  ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: user.avatarUrl!,
                      width: 96,
                      height: 96,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) => const CircularProgressIndicator(),
                      errorWidget:
                          (context, url, error) => const Icon(Icons.person),
                    ),
                  )
                  : Icon(
                    Icons.person,
                    size: 50,
                    color: theme.colorScheme.primary,
                  ),
        ),
        const SizedBox(height: 16),
        Text(
          user.name,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (user.email.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            user.email,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAccountDetailsCard(UserModel user, ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDetailRow(
              icon: Icons.phone,
              label: 'Phone',
              value: user.phone ?? 'Not provided',
              theme: theme,
            ),
            const Divider(height: 24),
            _buildDetailRow(
              icon: Icons.email,
              label: 'Email',
              value: user.email,
              theme: theme,
            ),
            const Divider(height: 24),
            _buildDetailRow(
              icon: Icons.location_on,
              label: 'Address',
              value: user.billingDetails?.address1 ?? 'Not provided',
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24, color: theme.colorScheme.primary),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(value, style: theme.textTheme.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        _buildListTileButton(
          context,
          icon: Icons.shopping_bag,
          title: 'My Orders',
          onTap: () {},
          theme: theme,
        ),
        _buildListTileButton(
          context,
          icon: Icons.settings,
          title: 'Settings',
          onTap: () {},
          theme: theme,
        ),
        _buildListTileButton(
          context,
          icon: Icons.help_center,
          title: 'Help & Support',
          onTap: () {},
          theme: theme,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              final authProvider = context.read<AuthProvider>();
              authProvider.logout();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
              side: BorderSide(color: theme.colorScheme.error),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Logout'),
          ),
        ),
      ],
    );
  }

  //Billing Details
  Widget _buildBillingDetailsCard(BillingDetails billing, ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Billing Address', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            _buildDetailRow(
              icon: Icons.person,
              label: 'Name',
              value: '${billing.firstName} ${billing.lastName}',
              theme: theme,
            ),
            const Divider(height: 24),
            _buildDetailRow(
              icon: Icons.location_on,
              label: 'Address',
              value: billing.address1,
              theme: theme,
            ),
            const Divider(height: 24),
            _buildDetailRow(
              icon: Icons.flag,
              label: 'Country',
              value: billing.country,
              theme: theme,
            ),
            const Divider(height: 24),
            _buildDetailRow(
              icon: Icons.phone,
              label: 'Phone',
              value: billing.phone,
              theme: theme,
            ),
            const Divider(height: 24),
            _buildDetailRow(
              icon: Icons.email,
              label: 'Email',
              value: billing.email,
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTileButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(title),
        trailing: Icon(
          Icons.chevron_right,
          color: theme.colorScheme.onSurface.withOpacity(0.5),
        ),
        onTap: onTap,
      ),
    );
  }

  void _showUpdateDialog(
    BuildContext context,
    AccountProvider accountProvider,
    UserModel user,
  ) {
    final theme = Theme.of(context);
    final nameController = TextEditingController(text: user.name);
    final phoneController = TextEditingController(text: user.phone ?? '');

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Edit Profile', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        onPressed: () async {
                          await accountProvider.updateUserProfile(
                            context,
                            name: nameController.text,
                            phone: phoneController.text,
                          );
                          if (mounted) Navigator.pop(context);
                        },
                        child: const Text('Save Changes'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
