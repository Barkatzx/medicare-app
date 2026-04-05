import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;

    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, ${user?.name ?? "Guest"}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const Text(
            'Welcome to Shop',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: Colors.grey,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            Navigator.pushNamed(context, '/notifications');
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
