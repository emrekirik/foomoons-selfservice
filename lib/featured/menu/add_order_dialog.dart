import 'package:altmisdokuzapp/featured/menu/menu_notifier.dart';
import 'package:altmisdokuzapp/product/model/menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void showAddOrderDialog(
    BuildContext context, WidgetRef ref, int tableId, List<Menu> orderItems) {
  // Adisyonu fetch etmek için fonksiyonu çağırın
  ref.read(menuProvider.notifier).fetchTableBill(tableId);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Ürün Seç'),
        content: Container(
          width: double.maxFinite,
          child: Row(
            children: [
              // Sol taraf: Ürün listesi
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
              // Sağ taraf: Masanın adisyonu
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
                                  icon: Icon(Icons.remove_circle_outline),
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
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Toplam: ${tableBill.fold(0, (sum, item) => sum + (item.price ?? 0))} TL', // Fiyat null ise 0 olarak topla
                            style: TextStyle(
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
            child: Text('Kapat'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
