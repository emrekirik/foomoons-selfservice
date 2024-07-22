import 'package:flutter/material.dart';
import 'package:altmisdokuzapp/product/model/table.dart';
import 'package:altmisdokuzapp/featured/menu/menu_notifier.dart';

void showAddTableDialog(BuildContext context, MenuNotifier menuNotifier) {
  final TextEditingController tableIdController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Masa Ekle'),
        content: TextField(
          controller: tableIdController,
          decoration: InputDecoration(hintText: "Masa ID'si"),
          keyboardType: TextInputType.number,
        ),
        actions: <Widget>[
          TextButton(
            child: Text('İptal'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Masa Ekle'),
            onPressed: () {
              final tableIdText = tableIdController.text;
              if (tableIdText.isNotEmpty) {
                final tableId = int.parse(tableIdText);
                final newTable = CoffeTable(tableId: tableId);
                menuNotifier.addTable(newTable); // Masa ekleme fonksiyonunu çağır
              }
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
