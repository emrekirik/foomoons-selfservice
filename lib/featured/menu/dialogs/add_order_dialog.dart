import 'package:altmisdokuzapp/featured/providers/menu_notifier.dart';
import 'package:altmisdokuzapp/product/model/menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

void showAddOrderDialog(
  BuildContext context,
  WidgetRef ref,
  int tableId,
  List<Menu> orderItems,
  String? qrUrl,
) {
  // Adisyonu fetch etmek için fonksiyonu çağırın
  ref.read(menuProvider.notifier).fetchTableBill(tableId);
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Ürün Seç'),
        content: SizedBox(
          width: double.maxFinite,
          child: Row(
            children: [
              // Sol taraf: Ürün listesi
              Flexible(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: orderItems.length,
                        itemBuilder: (BuildContext context, int index) {
                          final item = orderItems[index];
                          return ListTile(
                            title: Text(item.title ?? ''),
                            subtitle: Text(
                                '${item.price ?? 0} TL'), // Fiyat null ise 0 olarak göster
                            onTap: () {
                              // Ürün seçimi işlemi
                              // Ürünü masanın adisyonuna ekle
                              ref
                                  .read(menuProvider.notifier)
                                  .addItemToBill(tableId, item);
                            },
                          );
                        },
                      ),
                    ),
                    qrUrl != null
                        ? SizedBox(
                            child: QrImageView(
                              data: qrUrl,
                              version: QrVersions.auto,
                              size: 100.0,
                            ),
                          )
                        : const SizedBox(),
                  ],
                ),
              ),

              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    final tableBill = ref.watch(menuProvider
                        .select((state) => state.getTableBill(tableId)));
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Adisyon',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: tableBill.length,
                            itemBuilder: (BuildContext context, int index) {
                              final item = tableBill[index];
                              return ListTile(
                                title: Text(item.title ?? ''),
                                subtitle: Text(
                                    '${item.price ?? 0} TL'), // Fiyat null ise 0 olarak göster
                                trailing: IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () {
                                    // Adisyondan ürünü çıkarma işlemi
                                    ref
                                        .read(menuProvider.notifier)
                                        .removeItemFromBill(tableId, item);
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Toplam: ${tableBill.fold(0, (sum, item) => sum + (item.price ?? 0))} TL', // Fiyat null ise 0 olarak topla
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Kapat'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
