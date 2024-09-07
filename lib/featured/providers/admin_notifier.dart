import 'package:altmisdokuzapp/main.dart';
import 'package:altmisdokuzapp/product/model/order.dart' as app;
import 'package:altmisdokuzapp/product/utility/firebase/firebase_utility.dart';
import 'package:altmisdokuzapp/product/utility/firebase/user_firestore_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';
import 'dart:async';

final adminProvider = StateNotifierProvider<AdminNotifier, HomeState>((ref) {
  return AdminNotifier(ref);
});

class AdminNotifier extends StateNotifier<HomeState> with FirebaseUtility {
  final Ref _ref;
  final UserFirestoreHelper _firestoreHelper = UserFirestoreHelper();
  bool _isFirstLoad = true;
  List<app.Order> _previousOrders = [];
  Timer? _centralTimer;
  StreamSubscription? _orderSubscription; // Stream dinleyici için

  AdminNotifier(this._ref) : super(const HomeState()) {
    _checkAuthAndFetchOrders();
    _startCentralCountdown();
  }

  String? _selectedValue;
  String? get selectedValue => _selectedValue;

  @override
  void dispose() {
    _centralTimer?.cancel(); // Timer'ı iptal et
    _orderSubscription?.cancel(); // Firestore dinleyicisini iptal et
    super.dispose(); // StateNotifier'ın dispose metodunu çağır
  }

  void resetState() {
    state = const HomeState(); // Başlangıç durumuna sıfırla
  }

  /// Oturum kontrolü yap ve siparişleri getir
  Future<void> _checkAuthAndFetchOrders() async {
    final currentUser = _firestoreHelper.currentUser; // Oturum açmış kullanıcıyı kontrol et
    if (currentUser == null) {
      print('No authenticated user'); // Kullanıcı oturumu yoksa işlemi durdur
      return;
    }
    await fetchOrder();
    fetchOrdersStream(); // Dinleyiciyi başlat
  }

  /// Kullanıcıya özel siparişleri getirir
  Future<void> fetchOrder() async {
    try {
      final orderCollectionReference =
          _firestoreHelper.getUserCollection('orders');
      final response = await orderCollectionReference.withConverter<app.Order>(
        fromFirestore: (snapshot, options) {
          return const app.Order().fromFirebase(snapshot);
        },
        toFirestore: (value, options) {
          return value.toJson();
        },
      ).get();

      if (response.docs.isNotEmpty) {
        final values = response.docs.map((e) => e.data()).toList();
        if (!mounted) return; // Eğer widget 'mounted' değilse işlemi durdur
        state = state.copyWith(orders: values);
      }
    } catch (e) {
      print('Error fetching orders: $e');
    }
  }

  /// Kullanıcıya özel sipariş akışını takip eder
  void fetchOrdersStream() {
    final currentUser = _firestoreHelper.currentUser; // Oturum açmış kullanıcıyı kontrol et
    if (currentUser == null) {
      print('No authenticated user'); // Kullanıcı oturumu yoksa işlemi durdur
      return;
    }

    final orderCollectionReference =
        _firestoreHelper.getUserCollection('orders');

    _orderSubscription = orderCollectionReference.snapshots().listen((snapshot) {
      if (!mounted) {
        _orderSubscription?.cancel(); // Eğer widget 'mounted' değilse işlemi durdur
        return;
      }

      final values = snapshot.docs.map((doc) {
        return const app.Order()
            .fromFirebase(doc as DocumentSnapshot<Map<String, dynamic>>);
      }).toList();

      if (!_isFirstLoad) {
        if (values.length > _previousOrders.length) {
          showOrderAlert();
        }
      } else {
        _isFirstLoad = false;
      }

      _previousOrders = values;
      state = state.copyWith(orders: values);

      _startCentralCountdown();
    });
  }

  /// Sipariş hazırlık süresini günceller
  Future<void> _updateOrderPreparationTime(String orderId, int newTime) async {
    try {
      final orderDocument = _firestoreHelper.getUserDocument('orders', orderId);
      await orderDocument.update({'preperationTime': newTime});
    } catch (e) {
      print('Failed to update preparation time for orderId: $orderId: $e');
    }
  }

  /// Sipariş durumunu günceller
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      final orderDocument = _firestoreHelper.getUserDocument('orders', orderId);
      await orderDocument.update({'status': status});
    } catch (e) {
      print('Failed to update order status for orderId: $orderId: $e');
    }
  }

  /// Seçili değeri günceller
  void setSelectedValue(String? value) {
    _selectedValue = value;
    state = state.copyWith(selectedValue: value);
  }

  void showOrderAlert() {
    final context = _ref.read(navigatorKeyProvider).currentContext!;
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

  void _startCentralCountdown() {
    _centralTimer?.cancel();
    _centralTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final updatedOrders = state.orders?.map((order) {
        if (order.status == 'hazırlanıyor' &&
            order.preperationTime != null &&
            order.preperationTime! > 0) {
          if (order.id != null && order.id!.isNotEmpty) {
            _updateOrderPreparationTime(order.id!, order.preperationTime! - 1);
            return order.copyWith(preperationTime: order.preperationTime! - 1);
          }
        }
        return order;
      }).toList();

      state = state.copyWith(orders: updatedOrders);

      if (updatedOrders?.every((order) =>
              order.preperationTime == null || order.preperationTime == 0) ??
          true) {
        timer.cancel();
      }
    });
  }
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
