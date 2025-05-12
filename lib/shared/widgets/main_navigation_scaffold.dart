import 'package:flutter/material.dart';
// import 'package:your_app_name/core/constants/asset_constants.dart';
// import 'package:your_app_name/features/home/presentation/pages/home_page.dart';
// import 'package:your_app_name/features/category/presentation/pages/category_page.dart';
// import 'package:your_app_name/features/cart/presentation/pages/cart_page.dart';
// import 'package:your_app_name/features/account/presentation/pages/account_page.dart';

class MainNavigationScaffold extends StatefulWidget {
  const MainNavigationScaffold({super.key});

  @override
  State<MainNavigationScaffold> createState() => _MainNavigationScaffoldState();
}

class _MainNavigationScaffoldState extends State<MainNavigationScaffold> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    // HomePage(),
    // CategoryPage(),
    // CartPage(),
    // AccountPage(),
  ];

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
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      items: [
        _buildNavItem(icon: Icons.home, label: 'Home', index: 0),
        _buildNavItem(icon: Icons.category, label: 'Category', index: 1),
        _buildNavItem(icon: Icons.shopping_cart, label: 'Cart', index: 2),
        _buildNavItem(icon: Icons.account_circle, label: 'Account', index: 3),
      ],
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
                child: Icon(icon),
              )
              : Icon(icon),
      label: label,
    );
  }
}
