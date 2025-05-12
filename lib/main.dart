import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WooCommerce App',
      theme: ThemeData(primarySwatch: Colors.indigo),
      debugShowCheckedModeBanner: false,
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const Center(child: Text('Home')),
    const Center(child: Text('Category')),
    const Center(child: Text('Cart')),
    const Center(child: Text('Account')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60), // 60px height
        child: Container(
          color: Colors.white, // White background
          child: AppBar(
            backgroundColor: Colors.white, // White background
            elevation: 0,
            title: Row(
              children: [
                Image.asset('assets/img/logo.png', height: 30), // Add logo to assets
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 35,
                    child: TextField(
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                        hintText: 'Search...',
                        filled: true,
                        fillColor: Colors.grey[200],
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white, // White background for bottom navbar
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.indigo,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white, // White background
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: _selectedIndex == 0
                    ? BoxDecoration(
                  color: const Color(0xFFf5f5f5), // #f5f5f5 background
                  borderRadius: BorderRadius.circular(12),
                )
                    : null,
                child: const Icon(Icons.home),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: _selectedIndex == 1
                    ? BoxDecoration(
                  color: const Color(0xFFf5f5f5), // #f5f5f5 background
                  borderRadius: BorderRadius.circular(12),
                )
                    : null,
                child: const Icon(Icons.category),
              ),
              label: 'Category',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: _selectedIndex == 2
                    ? BoxDecoration(
                  color: const Color(0xFFf5f5f5), // #f5f5f5 background
                  borderRadius: BorderRadius.circular(12),
                )
                    : null,
                child: const Icon(Icons.shopping_cart),
              ),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: _selectedIndex == 3
                    ? BoxDecoration(
                  color: const Color(0xFFf5f5f5), // #f5f5f5 background
                  borderRadius: BorderRadius.circular(12),
                )
                    : null,
                child: const Icon(Icons.person),
              ),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }
}