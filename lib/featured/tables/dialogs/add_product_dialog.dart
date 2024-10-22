import 'package:altmisdokuzapp/featured/providers/menu_notifier.dart';
import 'package:altmisdokuzapp/product/model/category.dart';
import 'package:altmisdokuzapp/product/model/menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _menuProvider = StateNotifierProvider<MenuNotifier, MenuState>((ref) {
  return MenuNotifier(ref);
});

void showAddProductDialog(
  BuildContext context,
  List<Category> categories,
  MenuNotifier menuNotifier,
  MenuState menuState,
) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      // Text editing controllers are initialized inside the function.
      TextEditingController titleController = TextEditingController();
      TextEditingController priceController = TextEditingController();
      TextEditingController prepTimeController = TextEditingController();
      TextEditingController categoryController = TextEditingController();

      return AlertDialog(
        title: const Text('Ürün Ekle'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // StatefulBuilder ile yalnızca bu kısmı güncelleriz
              Consumer(
                builder: (context, ref, child) {
                  final _menuNotifier = ref.read(_menuProvider.notifier);
                  final _menuState = ref.watch(_menuProvider);
                  return GestureDetector(
                    onTap: () async {
                      await _menuNotifier.pickAndUploadImage();
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 100,
                          backgroundImage: _menuState.photoURL != null
                              ? NetworkImage(_menuState.photoURL!)
                              : const AssetImage(
                                  'assets/images/food_placeholder.png'),
                        ),
                        if (_menuState.isUploading)
                          const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                      ],
                    ),
                  );
                },
              ),

              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Ürün İsmi'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Ürün Fiyatı'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: prepTimeController,
                decoration: const InputDecoration(
                    labelText: 'Ürün Min Hazırlanma Süresi'),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Ürün Kategorisi'),
                items: categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category.name,
                    child: Text(category.name ?? ''),
                  );
                }).toList(),
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
            onPressed: () async {
              if (menuState.isUploading) {
                return; // Eğer hala resim yükleniyorsa buton devre dışı bırakılır
              }

              // Girdilerin doğrulaması
              if (titleController.text.isEmpty ||
                  priceController.text.isEmpty ||
                  prepTimeController.text.isEmpty ||
                  categoryController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Lütfen tüm alanları doldurun')),
                );
                return; // İşlemi durdur
              }
              await menuNotifier.fetchProducts();
              final newProduct = Menu(
                title: titleController.text,
                price: int.tryParse(priceController.text),
                image: menuState.photoURL,
                preparationTime: int.tryParse(prepTimeController.text)! * 60,
                category: categoryController.text,
              );

              await menuNotifier.addProduct(newProduct);
              Navigator.of(context).pop();
            },
            child: const Text('Kaydet'),
          )
        ],
      );
    },
  );
}


