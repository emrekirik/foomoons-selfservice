import 'package:flutter/material.dart';
import 'package:altmisdokuzapp/product/model/table.dart';
import 'package:altmisdokuzapp/featured/menu/menu_notifier.dart';

void showAddTableDialog(BuildContext context, MenuNotifier menuNotifier) {
  final TextEditingController tableIdController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Masa Ekle'),
        content: TextField(
          controller: tableIdController,
          decoration: const InputDecoration(hintText: "Masa ID'si"),
          keyboardType: TextInputType.number,
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('İptal'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Masa Ekle'),
            onPressed: () {
              final tableIdText = tableIdController.text;
              if (tableIdText.isNotEmpty) {
                final tableId = int.parse(tableIdText);
                final newTable = CoffeTable(tableId: tableId);
                menuNotifier
                    .addTable(newTable); // Masa ekleme fonksiyonunu çağır
              }
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
