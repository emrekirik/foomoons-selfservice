import 'package:flutter/material.dart';
import 'package:altmisdokuzapp/product/model/category.dart';
import 'package:altmisdokuzapp/product/model/menu.dart';
import 'package:altmisdokuzapp/featured/menu/menu_notifier.dart';

void showUpdateProductDialog(BuildContext context, MenuNotifier menuNotifier,
    List<Category> categories, String productId) {
  final existingProduct = menuNotifier.getProductById(productId);
  bool isPrepTimeChanged = false;

  // Mevcut preparationTime'ı saniyeden dakikaya çeviriyoruz
  final initialPrepTimeInMinutes = existingProduct?.preparationTime != null
      ? (existingProduct!.preparationTime! / 60).toStringAsFixed(0)
      : '';

  final TextEditingController titleController =
      TextEditingController(text: existingProduct?.title);
  final TextEditingController priceController =
      TextEditingController(text: existingProduct?.price?.toString());
  final TextEditingController imageController =
      TextEditingController(text: existingProduct?.image);
  final TextEditingController prepTimeController =
      TextEditingController(text: initialPrepTimeInMinutes);
  final TextEditingController categoryController =
      TextEditingController(text: existingProduct?.category);

  bool isChanged = false;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          // Değişiklikleri kontrol eden fonksiyon
          void checkIfChanged() {
            setState(() {
              isChanged = titleController.text != existingProduct?.title ||
                  priceController.text != existingProduct?.price?.toString() ||
                  imageController.text != existingProduct?.image ||
                  prepTimeController.text != initialPrepTimeInMinutes ||
                  categoryController.text != existingProduct?.category;
              isPrepTimeChanged =
                  prepTimeController.text != initialPrepTimeInMinutes;
            });
          }

          // Dinleyiciler ekleyerek değişiklikleri takip ediyoruz
          titleController.addListener(checkIfChanged);
          priceController.addListener(checkIfChanged);
          imageController.addListener(checkIfChanged);
          prepTimeController.addListener(checkIfChanged);
          categoryController.addListener(checkIfChanged);
          // String değeri int'e dönüştür

          return AlertDialog(
            title: const Text('Ürün Güncelle'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
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
                    controller: imageController,
                    decoration:
                        const InputDecoration(labelText: 'Ürün Resmi URL'),
                  ),
                  TextField(
                    controller: prepTimeController,
                    decoration: const InputDecoration(
                        labelText: 'Ürün Min Hazırlanma Süresi (dakika)'),
                    keyboardType: TextInputType.number,
                  ),
                  DropdownButtonFormField<String>(
                    decoration:
                        const InputDecoration(labelText: 'Ürün Kategorisi'),
                    items: categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category.name,
                        child: Text(category.name ?? ''),
                      );
                    }).toList(),
                    value: existingProduct?.category,
                    onChanged: (value) {
                      categoryController.text = value ?? '';
                      setState(() {
                        isChanged = true; // Dropdown değiştirildiğinde true yap
                      });
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
                onPressed: isChanged
                    ? () async {
                        final int? preparationTime =
                            int.tryParse(prepTimeController.text);
                        final updateProduct = Menu(
                          title: titleController.text,
                          price: int.tryParse(priceController.text),
                          image: imageController.text,
                          preparationTime:
                              isPrepTimeChanged && preparationTime != null
                                  ? preparationTime * 60
                                  : existingProduct?.preparationTime,
                          category: categoryController.text,
                        );
                        await menuNotifier.updateProduct(
                            productId, updateProduct, context);
                        Navigator.of(context).pop();
                      }
                    : null, // Değişiklik yapılmadıysa buton devre dışı
                child: const Text('Kaydet'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await menuNotifier.deleteProduct(productId, context);
                  Navigator.of(context).pop(); // Dialog'u kapat
                },
                child: const Text('Ürünü Sil'),
              ),
            ],
          );
        },
      );
    },
  );
}
