import 'package:foomoons/featured/providers/loading_notifier.dart';
import 'package:foomoons/product/utility/firebase/user_firestore_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foomoons/product/model/user.dart' as Userr;

class ReportsNotifier extends StateNotifier<ReportsState> {
  static const String allCategories = 'Tüm Kategoriler';
  final UserFirestoreHelper _firestoreHelper = UserFirestoreHelper();
  final Ref ref; // Ref instance to manage the global provider
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ReportsNotifier(this.ref) : super(const ReportsState());

  Future<void> fetchDeliveredRevenues({required String period, TimeOfDay? startTime, TimeOfDay? endTime}) async {
    try {
      DateTime now = DateTime.now();
      DateTime startDate;

      switch (period) {
        case 'Günlük':
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case 'Haftalık':
          startDate = now.subtract(const Duration(days: 7));
          break;
        case 'Aylık':
          startDate = now.subtract(const Duration(days: 30));
          break;
        default:
          startDate = now;
      }

      final orderCollection = _firestoreHelper.getUserCollection('pastOrders');
      final querySnapshot = await orderCollection
          .where('closedAtDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .get();

      int totalRevenues = 0;

      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null && data['totalPrice'] != null) {
          final closedAtDate = (data['closedAtDate'] as Timestamp).toDate();
          
          // Saat kontrolü
          if (startTime != null && endTime != null) {
            final orderHour = closedAtDate.hour;
            final orderMinute = closedAtDate.minute;
            
            if (orderHour < startTime.hour || 
                (orderHour == startTime.hour && orderMinute < startTime.minute) ||
                orderHour > endTime.hour ||
                (orderHour == endTime.hour && orderMinute > endTime.minute)) {
              continue;
            }
          }

          final totalPrice = (data['totalPrice'] as num).toInt();
          totalRevenues += totalPrice;
        }
      }

      state = state.copyWith(totalRevenues: totalRevenues);
    } catch (e) {
      _handleError(e, 'Teslim edilen siparişlerin toplam hasılatı hesaplanırken hata: $e');
    }
  }

  Future<void> fetchTotalProduct() async {
    try {
      final productCollection = _firestoreHelper.getUserCollection('products');
      final totalProductCount = await productCollection.get();
      final totalProduct = totalProductCount.size;

      state = state.copyWith(totalProduct: totalProduct);
    } catch (e) {
      _handleError(e, 'Toplam ürün sayısı yükleme hatası');
    }
  }

  Future<void> fetchTotalOrder({required String period, TimeOfDay? startTime, TimeOfDay? endTime}) async {
    try {
      DateTime now = DateTime.now();
      DateTime startDate;

      switch (period) {
        case 'Günlük':
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case 'Haftalık':
          startDate = now.subtract(const Duration(days: 7));
          break;
        case 'Aylık':
          startDate = now.subtract(const Duration(days: 30));
          break;
        default:
          startDate = now;
      }

      final orderCollection = _firestoreHelper.getUserCollection('pastOrders');
      final querySnapshot = await orderCollection
          .where('closedAtDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .get();

      int totalOrderCount = 0;
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null && doc['billItems'] != null) {
          final closedAtDate = (data['closedAtDate'] as Timestamp).toDate();
          
          // Saat kontrolü
          if (startTime != null && endTime != null) {
            final orderHour = closedAtDate.hour;
            final orderMinute = closedAtDate.minute;
            
            if (orderHour < startTime.hour || 
                (orderHour == startTime.hour && orderMinute < startTime.minute) ||
                orderHour > endTime.hour ||
                (orderHour == endTime.hour && orderMinute > endTime.minute)) {
              continue;
            }
          }

          final billItems = data['billItems'] as List<dynamic>;
          totalOrderCount += billItems.length;
        }
      }

      state = state.copyWith(totalOrder: totalOrderCount);
    } catch (e) {
      _handleError(e, 'Toplam Sipariş Sayısı Yükleme Hatası');
    }
  }

  Future<void> fetchTotalCredit({required String period, TimeOfDay? startTime, TimeOfDay? endTime}) async {
    try {
      DateTime now = DateTime.now();
      DateTime startDate;

      switch (period) {
        case 'Günlük':
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case 'Haftalık':
          startDate = now.subtract(const Duration(days: 7));
          break;
        case 'Aylık':
          startDate = now.subtract(const Duration(days: 30));
          break;
        default:
          startDate = now;
      }

      final orderCollection = _firestoreHelper.getUserCollection('pastOrders');
      final querySnapshot = await orderCollection
          .where('closedAtDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .get();

      int totalCredit = 0;

      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null && data['billItems'] != null) {
          final closedAtDate = (data['closedAtDate'] as Timestamp).toDate();
          
          // Saat kontrolü
          if (startTime != null && endTime != null) {
            final orderHour = closedAtDate.hour;
            final orderMinute = closedAtDate.minute;
            
            if (orderHour < startTime.hour || 
                (orderHour == startTime.hour && orderMinute < startTime.minute) ||
                orderHour > endTime.hour ||
                (orderHour == endTime.hour && orderMinute > endTime.minute)) {
              continue;
            }
          }

          final billItems = data['billItems'] as List<dynamic>;
          for (var item in billItems) {
            if (item['isCredit'] == true) {
              totalCredit += (item['price'] as num).toInt();
            }
          }
        }
      }

      state = state.copyWith(totalCredit: totalCredit);
    } catch (e) {
      _handleError(e, 'Kredi kartı ile ödeme yapanların hasılatı hesaplanırken hata: $e');
    }
  }

  Future<void> fetchTotalCash({required String period, TimeOfDay? startTime, TimeOfDay? endTime}) async {
    try {
      DateTime now = DateTime.now();
      DateTime startDate;

      switch (period) {
        case 'Günlük':
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case 'Haftalık':
          startDate = now.subtract(const Duration(days: 7));
          break;
        case 'Aylık':
          startDate = now.subtract(const Duration(days: 30));
          break;
        default:
          startDate = now;
      }

      final orderCollection = _firestoreHelper.getUserCollection('pastOrders');
      final querySnapshot = await orderCollection
          .where('closedAtDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .get();

      int totalCash = 0;

      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null && data['billItems'] != null) {
          final closedAtDate = (data['closedAtDate'] as Timestamp).toDate();
          
          // Saat kontrolü
          if (startTime != null && endTime != null) {
            final orderHour = closedAtDate.hour;
            final orderMinute = closedAtDate.minute;
            
            if (orderHour < startTime.hour || 
                (orderHour == startTime.hour && orderMinute < startTime.minute) ||
                orderHour > endTime.hour ||
                (orderHour == endTime.hour && orderMinute > endTime.minute)) {
              continue;
            }
          }

          final billItems = data['billItems'] as List<dynamic>;
          for (var item in billItems) {
            if (item['isCredit'] == false) {
              totalCash += (item['price'] as num).toInt();
            }
          }
        }
      }

      state = state.copyWith(totalCash: totalCash);
    } catch (e) {
      _handleError(e, 'Nakit ödemeler hesaplanırken hata: $e');
    }
  }

  Future<void> fetchDailySales(String period, {TimeOfDay? startTime, TimeOfDay? endTime}) async {
    Map<String, int> dailySales = {
      "Pzt": 0,
      "Sal": 0,
      "Çrş": 0,
      "Prş": 0,
      "Cum": 0,
      "Cmt": 0,
      "Paz": 0,
    };

    DateTime now = DateTime.now();
    DateTime startDate =
        now.subtract(Duration(days: now.weekday - 1)); // Haftanın başlangıcı

    final orderCollection = _firestoreHelper.getUserCollection('pastOrders');
    final querySnapshot = await orderCollection
        .where('closedAtDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .get();

    for (var doc in querySnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final closedAtDate = (data['closedAtDate'] as Timestamp).toDate();
      
      // Saat kontrolü
      if (startTime != null && endTime != null) {
        final orderHour = closedAtDate.hour;
        final orderMinute = closedAtDate.minute;
        
        // Sipariş saati, belirlenen aralığın dışındaysa atla
        if (orderHour < startTime.hour || 
            (orderHour == startTime.hour && orderMinute < startTime.minute) ||
            orderHour > endTime.hour ||
            (orderHour == endTime.hour && orderMinute > endTime.minute)) {
          continue;
        }
      }

      String dayName;
      switch (closedAtDate.weekday) {
        case 1:
          dayName = "Pzt";
          break;
        case 2:
          dayName = "Sal";
          break;
        case 3:
          dayName = "Çrş";
          break;
        case 4:
          dayName = "Prş";
          break;
        case 5:
          dayName = "Cum";
          break;
        case 6:
          dayName = "Cmt";
          break;
        case 7:
          dayName = "Paz";
          break;
        default:
          continue;
      }

      if (data['totalPrice'] != null) {
        dailySales[dayName] = (dailySales[dayName] ?? 0) + (data['totalPrice'] as num).toInt();
      }
    }

    state = state.copyWith(dailySales: dailySales);
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return "Pazartesi";
      case 2:
        return "Salı";
      case 3:
        return "Çarşamba";
      case 4:
        return "Perşembe";
      case 5:
        return "Cuma";
      case 6:
        return "Cumartesi";
      case 7:
        return "Pazar";
      default:
        return "";
    }
  }

  Future<String?> getCurrentUserCafeId() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
            .instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          String? userType = userDoc.data()?['userType'];
          if (userType == 'kafe') {
            return currentUser.uid; // Kafe ID olarak UID'yi döndürüyoruz
          } else if (userType == 'çalışan') {
            return userDoc.data()?['cafeId']; // Çalışanın kafe ID'si
          } else {
            print("Kullanıcı tipi bilinmiyor: $userType");
          }
        } else {
          print("Kullanıcı bulunamadı");
        }
      } else {
        print("Oturum açmış kullanıcı yok");
      }
    } catch (e) {
      print('Kafe ID getirme hatası: $e');
    }
    return null; // Eğer bir kafe bulunamazsa null döndür
  }

  Future<void> fetchEmployees() async {
    try {
      final orderCollection = _firestoreHelper.getUserCollection('users');
      final querySnapshot = await orderCollection.get();

      // Çalışanları liste olarak döndür
      final employeesList = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      print(employeesList);
      // State'i güncelle
      state = state.copyWith(employees: employeesList);
      // print('Çekilen çalışanlar: $employeesList');
    } catch (e) {
      print('Çalışanları getirme hatası: $e');
      throw e;
    }
  }

  // Future<Map<String, int>> fetchDailySales(String period) async {
  //   Map<String, int> dailySales =
  //       {}; // Tarih bazında satış miktarlarını tutmak için bir harita
  //   DateTime now = DateTime.now();
  //   DateTime startDate;

  //   switch (period) {
  //     case 'Günlük':
  //       startDate = DateTime(now.year, now.month, now.day);
  //       break;
  //     case 'Haftalık':
  //       startDate = now.subtract(Duration(days: now.weekday - 1));
  //       break;
  //     case 'Aylık':
  //       startDate = DateTime(now.year, now.month, now.day - 30);

  //       break;
  //     default:
  //       startDate = now;
  //   }

  //   final orderCollection = _firestoreHelper.getUserCollection('pastOrders');
  //   final querySnapshot = await orderCollection
  //       .where('closedAtDate',
  //           isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
  //       .get();

  //   for (var doc in querySnapshot.docs) {
  //     final data = doc.data() as Map<String, dynamic>?;

  //     if (data != null &&
  //         data['totalPrice'] != null &&
  //         data['closedAtDate'] != null) {
  //       DateTime closedAtDate = (data['closedAtDate'] as Timestamp).toDate();
  //       String dayKey =
  //           "${closedAtDate.year}-${closedAtDate.month}-${closedAtDate.day}";

  //       dailySales[dayKey] =
  //           (dailySales[dayKey] ?? 0) + (data['totalPrice'] as int);
  //     }
  //   }

  //   return dailySales;
  // }

  Future<void> fetchAndLoad(String period, {TimeOfDay? startTime, TimeOfDay? endTime}) async {
    try {
      ref.read(loadingProvider.notifier).setLoading(true);
      await Future.wait([
        fetchDeliveredRevenues(period: period, startTime: startTime, endTime: endTime),
        fetchTotalOrder(period: period, startTime: startTime, endTime: endTime),
        fetchTotalCredit(period: period, startTime: startTime, endTime: endTime),
        fetchTotalCash(period: period, startTime: startTime, endTime: endTime),
        fetchDailySales(period, startTime: startTime, endTime: endTime),
      ]);
    } catch (e) {
      _handleError(e, 'Veriler yüklenirken hata oluştu');
    } finally {
      ref.read(loadingProvider.notifier).setLoading(false);
    }
  }

  /// Hata yönetimi
  void _handleError(Object e, String message) {
    print(
        '$message: $e'); // Hataları loglayın veya bir hata yönetimi mekanizması kullanın
  }

  Future<void> createEmployee({
    required String name,
    required String position,
    required String profileImage,
    required String cafeId, // Kafe ID'si ilişkisi için eklendi
  }) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .collection('users')
            .add({
          'name': name,
          'position': position,
          'profileImage': profileImage,
          'cafeId': cafeId, // Kafe ile ilişkilendirme
          'userType': 'çalışan',
        });
        await fetchEmployees();
      }
    } on FirebaseAuthException catch (e) {
      print('Error: ${e.message}');
      throw e;
    }
  }

  Future<void> updateEmployee(
      String userId, Userr.User updatedUser, BuildContext context) async {
    try {
      final productDocument = _firestoreHelper.getUserDocument('users', userId);
      await productDocument.update(updatedUser.toJson());
      await fetchEmployees();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ürün başarıyla güncellendi')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        _handleError(e, 'Ürünü güncelleme hatası');
      }
    }
  }

  // Future<void> createEmployee({
  //   required String email,
  //   required String password,
  //   required String name,
  //   required String position,
  //   required String profileImage,
  //   required String cafeId, // Kafe ID'si ilişkisi için eklendi
  // }) async {
  //   // TODO: on idTokenChanged sign out and sign in
  //   try {
  //     // Kullanıcıyı Firebase Authentication'a ekle
  //     UserCredential userCredential =
  //         await _auth.createUserWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );

  //     // Kullanıcı Auth ile başarıyla oluşturulursa, Firestore'a kaydet
  //     await _firestore.collection('users').doc(userCredential.user!.uid).set({
  //       'name': name,
  //       'position': position,
  //       'email': email,
  //       'profileImage': profileImage,
  //       'cafeId': cafeId, // Kafe ile ilişkilendirme
  //       'userType': 'çalışan',
  //     });
  //   } on FirebaseAuthException catch (e) {
  //     print('Error: ${e.message}');
  //     throw e;
  //   }
  // }
}

