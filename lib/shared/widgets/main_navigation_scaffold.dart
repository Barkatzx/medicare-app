import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/features/cart/cart.dart';
import '/features/cart/cart_provider.dart';
import '/features/home/category/category_page.dart';
import '/features/home/presentation/pages/home_page.dart';
import '/features/myaccount/account_page.dart';

class MainNavigationScaffold extends StatefulWidget {
  final int selectedTab; // Changed from initialPage to selectedTab

  const MainNavigationScaffold({super.key, this.selectedTab = 0});

  @override
  State<MainNavigationScaffold> createState() => _MainNavigationScaffoldState();
}

class _MainNavigationScaffoldState extends State<MainNavigationScaffold> {
  late int _selectedIndex;
  final FocusNode _searchFocusNode = FocusNode();
  final PageStorageBucket _bucket = PageStorageBucket();

  final List<Widget> _screens = [
    const HomePage(key: PageStorageKey('home')),
    const CategoryPage(key: PageStorageKey('category')),
    const CartPage(key: PageStorageKey('cart')),
    const AccountPage(key: PageStorageKey('account')),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedTab; // Initialize with the passed value
    _searchFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _searchFocusNode.removeListener(_onFocusChange);
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
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
            Expanded(child: _buildSearchField()),
          ],
        ),
        centerTitle: false,
      ),
      body: PageStorage(
        bucket: _bucket,
        child: IndexedStack(index: _selectedIndex, children: _screens),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildSearchField() {
    return SizedBox(
      height: 35,
      child: TextField(
        focusNode: _searchFocusNode,
        showCursor: _searchFocusNode.hasFocus,
        decoration: InputDecoration(
          hintText: 'Search Medicine...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCustomNavItem(icon: Icons.home, label: 'Home', index: 0),
              _buildCustomNavItem(
                icon: Icons.category,
                label: 'Category',
                index: 1,
              ),
              _buildCustomNavItem(
                icon: Icons.shopping_bag,
                label: 'Cart',
                index: 2,
                badgeCount: cart.items.length,
              ),
              _buildCustomNavItem(
                icon: Icons.account_circle,
                label: 'Account',
                index: 3,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCustomNavItem({
    required IconData icon,
    required String label,
    required int index,
    int badgeCount = 0,
  }) {
    final bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF5F5F5) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 30,
                  color: isSelected ? Colors.indigo : Colors.grey,
                ),
                if (badgeCount > 0 && label == 'Cart')
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        badgeCount > 9 ? '9+' : '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? Colors.indigo : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
