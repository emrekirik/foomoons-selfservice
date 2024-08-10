import 'package:altmisdokuzapp/featured/admin/admin_notifier.dart' as admin;
import 'package:altmisdokuzapp/featured/menu/menu_notifier.dart' as menu;
import 'package:altmisdokuzapp/product/model/menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _adminProvider =
    StateNotifierProvider<admin.AdminNotifier, admin.HomeState>((ref) {
  return admin.AdminNotifier(ref);
});

final _menuProvider = StateNotifierProvider<menu.MenuNotifier, menu.MenuState>(
    (ref) => menu.MenuNotifier());

class AdminView extends ConsumerStatefulWidget {
  const AdminView({super.key});

  @override
  ConsumerState<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends ConsumerState<AdminView> {
  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(_adminProvider).orders ?? [];
    final menus = ref.watch(_menuProvider).orders ?? [];
    final newOrders = orders.where((order) => order.status == 'yeni').toList();
    final preparingOrders =
        orders.where((order) => order.status == 'hazırlanıyor').toList();
    // final readyOrders =
    //     orders.where((order) => order.status == 'hazır').toList();
    final pastOrders =
        orders.where((order) => order.status == 'teslim edildi').toList();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderColumn(context, 'Yeni Siparişler', newOrders,
                'hazırlanıyor', menus, 'yeni'),
            const SizedBox(width: 16),
            _buildOrderColumn(context, 'Hazırlanıyor', preparingOrders,
                'teslim edildi', menus, 'hazırlanıyor'),
            const SizedBox(width: 16),
            _buildOrderColumn(context, 'Geçmiş Siparişler', pastOrders,
                'teslim edildi', menus, 'hazır'),
          ],
        ),
      ),
    );
  }

  Expanded _buildOrderColumn(BuildContext context, String title, List orders,
      String nextStatus, List menus, String status) {
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
              offset: const Offset(0, 3),
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
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                    final menuItems =
                        menus.where((menu) => menu.title == item.title);
                    final menuItem =
                        menuItems.isNotEmpty ? menuItems.first : null;
                    final effectivePreparationTime =
                        item.preperationTime ?? menuItem?.preparationTime;

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
                            return SingleChildScrollView(
                              child: Wrap(
                                direction: isLargeScreen
                                    ? Axis.horizontal
                                    : Axis.vertical,
                                spacing: 8.0,
                                runSpacing: 4.0,
                                children: [
                                  _buildOrderDetail(item.title ?? ''),
                                  _buildOrderDetail('${item.piece} adet' ?? ''),
                                  status == 'hazır'
                                      ? SizedBox()
                                      : _buildOrderDetailWithTime(
                                          effectivePreparationTime),
                                  _buildOrderDetail(item.tableId ?? ''),
                                  _buildOrderDetail(item.price != null
                                      ? '${item.price} ₺'
                                      : 'Fiyat Yok'),
                                  Center(
                                    child: _buildActionButtons(
                                        item, nextStatus, status),
                                  ),
                                ],
                              ),
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

  Widget _buildOrderDetailWithTime(int? preparationTime) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Text(
        preparationTime != null
            ? formatDuration(preparationTime)
            : 'Süre Yok', // Dakikayı saniyeye çevir
        overflow: TextOverflow.visible,
      ),
    );
  }

  String formatDuration(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    final formattedMinutes = minutes.toString().padLeft(2, '0');
    final formattedSeconds = remainingSeconds.toString().padLeft(2, '0');
    return '$formattedMinutes:$formattedSeconds';
  }

  Widget _buildActionButtons(item, String nextStatus, String status) {
    return Wrap(
      spacing: 8.0,
      children: [
        status != 'yeni'
            ? const SizedBox()
            : IconButton(
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
        status  != 'yeni'
            ? const SizedBox()
            : IconButton(
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
        nextStatus == 'teslim edildi' && item.preperationTime == 0
            ? TextButton(
                onPressed: () {
                  if (item.preperationTime == 0) {
                    ref
                        .read(_adminProvider.notifier)
                        .updateOrderStatus(item.id!, nextStatus);
                  }
                },
                child: const Text(
                  'Tamamlandı',
                  style: TextStyle(
                    color: Colors.green,
                  ),
                ),
              )
            : const SizedBox(),
      ],
    );
  }
}
