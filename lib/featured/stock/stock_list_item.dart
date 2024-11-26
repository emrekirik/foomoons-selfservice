import 'package:foomoons/featured/providers/menu_notifier.dart';
import 'package:foomoons/featured/stock/stock_update_showdialog.dart';
import 'package:foomoons/product/model/menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StockListItem extends ConsumerWidget {
  final Menu item;
  final MenuNotifier menuNotifier;
  const StockListItem(
      {required this.item, required this.menuNotifier, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // İlk Text genişliğini sabitleyerek hizalama
              Text(
                item.title ?? '',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Stok bilgisi için Expanded kullanımı
              Expanded(
                child: Text(
                  item.stock != null ? '${item.stock}' : 'Stok Girilmemiş',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Düzenleme butonunun hizalanması
              IconButton(
                onPressed: () {
                  final productId = item.id;
                  if (productId == null) {
                    print('id null geliyor');
                    print('Menu Item: ${item.title}, ID: ${item.id}');
                  } else {
                    stockUpdateShowDialog(context, menuNotifier, productId);
                  }
                },
                icon: const Icon(Icons.create_outlined),
              )
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }
}
