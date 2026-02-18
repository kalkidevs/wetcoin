import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sweatcoin/features/orders/data/repositories/order_repository.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: StreamBuilder(
        stream: ref.read(orderRepositoryProvider).getUserOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final orders = snapshot.data ?? [];
          if (orders.isEmpty) {
            return const Center(child: Text('No orders yet.'));
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final date =
                  (order['createdAt'] as dynamic)?.toDate() ?? DateTime.now();

              return ListTile(
                leading: const Icon(Icons.local_shipping, color: Colors.blue),
                title: Text(order['rewardName'] ?? 'Order'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status: ${order['status'] ?? 'Pending'}'),
                    Text('Ordered on: ${DateFormat.yMMMd().format(date)}'),
                  ],
                ),
                trailing: Text('${order['cost']} Coins'),
              );
            },
          );
        },
      ),
    );
  }
}
