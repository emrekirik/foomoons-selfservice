import 'package:altmisdokuzapp/featured/admin/admin_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _menuProvider = StateNotifierProvider<AdminNotifier, HomeState>((ref) {
  return AdminNotifier(ref);
});

class AdminView extends ConsumerStatefulWidget {
  const AdminView({super.key});

  @override
  ConsumerState<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends ConsumerState<AdminView> {
  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(_menuProvider).orders ?? [];
    final newOrders = orders.where((order) => order.status == 'yeni').toList();
    final preparingOrders =
        orders.where((order) => order.status == 'hazırlanıyor').toList();
    final readyOrders =
        orders.where((order) => order.status == 'hazır').toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderColumn(
                  context, 'Yeni Siparişler', newOrders, 'hazırlanıyor'),
              const SizedBox(width: 16),
              _buildOrderColumn(
                  context, 'Hazırlanıyor', preparingOrders, 'hazır'),
              const SizedBox(width: 16),
              _buildOrderColumn(context, 'Hazır', readyOrders, 'teslim edildi'),
            ],
          ),
        ),
      ),
    );
  }

  Expanded _buildOrderColumn(
      BuildContext context, String title, List orders, String nextStatus) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final item = orders[index];
                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 4.0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          item.title ?? '',
                          overflow: TextOverflow.visible,
                        ),
                        Text(
                          item.piece ?? '',
                          overflow: TextOverflow.visible,
                        ),
                        Text(
                          item.preperationTime != null ? '${item.preperationTime} dk' : 'Süre Yok',
                          overflow: TextOverflow.visible,
                        ),
                        Text(
                          item.tableId ?? '',
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.visible,
                        ),
                        Text(
                          item.price != null ? '${item.price} ₺' : 'Fiyat Yok',
                          overflow: TextOverflow.visible,
                        ),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check),
                                onPressed: () {
                                  if (item.id != null) {
                                    ref
                                        .read(_menuProvider.notifier)
                                        .updateOrderStatus(item.id!, nextStatus);
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  if (item.id != null) {
                                    ref
                                        .read(_menuProvider.notifier)
                                        .updateOrderStatus(
                                            item.id!, 'iptal edildi');
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
