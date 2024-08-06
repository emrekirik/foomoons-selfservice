import 'package:altmisdokuzapp/featured/admin/admin_notifier.dart';
import 'package:altmisdokuzapp/product/constants/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _adminProvider = StateNotifierProvider<AdminNotifier, HomeState>((ref) {
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
    final orders = ref.watch(_adminProvider).orders ?? [];
    final newOrders = orders.where((order) => order.status == 'yeni').toList();
    final preparingOrders =
        orders.where((order) => order.status == 'hazırlanıyor').toList();
    final readyOrders =
        orders.where((order) => order.status == 'hazır').toList();

    return Center(
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
            _buildOrderColumn(
                context, 'Geçmiş Siparişler', readyOrders, 'teslim edildi'),
          ],
        ),
      ),
    );
  }

  Expanded _buildOrderColumn(
      BuildContext context, String title, List orders, String nextStatus) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Divider(
                indent: 100,
                endIndent: 100,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final item = orders[index];
                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 25),
                      elevation: 4.0,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final isLargeScreen = constraints.maxWidth > 200;
                            return Wrap(
                              direction: isLargeScreen
                                  ? Axis.horizontal
                                  : Axis.vertical,
                              spacing: 8.0,
                              runSpacing: 4.0,
                              children: [
                                _buildOrderDetail(item.title ?? ''),
                                _buildOrderDetail(item.piece ?? ''),
                                _buildOrderDetail(item.preperationTime != null
                                    ? '${item.preperationTime} dk'
                                    : 'Süre Yok'),
                                _buildOrderDetail(item.tableId ?? ''),
                                _buildOrderDetail(item.price != null
                                    ? '${item.price} ₺'
                                    : 'Fiyat Yok'),
                                Center(
                                  child:
                                      _buildActionButtons(item, nextStatus),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderDetail(String detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Text(
        detail,
        overflow: TextOverflow.visible,
      ),
    );
  }

  Widget _buildActionButtons(item, String nextStatus) {
    return Wrap(
      spacing: 8.0,
      children: [
        IconButton(
          icon: const Icon(
            Icons.check,
            size: 17,
          ),
          onPressed: () {
            if (item.id != null) {
              ref
                  .read(_adminProvider.notifier)
                  .updateOrderStatus(item.id!, nextStatus);
            }
          },
        ),
        IconButton(
          icon: const Icon(
            Icons.close,
            size: 17,
          ),
          onPressed: () {
            if (item.id != null) {
              ref
                  .read(_adminProvider.notifier)
                  .updateOrderStatus(item.id!, 'iptal edildi');
            }
          },
        ),
      ],
    );
  }
}
