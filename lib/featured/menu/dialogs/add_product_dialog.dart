import 'package:flutter/material.dart';
import 'package:altmisdokuzapp/product/model/category.dart';
import 'package:altmisdokuzapp/product/model/menu.dart';
import 'package:altmisdokuzapp/featured/providers/menu_notifier.dart';


void showAddProductDialog(BuildContext context, MenuNotifier menuNotifier,
      List<Category> categories) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController imageController = TextEditingController();
    final TextEditingController prepTimeController = TextEditingController();
    final TextEditingController categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ürün Ekle'),
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
                      labelText: 'Ürün Min Hazırlanma Süresi'),
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
              onPressed: () {
                final newProduct = Menu(
                  title: titleController.text,
                  price: int.tryParse(priceController.text),
                  image: imageController.text,
                  preparationTime: int.tryParse(prepTimeController.text)! * 60,
                  category: categoryController.text,
                );
                menuNotifier.addProduct(newProduct);
                Navigator.of(context).pop();
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }