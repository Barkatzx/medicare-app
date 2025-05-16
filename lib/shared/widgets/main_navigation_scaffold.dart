import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/features/home/category/category_page.dart';
import '/features/home/presentation/pages/home_page.dart';
import '/features/myaccount/account_page.dart';
import '../../features/cart/cart.dart';
import '../../features/cart/cart_provider.dart';

class MainNavigationScaffold extends StatefulWidget {
  const MainNavigationScaffold({super.key});

  static void navigateToTab(BuildContext context, int index) {
    final state =
        context.findAncestorStateOfType<_MainNavigationScaffoldState>();
    state?._onItemTapped(index);
  }

  @override
  State<MainNavigationScaffold> createState() => _MainNavigationScaffoldState();
}

class _MainNavigationScaffoldState extends State<MainNavigationScaffold> {
  int _selectedIndex = 0;
  final FocusNode _searchFocusNode = FocusNode();
  final List<Widget> _screens = const [
    HomePage(),
    CategoryPage(),
    CartPage(),
    AccountPage(),
  ];

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Image.asset('assets/img/logo.png', height: 40),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 36,
                child: TextField(
                  focusNode: _searchFocusNode,
                  showCursor: _searchFocusNode.hasFocus,
                  autofocus: false,
                  decoration: InputDecoration(
                    hintText: 'Search Medicine...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cart, child) {
          return BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.indigo,
            unselectedItemColor: Colors.grey,
            items: [
              _buildNavItem(icon: Icons.home, label: 'Home', index: 0),
              _buildNavItem(icon: Icons.category, label: 'Category', index: 1),
              _buildNavItem(
                icon: Icons.shopping_cart,
                label: 'Cart',
                index: 2,
                badgeCount: cart.items.length,
              ),
              _buildNavItem(
                icon: Icons.account_circle,
                label: 'Account',
                index: 3,
              ),
            ],
          );
        },
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    int badgeCount = 0,
  }) {
    final bool isSelected = _selectedIndex == index;

    return BottomNavigationBarItem(
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          isSelected
              ? Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(icon, size: 30),
              )
              : Icon(icon, size: 30),
          if (badgeCount > 0 && label == 'Cart')
            Positioned(
              right: -5,
              top: -5,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Text(
                  badgeCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      label: label,
    );
  }
}
