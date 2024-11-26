import 'package:foomoons/featured/providers/reports_notifier.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<dynamic> addPersonalDialog(
    BuildContext context, ReportsNotifier reportsNotifier) {
  final TextEditingController profileImageController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController positionController = TextEditingController();

  User? currentUser = FirebaseAuth.instance.currentUser;

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Bilgiler'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: profileImageController,
                decoration: const InputDecoration(labelText: 'Profil Resmi'),
              ),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'İsim Soyisim'),
              ),
              TextField(
                controller: positionController,
                decoration: const InputDecoration(labelText: 'Ünvan'),
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
              // Girdilerin doğrulaması
              if (nameController.text.isEmpty ||
                  positionController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Lütfen tüm alanları doldurun')),
                );
                return; // İşlemi durdur
              }
              try {
                await reportsNotifier.createEmployee(
                  name: nameController.text,
                  position: positionController.text,
                  profileImage: profileImageController.text,
                  cafeId: currentUser!.uid,
                );

                Navigator.of(context).pop();
              } catch (e) {
                print('Error: $e');
                // Hata durumunda ekrana hata mesajı gösterebilirsiniz
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      );
    },
  );
}
