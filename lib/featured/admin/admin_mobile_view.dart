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

class AdminMobileView extends ConsumerStatefulWidget {
  const AdminMobileView({super.key});

  @override
  ConsumerState<AdminMobileView> createState() => _AdminMobileViewState();
}

class _AdminMobileViewState extends ConsumerState<AdminMobileView> {
  String _selectedOrderType = 'Yeni Siparişler'; // Default selection
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: _selectedOrderType == 'Yeni Siparişler'
                          ? Colors.orange
                          : Colors.transparent, // Highlight color when selected
                      width: 3, // Thickness of the underline
                    ),
                  ),
                ),
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedOrderType = 'Yeni Siparişler';
                    });
                  },
                  child: Text(
                    'Yeni Siparişler',
                    style: TextStyle(
                      fontSize: 12,
                      color: _selectedOrderType == 'Yeni Siparişler'
                          ? Colors.orange
                          : Colors.blueAccent,
                    ),
                  ),
                ),
              ),
              // Hazırlanıyor Button
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: _selectedOrderType == 'Hazırlanıyor'
                          ? Colors.orange
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedOrderType = 'Hazırlanıyor';
                    });
                  },
                  child: Text(
                    'Hazırlanıyor',
                    style: TextStyle(
                      fontSize: 12,
                      color: _selectedOrderType == 'Hazırlanıyor'
                          ? Colors.orange
                          : Colors.blueAccent,
                    ),
                  ),
                ),
              ),
              // Geçmiş Siparişler Button
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: _selectedOrderType == 'Geçmiş Siparişler'
                          ? Colors.orange
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedOrderType = 'Geçmiş Siparişler';
                    });
                  },
                  child: Text(
                    'Geçmiş Siparişler',
                    style: TextStyle(
                      fontSize: 12,
                      color: _selectedOrderType == 'Geçmiş Siparişler'
                          ? Colors.orange
                          : Colors.blueAccent,
                    ),
                  ),
                ),
              ),
              isProcessing == true
                  ? const CircularProgressIndicator()
                  : const SizedBox()
            ],
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_selectedOrderType == 'Yeni Siparişler')
                  _buildOrderColumn(
                    context,
                    'Yeni Siparişler',
                    newOrders,
                    'hazırlanıyor',
                    menus,
                    'yeni',
                  ),
                if (_selectedOrderType == 'Hazırlanıyor')
                  _buildOrderColumn(
                    context,
                    'Hazırlanıyor',
                    preparingOrders,
                    'teslim edildi',
                    menus,
                    'hazırlanıyor',
                  ),
                if (_selectedOrderType == 'Geçmiş Siparişler')
                  _buildOrderColumn(context, 'Geçmiş Siparişler', pastOrders,
                      'teslim edildi', menus, 'hazır'),
              ],
            ),
          ),
        ],
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
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
              const Divider(),
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
                                                  status == 'hazır'
                                                      ? const SizedBox()
                                                      : _buildOrderDetailWithTime(
                                                          effectivePreparationTime),
                                                  _buildOrderDetail(item
                                                              .tableId !=
                                                          null
                                                      ? 'Masa ${item.tableId}'
                                                      : 'Masa bilgisi bilinmiyor.'),
                                                  _buildActionButtons(
                                                      item, nextStatus, status),
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

  Widget _buildOrderDetailWithTime(int? preparationTime) {
    return Expanded(
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
                  onPressed: () {
                    if (item.id != null) {
                      ref
                          .read(_adminProvider.notifier)
                          .updateOrderStatus(item.id!, nextStatus);
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
                  onPressed: isProcessing
                      ? null // İşlem devam ederken butonu devre dışı bırak
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
