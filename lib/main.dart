import 'package:altmisdokuzapp/featured/tab/tab_view.dart';
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

class MyApp extends ConsumerWidget  {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigatorKey = ref.read(navigatorKeyProvider);
    return MaterialApp(
      navigatorKey: navigatorKey,
      home: const TabView(),
    );
  }
}

//TODO:
//Panel'de rapor kısmının UI'ını yap  - 04  +
//Sipariş adet ve süresini firebase'e bağla ve dinamikleştir - 04
//Müşteri tarafında berfin'in attığı kodları entegre et - 05
//Panel tarafında ürün eklerken min süre 06
//Panel'de ürün ekleme sayfasının ui'ını yap 06
//Panelde ürüne tıkladığında ürün bilgileri gelecek ve güncellenebilecek 07
//Panelde ürüne girilen min süreyi müşteri tarafına gönderme 07  
//Iyzico'yu entegre et 08
//QR code sistemini yap 09 +2 gün sarkabilir....