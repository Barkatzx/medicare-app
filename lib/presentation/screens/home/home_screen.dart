import 'package:flutter/material.dart';
import 'package:medicare_app/presentation/providers/product_provider.dart';
import 'package:medicare_app/presentation/screens/cart/cart_screen.dart';
import 'package:medicare_app/presentation/screens/profile/profile_screen.dart';
import 'package:medicare_app/presentation/widgets/home/home_app_bar.dart';
import 'package:medicare_app/presentation/widgets/home/product_card.dart';
import 'package:provider/provider.dart';
import 'trending_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeContentScreen(),
    const TrendingScreen(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up_outlined),
            activeIcon: Icon(Icons.trending_up),
            label: 'Trending',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomeContentScreen extends StatefulWidget {
  const HomeContentScreen({super.key});

  @override
  State<HomeContentScreen> createState() => _HomeContentScreenState();
}

class _HomeContentScreenState extends State<HomeContentScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );
      productProvider.loadProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HomeAppBar(),
      body: Column(
        children: [
          // Search Bar
          Padding(padding: const EdgeInsets.all(16), child: _buildSearchBar()),
          // Products
          // Replace the GridView.builder with ListView.builder
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, productProvider, child) {
                if (productProvider.isLoading &&
                    productProvider.products.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (productProvider.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.black,
                        ),
                        const SizedBox(height: 16),
                        Text(productProvider.errorMessage!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            productProvider.loadProducts();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (productProvider.products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.medical_services_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          productProvider.searchQuery.isEmpty
                              ? 'No products available'
                              : 'No products found for "${productProvider.searchQuery}"',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                }

                // Use ListView.builder for single column (one row per product)
                // In the ListView.builder, update the ProductCard usage
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: productProvider.products.length,
                  itemBuilder: (context, index) {
                    final product = productProvider.products[index];
                    return ProductCard(
                      product: product,
                      onAddToCart: () {
                        // Add to cart logic
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.name} added to cart'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: (value) {
          final productProvider = Provider.of<ProductProvider>(
            context,
            listen: false,
          );
          if (value.isEmpty) {
            productProvider.clearSearch();
          } else {
            productProvider.searchProducts(value);
          }
        },
        decoration: InputDecoration(
          hintText: 'Napa Extra...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    final productProvider = Provider.of<ProductProvider>(
                      context,
                      listen: false,
                    );
                    productProvider.clearSearch();
                    _searchFocusNode.unfocus();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
