// lib/features/orders/orders_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '/features/orders/order_model.dart';
import '/features/orders/order_provider.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  Future<void> _loadOrders() async {
    try {
      await Provider.of<OrderProvider>(
        context,
        listen: false,
      ).fetchOrders(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to refresh orders: ${e.toString()}')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Delay the fetch to after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              scaffoldMessenger.showSnackBar(
                const SnackBar(
                  content: Text('Refreshing Your Orders...'),
                  duration: Duration(seconds: 1),
                ),
              );
              await _loadOrders();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadOrders,
        child: _buildBody(orderProvider, theme),
      ),
    );
  }

  Widget _buildBody(OrderProvider orderProvider, ThemeData theme) {
    if (orderProvider.isLoading && orderProvider.orders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (orderProvider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              orderProvider.error!,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await _loadOrders();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (orderProvider.orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: theme.disabledColor),
            const SizedBox(height: 16),
            Text('No orders found', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'You haven\'t placed any orders yet',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orderProvider.orders.length,
      itemBuilder: (context, index) {
        final order = orderProvider.orders[index];
        return _buildOrderCard(order, theme, context);
      },
    );
  }

  Widget _buildOrderCard(Order order, ThemeData theme, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showOrderDetails(context, order),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.number}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Chip(
                    label: Text(
                      order.status.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: _getStatusColor(order.status),
                  ),
                ],
              ),
              const SizedBox(height: 1),
              Text(
                DateFormat('MMM dd, yyyy - hh:mm a').format(order.dateCreated),
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 1),
              ...order.items
                  .take(2)
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 1),
                      child: Row(
                        children: [
                          if (item.imageUrl != null)
                            Container(
                              width: 40,
                              height: 40,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  image: NetworkImage(item.imageUrl!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          Expanded(
                            child: Text(
                              '${item.name} × ${item.quantity}',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                          Text(item.total),
                        ],
                      ),
                    ),
                  ),
              if (order.items.length > 2)
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    '+ ${order.items.length - 2} more items',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              const Divider(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total', style: theme.textTheme.bodyMedium),
                  Text(order.total),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'processing':
        return Colors.blue;
      case 'on-hold':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'refunded':
        return Colors.purple;
      default:
        return Colors.pink;
    }
  }

  void _showOrderDetails(BuildContext context, Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => DraggableScrollableSheet(
            expand: false,
            maxChildSize: 0.9,
            initialChildSize: 0.7,
            builder:
                (_, controller) => OrderDetailsSheet(
                  order: order,
                  scrollController: controller,
                ),
          ),
    );
  }
}

class OrderDetailsSheet extends StatelessWidget {
  final Order order;
  final ScrollController scrollController;

  const OrderDetailsSheet({
    super.key,
    required this.order,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      controller: scrollController,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Text(
              'Order #${order.number}',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Text(
                  DateFormat(
                    'MMM dd, yyyy - hh:mm a',
                  ).format(order.dateCreated),
                  style: theme.textTheme.bodySmall,
                ),
                const Spacer(),
                Chip(
                  label: Text(
                    order.status.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: _getStatusColor(order.status),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              'Items (${order.items.length})',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.imageUrl != null)
                      Container(
                        width: 60,
                        height: 60,
                        margin: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(item.imageUrl!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name, style: theme.textTheme.bodyMedium),
                          const SizedBox(height: 4),
                          Text(
                            '${item.price} × ${item.quantity}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      item.total,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtotal', style: theme.textTheme.bodyMedium),
                Text(order.total, style: theme.textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Shipping', style: theme.textTheme.bodyMedium),
                Text('Free', style: theme.textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Payment Method', style: theme.textTheme.bodyMedium),
                Text(order.paymentMethod, style: theme.textTheme.bodyMedium),
              ],
            ),
            const Divider(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  order.total,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (order.billing != null) ...[
              Text(
                'Billing Address',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${order.billing!.firstName} ${order.billing!.lastName}',
                style: theme.textTheme.bodyMedium,
              ),
              if (order.billing!.address1.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  order.billing!.address1,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
              if (order.billing!.phone.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(order.billing!.phone, style: theme.textTheme.bodyMedium),
              ],
              if (order.billing!.email.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(order.billing!.email, style: theme.textTheme.bodyMedium),
              ],
              const SizedBox(height: 10),
            ],
            if (order.shipping != null) ...[
              Text(
                'Shipping Address',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${order.shipping!.firstName} ${order.shipping!.lastName}',
                style: theme.textTheme.bodyMedium,
              ),
              if (order.shipping!.address1.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  order.shipping!.address1,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
              if (order.shipping!.city.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  '${order.shipping!.city}, ${order.shipping!.state} ${order.shipping!.postcode}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
              if (order.shipping!.country.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  order.shipping!.country,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ],
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'processing':
        return Colors.blue;
      case 'on-hold':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'refunded':
        return Colors.purple;
      default:
        return Colors.pink;
    }
  }
}
