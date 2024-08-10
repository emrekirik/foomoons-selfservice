import 'package:flutter/material.dart';
import 'package:altmisdokuzapp/product/model/category.dart';
import 'package:altmisdokuzapp/product/model/menu.dart';
import 'package:altmisdokuzapp/featured/menu/menu_notifier.dart';

void showUpdateProductDialog(BuildContext context, MenuNotifier menuNotifier,
    List<Category> categories, String productId) {
  // Mevcut ürünü alıyoruz
  final existingProduct = menuNotifier.getProductById(productId);

  // Mevcut verileri TextEditingController'lara dolduruyoruz
  final TextEditingController titleController =
      TextEditingController(text: existingProduct?.title);
  final TextEditingController priceController =
      TextEditingController(text: existingProduct?.price?.toString());
  final TextEditingController imageController =
      TextEditingController(text: existingProduct?.image);
  final TextEditingController prepTimeController =
      TextEditingController(text: existingProduct?.preparationTime?.toString());
  final TextEditingController categoryController =
      TextEditingController(text: existingProduct?.category);

  showDialog(
    context: context,
    builder: (BuildContext context) {
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
                decoration: const InputDecoration(labelText: 'Ürün Resmi URL'),
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
                value: existingProduct?.category,
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
              final updateProduct = Menu(
                title: titleController.text,
                price: int.tryParse(priceController.text),
                image: imageController.text,
                preparationTime: int.tryParse(prepTimeController.text),
                category: categoryController.text,
              );
              // Güncelleme işlemi
              await menuNotifier.updateProduct(productId, updateProduct, context);
              Navigator.of(context).pop();
            },
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
}
