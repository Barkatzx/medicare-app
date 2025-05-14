import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '/core/config/api_config.dart';
import '/features/cart/cart_provider.dart';
import '/features/cart/order_success_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _hasAddress = false;
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
    _fetchCustomerData();
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
        setState(() {
          _hasAddress = _checkHasAddress(data);
          _populateControllers(data);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error fetching customer data: $e');
    }
  }

  bool _checkHasAddress(Map<String, dynamic> data) {
    final billing = data['billing'] ?? data;
    return (billing['address_1'] != null &&
            billing['address_1'].toString().isNotEmpty) ||
        (data['billing_address_1'] != null &&
            data['billing_address_1'].toString().isNotEmpty);
  }

  void _populateControllers(Map<String, dynamic> data) {
    final billing = data['billing'] ?? data;

    for (var key in _controllers.keys) {
      final field = key.replaceFirst('billing.', '');
      if (billing[field] != null) {
        _controllers[key]!.text = billing[field].toString();
      } else if (data[key] != null) {
        _controllers[key]!.text = data[key].toString();
      }
    }
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final cart = Provider.of<CartProvider>(context, listen: false);
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

    final orderData = {
      'payment_method': 'cod',
      'payment_method_title': 'Cash on Delivery',
      'status': 'pending',
      'line_items': lineItems,
      'billing': billingData,
    };

    try {
      final response = await http.post(
        Uri.parse(
          '${ApiConfig.ordersEndpoint}?consumer_key=${ApiConfig.consumerKey}&consumer_secret=${ApiConfig.consumerSecret}',
        ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(orderData),
      );

      if (response.statusCode == 201) {
        final order = json.decode(response.body);
        final orderId = order['id'];
        final orderNumber = order['number'];
        cart.clearCart();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (_) => OrderSuccessPage(
                  orderId: orderId,
                  orderNumber: orderNumber,
                ),
          ),
        );
      } else {
        throw Exception('Failed to place order: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error placing order: $e')));
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

    return Scaffold(
      backgroundColor: const Color(0xFFf5f5f5),
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: const Color(0xFFf5f5f5),
        elevation: 0,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildBody(cart),
    );
  }

  Widget _buildBody(CartProvider cart) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Billing Section
                  _buildBillingSection(),
                  const SizedBox(height: 16),
                  // Order Summary
                  _buildOrderSummary(cart),
                ],
              ),
            ),
          ),
        ),
        // Footer with totals and button
        _buildCheckoutFooter(cart),
      ],
    );
  }

  Widget _buildBillingSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Billing Details',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 12),
          if (_hasAddress) ...[
            _buildAddressPreview(),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => setState(() => _hasAddress = false),
              child: const Text(
                'Change Address',
                style: TextStyle(color: Colors.indigo),
              ),
            ),
          ] else ...[
            _buildTextField(
              label: 'Pharmacy Name',
              controller: _controllers['billing.first_name']!,
              hint: 'Your Pharmacy Name',
              isRequired: true,
            ),
            _buildTextField(
              label: 'Full Name',
              controller: _controllers['billing.last_name']!,
              hint: 'Your Full Name',
            ),
            _buildTextField(
              label: 'Country',
              controller: _controllers['billing.country']!,
              isRequired: true,
              readOnly: true,
            ),
            _buildTextField(
              label: 'Address',
              controller: _controllers['billing.address_1']!,
              hint: 'Your Address',
              isRequired: true,
            ),
            _buildTextField(
              label: 'Phone',
              controller: _controllers['billing.phone']!,
              hint: 'Your Phone Number',
              keyboardType: TextInputType.phone,
              isRequired: true,
            ),
            _buildTextField(
              label: 'Email',
              controller: _controllers['billing.email']!,
              hint: 'Your Email Address',
              keyboardType: TextInputType.emailAddress,
            ),
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

  Widget _buildCheckoutFooter(CartProvider cart) {
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
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const Spacer(),
              Text(
                '৳${cart.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Text(
                'Delivery:',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              Spacer(),
              Text(
                '৳0.00',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              const Text(
                'Total:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                '৳${cart.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
              onPressed: _placeOrder,
              child: const Text(
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

  Widget _buildAddressPreview() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFf5f5f5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_controllers['billing.first_name']!.text} ${_controllers['billing.last_name']!.text}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(_controllers['billing.address_1']!.text),
          const SizedBox(height: 4),
          Text(_controllers['billing.country']!.text),
          const SizedBox(height: 4),
          Text('Phone: ${_controllers['billing.phone']!.text}'),
          if (_controllers['billing.email']!.text.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('Email: ${_controllers['billing.email']!.text}'),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    bool isRequired = false,
    bool readOnly = false,
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
            validator:
                (value) =>
                    isRequired && (value == null || value.isEmpty)
                        ? 'This field is required'
                        : null,
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
