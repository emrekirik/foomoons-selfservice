import 'package:altmisdokuzapp/featured/providers/admin_notifier.dart';
import 'package:altmisdokuzapp/featured/providers/loading_notifier.dart';
import 'package:altmisdokuzapp/featured/providers/menu_notifier.dart' as menu;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _adminProvider = StateNotifierProvider<AdminNotifier, HomeState>((ref) {
  return AdminNotifier(ref);
});

final _menuProvider = StateNotifierProvider<menu.MenuNotifier, menu.MenuState>(
    (ref) => menu.MenuNotifier(ref));

class AdminView extends ConsumerStatefulWidget {
  const AdminView({super.key});

  @override
  ConsumerState<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends ConsumerState<AdminView> {
  bool isProcessing = false;
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(_adminProvider.notifier).fetchAndLoad();
    });
  }

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(_adminProvider).orders ?? [];
    final menus = ref.watch(_menuProvider).products ?? [];
    final newOrders = orders.where((order) => order.status == 'yeni').toList();
    final preparingOrders =
        orders.where((order) => order.status == 'hazırlanıyor').toList();
    // final readyOrders =
    //     orders.where((order) => order.status == 'hazır').toList();
    final pastOrders =
        orders.where((order) => order.status == 'teslim edildi').toList();

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderColumn(
              context,
              'Yeni Siparişler',
              newOrders,
              'hazırlanıyor',
              menus,
              'yeni',
            ),
            const SizedBox(width: 16),
            _buildOrderColumn(
              context,
              'Hazırlanıyor',
              preparingOrders,
              'teslim edildi',
              menus,
              'hazırlanıyor',
            ),
            const SizedBox(width: 16),
            _buildOrderColumn(context, 'Geçmiş Siparişler', pastOrders,
                'teslim edildi', menus, 'hazır'),
          ],
        ),
      ),
    );
  }

  Expanded _buildOrderColumn(
    BuildContext context,
    String title,
    List orders,
    String nextStatus,
    List menus,
    String status,
  ) {
    final isLoading = ref.watch(loadingProvider);
    // final stockWarning = ref.watch(_menuProvider).stockWarning;
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(),
                    Text(
                      title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    if (status == 'hazırlanıyor')
                      if (isProcessing == true)
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        )
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(
                  indent: 100,
                  endIndent: 100,
                ),
                Expanded(
                  child: orders.isEmpty
                      ? const Center(child: Text('Şu anda siparişiniz yok'))
                      : ListView.separated(
                          itemCount: orders.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final item = orders[index];
                            final menuItems =
                                menus.where((menu) => menu.title == item.title);
                            final menuItem =
                                menuItems.isNotEmpty ? menuItems.first : null;
                            final effectivePreparationTime =
                                item.preperationTime ??
                                    menuItem?.preparationTime ??
                                    60;

                            return Card(
                              color: Colors.white,
                              elevation: 0,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    // final isLargeScreen = constraints.maxWidth > 200;
                                    return SingleChildScrollView(
                                      child: isLoading
                                          ? const SizedBox()
                                          : Column(
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  // direction: isLargeScreen
                                                  //     ? Axis.horizontal
                                                  //     : Axis.vertical,
                                                  // spacing: 8.0,
                                                  // runSpacing: 4.0,
                                                  children: [
                                                    _buildOrderDetail(
                                                        item.title ?? ''),
                                                    _buildOrderDetail(
                                                        '${item.piece} adet'),
                                                    // status == 'hazır'
                                                    //     ? const SizedBox()
                                                    //     : _buildOrderDetailWithTime(
                                                    //         effectivePreparationTime),
                                                    _buildOrderDetail(item
                                                                .tableId !=
                                                            null
                                                        ? '${item.tableId}'
                                                        : 'Masa bilgisi bilinmiyor.'),
                                                    _buildActionButtons(item,
                                                        nextStatus, status),
                                                  ],
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
      ),
    );
  }

  Widget _buildOrderDetail(String detail) {
    return Expanded(
      child: Text(
        detail,
        overflow: TextOverflow.visible,
      ),
    );
  }

  // Widget _buildOrderDetailWithTime(int? preparationTime) {
  //   return Expanded(
  //     child: Text(
  //       preparationTime != null
  //           ? formatDuration(preparationTime)
  //           : 'Süre Yok', // Dakikayı saniyeye çevir
  //       overflow: TextOverflow.visible,
  //     ),
  //   );
  // }

  String formatDuration(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    final formattedMinutes = minutes.toString().padLeft(2, '0');
    final formattedSeconds = remainingSeconds.toString().padLeft(2, '0');
    return '$formattedMinutes:$formattedSeconds';
  }

  Widget _buildActionButtons(item, String nextStatus, String status) {
    return Expanded(
      child: Row(
        // spacing: 8.0,
        children: [
          status != 'yeni'
              ? const SizedBox()
              : IconButton(
                  icon: const Icon(
                    Icons.check,
                    size: 17,
                  ),
                  onPressed: isProcessing == true
                      ? null
                      : () async {
                          setState(() {
                            isProcessing = true;
                          });
                          try {
                            await ref
                                .read(_adminProvider.notifier)
                                .updateOrderStatus(item.id!, nextStatus);
                            // İşlem tamamlandıktan sonra kısa bir gecikme ekle
                            await Future.delayed(Duration(milliseconds: 500));
                          } finally {
                            setState(() {
                              isProcessing = false;
                            });
                          }
                        },
                ),
          status != 'yeni'
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
          nextStatus == 'teslim edildi'
              ? TextButton(
                  onPressed: isProcessing == true
                      ? null
                      : () async {
                          setState(() {
                            isProcessing = true;
                          });
                          await ref
                              .read(_adminProvider.notifier)
                              .updateOrderStatus(item.id!, nextStatus);
                          setState(() {
                            isProcessing = false;
                          });
                        },
                  child: const Text(
                    'Tamamlandı',
                    style: TextStyle(color: Colors.green, fontSize: 12),
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}
