import 'package:altmisdokuzapp/featured/providers/reports_notifier.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<dynamic> addPersonalDialog(
    BuildContext context, ReportsNotifier reportsNotifier) {
  final TextEditingController profileImageController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController positionController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Mail'),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Şifre'),
                obscureText: true,
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
              // Firebase'e çalışan kaydetme işlemi
              try {
                await reportsNotifier.createEmployee(
                  email: emailController.text,
                  password: passwordController.text,
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
