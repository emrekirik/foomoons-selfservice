import 'package:foomoons/featured/providers/tables_notifier.dart';
import 'package:flutter/material.dart';

void showAddAreaDialog(BuildContext context, TablesNotifier tablesNotifier) {
  final TextEditingController areaName = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Bölge Ekle'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: areaName,
                    decoration: const InputDecoration(hintText: "Bölge İsmi"),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('İptal'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                onPressed: () {
                  final areaNameText = areaName.text;
                  if (areaNameText.isNotEmpty) {
                    tablesNotifier.addAreaToFirebase(areaNameText);
                  }
                  Navigator.of(context).pop();
                },
                child: const Text('Bölge Ekle'),
              ),
            ],
          );
        },
      );
    },
  );
}
