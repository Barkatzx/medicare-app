import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '/core/config/api_config.dart';
import '/features/cart/cart_provider.dart';
import '/features/cart/order_success_page.dart';
import '/features/myaccount/account_provider.dart';
import '/features/myaccount/user_model.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _hasAddress = false;
  bool _isPlacingOrder = false;
  late AnimationController _animationController;
  Animation<double>? _fadeAnimation;

  final Map<String, TextEditingController> _controllers = {
    'billing.first_name': TextEditingController(),
    'billing.last_name': TextEditingController(),
    'billing.country': TextEditingController(text: 'Bangladesh'),
    'billing.address_1': TextEditingController(),
    'billing.phone': TextEditingController(),
    'billing.email': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    final accountProvider = Provider.of<AccountProvider>(
      context,
      listen: false,
    );

    if (accountProvider.user == null) {
      await accountProvider.fetchUserData(context);
    }

    if (accountProvider.user?.billingDetails != null) {
      _populateControllersFromBilling(accountProvider.user!.billingDetails!);
      setState(() {
        _hasAddress = _checkHasAddress(accountProvider.user!.billingDetails!);
        _isLoading = false;
      });
      return;
    }

    await _fetchCustomerData();
  }

  Future<void> _fetchCustomerData() async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.customersEndpoint}/me?consumer_key=${ApiConfig.consumerKey}&consumer_secret=${ApiConfig.consumerSecret}',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _hasAddress = _checkHasAddress(data);
            _populateControllers(data);
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
        }
        debugPrint('Failed to fetch customer data: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      debugPrint('Error fetching customer data: $e');
    }
  }

  bool _checkHasAddress(dynamic data) {
    if (data is BillingDetails) {
      return data.address1.isNotEmpty &&
          data.firstName.isNotEmpty &&
          data.phone.isNotEmpty;
    } else if (data is Map<String, dynamic>) {
      final billing = data['billing'] ?? {};
      return billing['address_1']?.toString().isNotEmpty == true &&
          billing['first_name']?.toString().isNotEmpty == true &&
          billing['phone']?.toString().isNotEmpty == true;
    }
    return false;
  }

  void _populateControllersFromBilling(BillingDetails billing) {
    _controllers['billing.first_name']!.text = billing.firstName;
    _controllers['billing.last_name']!.text = billing.lastName;
    _controllers['billing.country']!.text = billing.country;
    _controllers['billing.address_1']!.text = billing.address1;
    _controllers['billing.phone']!.text = billing.phone;
    _controllers['billing.email']!.text = billing.email;
  }

  void _populateControllers(Map<String, dynamic> data) {
    final billing = data['billing'] ?? {};

    for (var key in _controllers.keys) {
      final field = key.replaceFirst('billing.', '');
      if (billing[field] != null && billing[field].toString().isNotEmpty) {
        _controllers[key]!.text = billing[field].toString();
      } else if (data[field] != null && data[field].toString().isNotEmpty) {
        _controllers[key]!.text = data[field].toString();
      }
    }
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isPlacingOrder = true);

    final cart = Provider.of<CartProvider>(context, listen: false);
    final accountProvider = Provider.of<AccountProvider>(
      context,
      listen: false,
    );

    final lineItems =
        cart.items.values
            .map(
              (item) => {
                'product_id': int.parse(item.id),
                'quantity': item.quantity,
              },
            )
            .toList();

    final billingData = {
      'first_name': _controllers['billing.first_name']!.text,
      'last_name': _controllers['billing.last_name']!.text,
      'country': _controllers['billing.country']!.text,
      'address_1': _controllers['billing.address_1']!.text,
      'phone': _controllers['billing.phone']!.text,
      'email': _controllers['billing.email']!.text,
    };

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.ordersEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Basic ${base64Encode(utf8.encode('${ApiConfig.consumerKey}:${ApiConfig.consumerSecret}'))}',
        },
        body: json.encode({
          'payment_method': 'cod',
          'payment_method_title': 'Cash on Delivery',
          'status': 'pending',
          'line_items': lineItems,
          'billing': billingData,
        }),
      );

      if (response.statusCode == 201) {
        await accountProvider.updateUserProfile(
          context,
          firstName: _controllers['billing.first_name']!.text,
          lastName: _controllers['billing.last_name']!.text,
          phone: _controllers['billing.phone']!.text,
          country: _controllers['billing.country']!.text,
          address1: _controllers['billing.address_1']!.text,
        );

        final order = json.decode(response.body);
        cart.clearCart();

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (_) => OrderSuccessPage(
                    orderId: order['id'],
                    orderNumber: order['number'],
                  ),
            ),
          );
        }
      } else {
        throw Exception('Order failed: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPlacingOrder = false);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Checkout'),
        centerTitle: false,
        elevation: 0,
        backgroundColor: const Color(0xFFF5F5F5),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _fadeAnimation == null
              ? const SizedBox()
              : FadeTransition(
                opacity: _fadeAnimation!,
                child: Column(
                  children: [
                    Expanded(
                      child: CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    _buildBillingSection(),
                                    const SizedBox(height: 16),
                                    _buildOrderSummary(cart),
                                    const SizedBox(height: 10),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildCheckoutFooter(cart, theme),
                  ],
                ),
              ),
    );
  }

  Widget _buildBillingSection() {
    final accountProvider = Provider.of<AccountProvider>(context);
    final hasSavedAddress =
        accountProvider.user?.billingDetails != null &&
        _checkHasAddress(accountProvider.user!.billingDetails!);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey<bool>(_hasAddress),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on_outlined, color: Colors.indigo),
                const SizedBox(width: 5),
                Text(
                  'Delivery Address',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (hasSavedAddress && _hasAddress) ...[
              _buildAddressPreview(),
              const SizedBox(height: 1),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => setState(() => _hasAddress = false),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Change Address'),
                ),
              ),
            ] else ...[
              _buildTextField(
                label: 'Pharmacy Name*',
                controller: _controllers['billing.first_name']!,
                hint: 'Your Pharmacy Name',
                icon: Icons.store_outlined,
                validator:
                    (value) => value?.isEmpty ?? true ? 'Required field' : null,
              ),
              _buildTextField(
                label: 'Full Name',
                controller: _controllers['billing.last_name']!,
                hint: 'Your Full Name',
                icon: Icons.person_outline,
              ),
              _buildTextField(
                label: 'Country*',
                controller: _controllers['billing.country']!,
                readOnly: true,
                icon: Icons.flag_outlined,
                validator:
                    (value) => value?.isEmpty ?? true ? 'Required field' : null,
              ),
              _buildTextField(
                label: 'Address*',
                controller: _controllers['billing.address_1']!,
                hint: 'Your Complete Address',
                icon: Icons.home_outlined,
                validator:
                    (value) => value?.isEmpty ?? true ? 'Required field' : null,
              ),
              _buildTextField(
                label: 'Phone*',
                controller: _controllers['billing.phone']!,
                hint: '01XXXXXXXXX',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Required field';
                  if (!RegExp(r'^01\d{9}$').hasMatch(value!)) {
                    return 'Invalid BD phone number';
                  }
                  return null;
                },
              ),
              _buildTextField(
                label: 'Email',
                controller: _controllers['billing.email']!,
                hint: 'your@email.com',
                readOnly: true,
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value?.isNotEmpty ?? false) {
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value!)) {
                      return 'Invalid email';
                    }
                  }
                  return null;
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAddressPreview() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: Colors.indigo.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.indigo),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_controllers['billing.first_name']!.text.isNotEmpty ||
              _controllers['billing.last_name']!.text.isNotEmpty)
            Row(
              children: [
                Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  '${_controllers['billing.first_name']!.text} ${_controllers['billing.last_name']!.text}'
                      .trim(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          if (_controllers['billing.address_1']!.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.home_outlined, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(child: Text(_controllers['billing.address_1']!.text)),
              ],
            ),
          ],
          if (_controllers['billing.country']!.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.flag_outlined, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(_controllers['billing.country']!.text),
              ],
            ),
          ],
          if (_controllers['billing.phone']!.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone_outlined, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(_controllers['billing.phone']!.text),
              ],
            ),
          ],
          if (_controllers['billing.email']!.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.email_outlined, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(_controllers['billing.email']!.text),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderSummary(CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shopping_bag_outlined, color: Colors.indigo),
              const SizedBox(width: 8),
              Text(
                'Order Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...cart.items.values.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[100],
                      image:
                          item.imageUrl.isNotEmpty
                              ? DecorationImage(
                                image: NetworkImage(item.imageUrl),
                                fit: BoxFit.cover,
                                onError: (_, __) {},
                              )
                              : null,
                    ),
                    child:
                        item.imageUrl.isEmpty
                            ? Center(
                              child: Icon(
                                Icons.medication_outlined,
                                color: Colors.grey[400],
                                size: 30,
                              ),
                            )
                            : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '৳${item.price.toStringAsFixed(2)} × ${item.quantity}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '৳${(item.price * item.quantity).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.indigo,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutFooter(CartProvider cart, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                'Subtotal:',
                style: TextStyle(fontSize: 15, color: Colors.grey[600]),
              ),
              const Spacer(),
              Text(
                '৳${cart.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Delivery:',
                style: TextStyle(fontSize: 15, color: Colors.grey[600]),
              ),
              const Spacer(),
              const Text('Free', style: TextStyle(fontSize: 15)),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text('Total:', style: TextStyle(fontSize: 15)),
              const Spacer(),
              Text(
                '৳${cart.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _isPlacingOrder ? null : _placeOrder,
              child:
                  _isPlacingOrder
                      ? const SizedBox(
                        width: 20,
                        height: 10,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : const Text(
                        'Confirm Order',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: Colors.white,
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 1),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            readOnly: readOnly,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, size: 20),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            validator: validator,
          ),
        ],
      ),
    );
  }
}
