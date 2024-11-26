import 'package:foomoons/featured/providers/loading_notifier.dart';
import 'package:foomoons/featured/stock/stock_list_item.dart';
import 'package:foomoons/featured/providers/menu_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _menuProvider = StateNotifierProvider<MenuNotifier, MenuState>((ref) {
  return MenuNotifier(ref);
});

/// MenuView Widget
class StockMobileView extends ConsumerStatefulWidget {
  final String? successMessage;
  const StockMobileView({this.successMessage, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _StockMobileViewState();
}

class _StockMobileViewState extends ConsumerState<StockMobileView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(_menuProvider.notifier).fetchAndload();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loadingProvider);
    final menuNotifier = ref.watch(_menuProvider.notifier);
    final orderItem = ref
            .watch(_menuProvider)
            .products
            ?.where((item) => item.stock != null)
            .toList() ??
        [];

    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Ürün',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Stok Sayısı',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Güncelle',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: orderItem.length,
                    itemBuilder: (context, index) {
                      final item = orderItem[index];
                      return isLoading
                          ? const SizedBox()
                          : StockListItem(
                              item: item,
                              menuNotifier: menuNotifier,
                            );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
