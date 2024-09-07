import 'package:altmisdokuzapp/featured/auth/auth_wrapper.dart';
import 'package:altmisdokuzapp/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final navigatorKeyProvider = Provider<GlobalKey<NavigatorState>>((ref) {
  return GlobalKey<NavigatorState>();
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigatorKey = ref.read(navigatorKeyProvider);
    return MaterialApp(
      navigatorKey: navigatorKey,
      home: const AuthWrapper(),
    );
  }
}

//TODO:
//Panel'de rapor kısmının UI'ını yap : yapıldı
//Sipariş minimum süresini menu'ye çek firebase'den : yapıldı‚
//Kategori ekleme : yapıldı
//Panelde ürüne tıkladığında ürün bilgileri gelecek ve güncellenebilecek : yapıldı
//Panel'de ürün ekleme sayfasının ui'ını yap
//Stok sayfası
//Iyzico'yu entegre et
//QR code sistemini yap  yapıldı