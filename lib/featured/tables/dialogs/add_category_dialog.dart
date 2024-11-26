import 'package:flutter/material.dart';
import 'package:foomoons/product/model/category.dart';
import 'package:foomoons/featured/providers/menu_notifier.dart';

void showAddCategoryDialog(BuildContext context, MenuNotifier menuNotifier) {
  final TextEditingController controller = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Kategori Ekle'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: controller,
                decoration: const InputDecoration(labelText: 'Kategori İsmi'),
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
              final newCategory = Category(
                name: controller.text
              );
              menuNotifier.addCategory(newCategory);
              Navigator.of(context).pop();
            },
            child: const Text('Kaydet'),
          ),
        ],
      );
    },
  );
}
