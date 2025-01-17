import 'package:foomoons/featured/providers/loading_notifier.dart';
import 'package:foomoons/featured/providers/menu_notifier.dart';
import 'package:foomoons/main.dart';
import 'package:foomoons/product/model/menu.dart';
import 'package:foomoons/product/model/order.dart' as app;
import 'package:foomoons/product/utility/firebase/firebase_utility.dart';
import 'package:foomoons/product/utility/firebase/user_firestore_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';

final _menuProvider = StateNotifierProvider<MenuNotifier, MenuState>((ref) {
  return MenuNotifier(ref);
});

class AdminNotifier extends StateNotifier<HomeState> with FirebaseUtility {
  final Ref _ref;
  final UserFirestoreHelper _firestoreHelper = UserFirestoreHelper();
  final uuid = const Uuid();
  bool _isFirstLoad = true;
  List<app.Order> _previousOrders = [];
  Timer? _centralTimer;
  StreamSubscription? _orderSubscription; // Stream dinleyici için
  final player = AudioPlayer();

  AdminNotifier(this._ref) : super(const HomeState());

  String? _selectedValue;
  String? get selectedValue => _selectedValue;

  @override
  void dispose() {
    _centralTimer?.cancel(); // Timer'ı iptal et
    _orderSubscription?.cancel(); // Firestore dinleyicisini iptal et
    super.dispose(); // StateNotifier'ın dispose metodunu çağır
  }

  /// Kullanıcıya özel sipariş akışını takip eder
  void fetchOrdersStream() async {
    try {
      final userType = await _firestoreHelper.getUserType();
      final cafeId = await _firestoreHelper.getCafeId();

      Query orderCollectionReference;

      if (userType == 'çalışan' && cafeId != null) {
        // Çalışan ise bağlı olduğu cafeId'ye göre filtrele
        orderCollectionReference = FirebaseFirestore.instance
            .collection('users')
            .doc(cafeId)
            .collection('orders');
      } else if (userType == 'kafe') {
        // Kafe ise tüm siparişleri çek
        orderCollectionReference = _firestoreHelper.getUserCollection('orders');
      } else {
        print('User is not authorized to fetch orders');
        return;
      }

      // Dinleyiciyi başlat
      _orderSubscription =
          orderCollectionReference.snapshots().listen((snapshot) {
        final values = snapshot.docs.map((doc) {
          return const app.Order()
              .fromFirebase(doc as DocumentSnapshot<Map<String, dynamic>>);
        }).toList();

        // Siparişleri tarihe göre sıralama
        values.sort((a, b) {
          final dateA = a.orderDate;
          final dateB = b.orderDate;
          if (dateA == null && dateB == null) return 0;
          if (dateA == null) return 1;
          if (dateB == null) return -1;
          return dateB.compareTo(dateA);
        });

        if (!_isFirstLoad) {
          if (values.length > _previousOrders.length) {
            showOrderAlert();
          }
        } else {
          _isFirstLoad = false;
        }

        _previousOrders = values;
        state = state.copyWith(orders: values);
      });
    } catch (e) {
      print('Error fetching orders: $e');
    }
  }

  Future<void> fetchAndLoad() async {
    _ref.read(loadingProvider.notifier).setLoading(true);
    try {
      fetchOrdersStream();
    } catch (e) {
      print('Veri yükleme hatası');
    } finally {
      _ref.read(loadingProvider.notifier).setLoading(false);
    }
  }

  /// Sipariş hazırlık süresini günceller
  // Future<void> _updateOrderPreparationTime(String orderId, int newTime) async {
  //   try {
  //     final orderDocument = _firestoreHelper.getUserDocument('orders', orderId);
  //     await orderDocument.update({'preperationTime': newTime});
  //   } catch (e) {
  //     print('Failed to update preparation time for orderId: $orderId: $e');
  //   }
  // }

  //// Sipariş durumunu günceller ve durum `teslim edildi` olduğunda stok güncellemesi yapar
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      final userType = await _firestoreHelper.getUserType();
      final cafeId = await _firestoreHelper.getCafeId();
      late DocumentReference orderDocument;

      if (userType == 'kafe') {
        orderDocument =
            _firestoreHelper.getUserCollection('orders').doc(orderId);
      } else if (userType == 'çalışan' && cafeId != null) {
        orderDocument = FirebaseFirestore.instance
            .collection('users')
            .doc(cafeId)
            .collection('orders')
            .doc(orderId);
      } else {
        throw Exception('Geçersiz kullanıcı tipi');
      }

      await orderDocument.update({'status': status}); // Durumu güncelle

