import 'package:flutter/material.dart';

Future<dynamic> ProfileInfoShowDialog(
  BuildContext context, {
  required String initialValue,
  required void Function(String updatedValue) onSave, // Güncelleme işlemi için callback
}) {
  final TextEditingController controller = TextEditingController(text: initialValue);

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Bilgiyi Güncelle'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: controller,
                decoration: InputDecoration(labelText: 'Bilgi'),
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
              // Yeni değeri geri döndürüyoruz
              onSave(controller.text); 
              Navigator.of(context).pop();
            },
            child: const Text('Kaydet'),
          ),
        ],
      );
    },
  );
}


