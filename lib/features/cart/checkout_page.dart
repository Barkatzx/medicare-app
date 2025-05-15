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

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _hasAddress = false;
  bool _isPlacingOrder = false;

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeData());
  }

  Future<void> _initializeData() async {
    final accountProvider = Provider.of<AccountProvider>(
      context,
      listen: false,
    );

    // Fetch user data if not already loaded
    if (accountProvider.user == null) {
      await accountProvider.fetchUserData(context);
    }

    // Populate form with existing billing details
    if (accountProvider.user?.billingDetails != null) {
      _populateControllersFromBilling(accountProvider.user!.billingDetails!);
      setState(() {
        _hasAddress = _checkHasAddress(accountProvider.user!.billingDetails!);
        _isLoading = false;
      });
      return;
    }

    // Fallback to API fetch if no billing details in AccountProvider
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
        // Update user's billing details
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() => _isPlacingOrder = false);
      }
    }
  }

  @override
  void dispose() {
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
      backgroundColor: const Color(0xFFf5f5f5),
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFf5f5f5),
        elevation: 0,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildBillingSection(),
                            const SizedBox(height: 16),
                            _buildOrderSummary(cart),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _buildCheckoutFooter(cart, theme),
                ],
              ),
    );
  }

  Widget _buildBillingSection() {
    final accountProvider = Provider.of<AccountProvider>(context);
    final hasSavedAddress =
        accountProvider.user?.billingDetails != null &&
        _checkHasAddress(accountProvider.user!.billingDetails!);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Billing Details',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 20),
          if (hasSavedAddress && _hasAddress) ...[
            _buildAddressPreview(),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => setState(() => _hasAddress = false),
              child: const Text(
                'Change Address',
                style: TextStyle(color: Colors.indigo),
              ),
            ),
          ] else ...[
            _buildTextField(
              label: 'Pharmacy Name*',
              controller: _controllers['billing.first_name']!,
              hint: 'Your Pharmacy Name',
              validator:
                  (value) => value?.isEmpty ?? true ? 'Required field' : null,
            ),
            _buildTextField(
              label: 'Full Name',
              controller: _controllers['billing.last_name']!,
              hint: 'Your Full Name',
            ),
            _buildTextField(
              label: 'Country*',
              controller: _controllers['billing.country']!,
              readOnly: true,
              validator:
                  (value) => value?.isEmpty ?? true ? 'Required field' : null,
            ),
            _buildTextField(
              label: 'Address*',
              controller: _controllers['billing.address_1']!,
              hint: 'Your Complete Address',
              validator:
                  (value) => value?.isEmpty ?? true ? 'Required field' : null,
            ),
            _buildTextField(
              label: 'Phone*',
              controller: _controllers['billing.phone']!,
              hint: '01XXXXXXXXX',
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
    );
  }

  Widget _buildAddressPreview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFf5f5f5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_controllers['billing.first_name']!.text.isNotEmpty ||
              _controllers['billing.last_name']!.text.isNotEmpty)
            Text(
              '${_controllers['billing.first_name']!.text} ${_controllers['billing.last_name']!.text}'
                  .trim(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          if (_controllers['billing.address_1']!.text.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(_controllers['billing.address_1']!.text),
          ],
          if (_controllers['billing.country']!.text.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(_controllers['billing.country']!.text),
          ],
          if (_controllers['billing.phone']!.text.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('Phone: ${_controllers['billing.phone']!.text}'),
          ],
          if (_controllers['billing.email']!.text.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('Email: ${_controllers['billing.email']!.text}'),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderSummary(CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 12),
          ...cart.items.values.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: const Color(0xFFf5f5f5),
                    ),
                    child:
                        item.imageUrl.isNotEmpty
                            ? Image.network(
                              item.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                            )
                            : Center(
                              child: Icon(Icons.image, color: Colors.grey[400]),
                            ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '৳${item.price.toStringAsFixed(2)} × ${item.quantity}',
                          style: const TextStyle(
                            color: Colors.grey,
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
                      fontSize: 16,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Subtotal:',
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
              const Spacer(),
              Text(
                '৳${cart.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Text(
                'Delivery:',
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
              Spacer(),
              Text('Free', style: TextStyle(fontSize: 15)),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              const Text(
                'Total:',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                '৳${cart.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: _isPlacingOrder ? null : _placeOrder,
              child:
                  _isPlacingOrder
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                        'Place Order',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            readOnly: readOnly,
            decoration: InputDecoration(
              hintText: hint,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.grey),
              ),
            ),
            validator: validator,
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}
