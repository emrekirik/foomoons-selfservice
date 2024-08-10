import 'package:altmisdokuzapp/main.dart';
import 'package:altmisdokuzapp/product/model/order.dart' as app;
import 'package:altmisdokuzapp/product/utility/firebase/firebase_collections.dart';
import 'package:altmisdokuzapp/product/utility/firebase/firebase_utility.dart';
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
  bool _isFirstLoad = true;
  List<app.Order> _previousOrders = [];

  AdminNotifier(this._ref) : super(const HomeState()) {
    fetchOrdersStream();
    _startCentralCountdown();
  }

  String? _selectedValue;
  String? get selectedValue => _selectedValue;
  Timer? _centralTimer;

  Future<void> fetchOrder() async {
    final orderCollectionReference = FirebaseCollections.checkOrder.reference;
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
      state = state.copyWith(orders: values);
    }
  }

  void showOrderAlert() {
    final context = _ref.read(navigatorKeyProvider).currentContext!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Yeni bir sipariş var.'),
        action: SnackBarAction(
          label: 'Tamam',
          onPressed: () {
            // SnackBar kapatıldığında yapılacak işlemler
          },
        ),
      ),
    );
  }


  void fetchOrdersStream() {
    FirebaseCollections.checkOrder.reference.snapshots().listen((snapshot) {
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

  void _startCentralCountdown() {
    _centralTimer?.cancel();
    _centralTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final updatedOrders = state.orders?.map((order) {
        if (order.status == 'hazırlanıyor' &&
            order.preperationTime != null &&
            order.preperationTime! > 0) {
          // Update Firebase with the new preparation time
          if (order.id != null && order.id!.isNotEmpty) {
            _updateOrderPreparationTime(order.id!, order.preperationTime! - 1);
            return order.copyWith(preperationTime: order.preperationTime! - 1);
          } else {
            print('Order ID is null or empty');
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

  Future<void> _updateOrderPreparationTime(String orderId, int newTime) async {
    final orderCollectionReference = FirebaseCollections.checkOrder.reference;
    try {
      final newTimeInMinutes = newTime;
      await orderCollectionReference
          .doc(orderId)
          .update({'preperationTime': newTimeInMinutes});
      print('Preparation time updated for orderId: $orderId');
    } catch (e) {
      print('Failed to update preparation time for orderId: $orderId: $e');
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    final orderCollectionReference = FirebaseCollections.checkOrder.reference;
    try {
      await orderCollectionReference.doc(orderId).update({'status': status});
      print('Order status updated for orderId: $orderId');
    } catch (e) {
      print('Failed to update order status for orderId: $orderId: $e');
    }
  }

  void setSelectedValue(String? value) {
    _selectedValue = value;
    state = state.copyWith(selectedValue: value);
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