class ReportsState extends Equatable {
  const ReportsState({
    this.totalOrder,
    this.totalRevenues,
    this.totalProduct,
    this.totalCredit,
    this.totalCash,
    this.dailySales = const {},
    this.employees = const [], // Çalışanlar listesi
  });

  final int? totalOrder;
  final int? totalRevenues;
  final int? totalProduct;
  final int? totalCredit;
  final int? totalCash;
  final Map<String, int> dailySales;
  final List<Map<String, dynamic>> employees;

  @override
  List<Object?> get props => [
        totalOrder,
        totalRevenues,
        totalProduct,
        employees,
        dailySales,
        totalCredit,
        totalCash
      ];

  ReportsState copyWith({
    int? totalOrder,
    int? totalRevenues,
    int? totalProduct,
    int? totalCredit,
    int? totalCash,
    Map<String, int>? dailySales,
    List<Map<String, dynamic>>? employees,
  }) {
    return ReportsState(
        totalOrder: totalOrder ?? this.totalOrder,
        totalRevenues: totalRevenues ?? this.totalRevenues,
        totalProduct: totalProduct ?? this.totalProduct,
        dailySales: dailySales ?? this.dailySales,
        employees: employees ?? this.employees,
        totalCredit: totalCredit ?? this.totalCredit,
        totalCash: totalCash ?? this.totalCash);
  }
}
