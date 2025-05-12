import 'package:flutter/material.dart';

import '/features/cart/cartpage/cart.dart';
import '/features/home/category/category_page.dart';
import '/features/home/presentation/pages/home_page.dart';

class MainNavigationScaffold extends StatefulWidget {
  const MainNavigationScaffold({super.key});

  @override
  State<MainNavigationScaffold> createState() => _MainNavigationScaffoldState();
}

class _MainNavigationScaffoldState extends State<MainNavigationScaffold> {
  int _selectedIndex = 0;

  final FocusNode _searchFocusNode = FocusNode();

  final List<Widget> _screens = const [
    // Replace with your actual page widgets
    HomePage(),
    CategoryPage(),
    CartPage(),
    // AccountPage(),
  ];

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() {}); // Rebuild to update cursor visibility when focus changes
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
                height: 36, // Reduced height here
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
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        items: [
          _buildNavItem(icon: Icons.home, label: 'Home', index: 0),
          _buildNavItem(icon: Icons.category, label: 'Category', index: 1),
          _buildNavItem(icon: Icons.shopping_cart, label: 'Cart', index: 2),
          _buildNavItem(icon: Icons.account_circle, label: 'Account', index: 3),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isSelected = _selectedIndex == index;

    return BottomNavigationBarItem(
      icon:
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
      label: label,
    );
  }
}