      // Sipariş `teslim edildi` durumuna geçtiğinde stok güncellemesini ve `bills` kaydını yap
      if (status == 'teslim edildi') {
        // Sipariş detaylarını al
        final orderSnapshot = await orderDocument.get();
        final orderData = orderSnapshot.data() as Map<String, dynamic>?;

        if (orderData != null) {
          // Order nesnesini oluştur
          final app.Order order = const app.Order().fromJson(orderData);

          // Eğer `productId` ve `piece` değerleri varsa stok düşüşünü yap
          if (order.id != null && order.piece != null) {
            final menuNotifier = _ref.read(_menuProvider.notifier);
            await menuNotifier.reduceProductStock(
              order.id!,
              order.piece!,
              _ref.read(navigatorKeyProvider).currentContext!,
            );
            print('Stok güncellemesi başarılı: productId: ${order.id}');
          }

          // Order'ı bills koleksiyonuna kaydetme işlemi
          if (order.tableId != null) {
            late DocumentReference billDocument;
            if (userType == 'çalışan' && cafeId != null) {
              billDocument = FirebaseFirestore.instance
                  .collection('users')
                  .doc(cafeId)
                  .collection('bills')
                  .doc(order.tableId);
            } else if (userType == 'kafe') {
              billDocument =
                  _firestoreHelper.getUserDocument('bills', order.tableId!);
            }

            final doc = await billDocument.get();
            List<Menu> currentBillItems = [];

            if (doc.exists) {
              // Mevcut adisyon öğelerini al
              final data = doc.data() as Map<String, dynamic>;
              currentBillItems = (data['billItems'] as List<dynamic>)
                  .map((item) => Menu.fromJson(item as Map<String, dynamic>))
                  .toList();
            }

            // Siparişten bir Menu öğesi oluştur ve adisyona ekle
            // Siparişten her adet için bir Menu öğesi oluştur ve adisyona ekle
            for (int i = 0; i < (order.piece ?? 1); i++) {
              final String uniqueItemId = uuid.v4();
              final menuItem = Menu(
                title: order.title,
                price: order.price,
                preparationTime: order.preperationTime,
                id: uniqueItemId,
                status: order.status,
                piece: 1, // Tek bir adet ekleniyor
              );
              currentBillItems.add(menuItem);
            }

            // Bills koleksiyonundaki ilgili belgeyi güncelle
            await billDocument.set({
              'tableId': order.tableId,
              'billItems':
                  currentBillItems.map((item) => item.toJson()).toList(),
            });

            print(
                'Sipariş `bills` koleksiyonuna kaydedildi: tableId: ${order.tableId}');
          }
        }
      }
    } catch (e) {
      print('Failed to update order status for orderId: $orderId: $e');
    }
  }

  Future<String?> getCafeIdForCurrentUser() async {
    final currentUser = _firestoreHelper.currentUser;
    if (currentUser == null) {
      print('No authenticated user');
      return null;
    }
    // Kullanıcı verilerini Firestore'dan al
    final userDoc =
        await _firestoreHelper.getUserDocument('users', currentUser.uid).get();
    final userData = userDoc.data() as Map<String, dynamic>?;
    return userData?['cafeId'] as String?;
  }

  /// Seçili değeri günceller
  void setSelectedValue(String? value) {
    _selectedValue = value;
    state = state.copyWith(selectedValue: value);
  }

  void playNotificationSound() async {
    try {
      await player.setUrl('assets/assets/sounds/notification.mp3');
      player.play();
    } catch (e) {
      print('Ses çalınamadı: $e');
    }
  }

  void showOrderAlert() {
    final context = _ref.read(navigatorKeyProvider).currentContext;
    if (context != null) {
      playNotificationSound();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Yeni bir sipariş var.'),
          action: SnackBarAction(
            label: 'Tamam',
            onPressed: () {},
          ),
        ),
      );
    }
  }

//   void startCentralCountdown() {
//     _centralTimer?.cancel();
//     _centralTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       final updatedOrders = state.orders?.map((order) {
//         if (order.status == 'hazırlanıyor' &&
//             order.preperationTime != null &&
//             order.preperationTime! > 0) {
//           if (order.id != null && order.id!.isNotEmpty) {
//             _updateOrderPreparationTime(order.id!, order.preperationTime! - 1);
//             return order.copyWith(preperationTime: order.preperationTime! - 1);
//           }
//         }
//         return order;
//       }).toList();

//       state = state.copyWith(orders: updatedOrders);

//       if (updatedOrders?.every((order) =>
//               order.preperationTime == null || order.preperationTime == 0) ??
//           true) {
//         timer.cancel();
//       }
//     });
//   }
}

class HomeState extends Equatable {
  const HomeState({
    this.orders,
    this.selectedValue,
  });

  final List<app.Order>? orders;
  final String? selectedValue;

  @override
  List<Object?> get props => [orders, selectedValue];

  HomeState copyWith({
    List<app.Order>? orders,
    String? selectedValue,
  }) {
    return HomeState(
      orders: orders ?? this.orders,
      selectedValue: selectedValue ?? this.selectedValue,
    );
  }
}
