import 'package:flutter/material.dart';

Future<dynamic> updatePersonalDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Bilgileri Güncelle'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                decoration: InputDecoration(labelText: 'Profil Resmi'),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'İsim Soyisim'),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Ünvan'),
                keyboardType: TextInputType.number,
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
              Navigator.of(context).pop();
            },
            child: const Text('Kaydet'),
          ),
        ],
      );
    },
  );
}