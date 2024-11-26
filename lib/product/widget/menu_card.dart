import 'package:foomoons/featured/providers/menu_notifier.dart';
import 'package:foomoons/product/model/category.dart';
import 'package:foomoons/product/model/menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _menuProvider = StateNotifierProvider<MenuNotifier, MenuState>((ref) {
  return MenuNotifier(ref);
});

class MenuCard extends ConsumerWidget {
  final Menu item;
  final List<Category> categories;
  const MenuCard({required this.item, required this.categories, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isUploading = false;
    return InkWell(
      onTap: () async {
        final productId = item.id;
        if (productId == null) {
          print('id null geliyor');
          print('Menu Item: ${item.title}, ID: ${item.id}');
        } else {
          print('Menu Item: ${item.title}, ID: ${item.id}');

          showDialog(
            context: context,
            builder: (BuildContext context) {
              late TextEditingController titleController;
              late TextEditingController priceController;
              late TextEditingController prepTimeController;
              late TextEditingController categoryController;
              late TextEditingController stockController;
              // Mevcut ürünü dolduruyoruz
              final initialPrepTimeInMinutes = (item.preparationTime ?? 0) / 60;
              titleController = TextEditingController(text: item.title);
              priceController =
                  TextEditingController(text: item.price?.toString());
              prepTimeController = TextEditingController(
                  text: initialPrepTimeInMinutes.toStringAsFixed(0));
              categoryController = TextEditingController(text: item.category);
              stockController = TextEditingController(
                  text: item.stock?.toString() ?? 'Stok Girişi Yok');

              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: const Text('Ürün Güncelle'),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () async {
                              setState(() {
                                isUploading = true;
                              });
                              await ref
                                  .read(_menuProvider.notifier)
                                  .pickAndUploadImage();
                              setState(() {
                                isUploading = false;
                              });
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 100,
                                  backgroundImage: (ref
                                                  .watch(_menuProvider)
                                                  .photoURL !=
                                              null &&
                                          ref
                                              .watch(_menuProvider)
                                              .photoURL!
                                              .isNotEmpty)
                                      ? NetworkImage(
                                          ref.watch(_menuProvider).photoURL!)
                                      : (item.image != null
                                          ? NetworkImage(item.image!)
                                          : const AssetImage(
                                                  'assets/images/food_placeholder.png')
                                              as ImageProvider),
                                ),
                                if (isUploading)
                                  const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                              ],
                            ),
                          ),
                          TextField(
                            controller: titleController,
                            decoration:
                                const InputDecoration(labelText: 'Ürün İsmi'),
                          ),
                          TextField(
                            controller: priceController,
                            decoration:
                                const InputDecoration(labelText: 'Ürün Fiyatı'),
                            keyboardType: TextInputType.number,
                          ),
                          TextField(
                            controller: prepTimeController,
                            decoration: const InputDecoration(
                                labelText: 'Ürün Min Hazırlanma Süresi'),
                            keyboardType: TextInputType.number,
                          ),
                          TextField(
                            controller: stockController,
                            decoration:
                                const InputDecoration(labelText: 'Stok'),
                            keyboardType: TextInputType.number,
                          ),
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                                labelText: 'Ürün Kategorisi'),
                            items: categories.map((category) {
                              return DropdownMenuItem<String>(
                                value: category.name,
                                child: Text(category.name ?? ''),
                              );
                            }).toList(),
                            value: item.category,
                            onChanged: (value) {
                              categoryController.text = value ?? '';
                            },
                          ),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('İptal'),
                      ),
                      ElevatedButton(
                        onPressed: isUploading
                            ? null // Eğer hala resim yükleniyorsa butonu devre dışı bırak
                            : () async {
                                final updatedProduct = Menu(
                                  title: titleController.text,
                                  price: int.tryParse(priceController.text),
                                  image: ref.watch(_menuProvider).photoURL,
                                  preparationTime:
                                      int.tryParse(prepTimeController.text)! *
                                          60,
                                  category: categoryController.text,
                                  stock: int.tryParse(stockController.text),
                                );
                                await ref
                                    .read(_menuProvider.notifier)
                                    .updateProduct(
                                        productId, updatedProduct, context);
                                Navigator.of(context).pop();
                              },
                        child: const Text('Kaydet'),
                      ),
                    ],
                  );
                },
              );
            },
          );
          
        }
      },
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: FadeInImage.assetNetwork(
                  placeholder:
                      'assets/images/food_placeholder.png', // Geçici resim yolu
                  image: item.image ?? 'assets/images/food_placeholder.png',
                  width: double.infinity,
                  height: 130,
                  fit: BoxFit.cover,
                  imageErrorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/food_placeholder.png', // Placeholder image path
                      width: double.infinity,
                      height: 120,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                item.title ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              item.price != null ? '${item.price} ₺' : 'Fiyat Yok',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
