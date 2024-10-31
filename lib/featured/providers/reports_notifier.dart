import 'package:altmisdokuzapp/featured/providers/loading_notifier.dart';
import 'package:altmisdokuzapp/product/utility/firebase/user_firestore_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReportsNotifier extends StateNotifier<ReportsState> {
  static const String allCategories = 'Tüm Kategoriler';
  final UserFirestoreHelper _firestoreHelper = UserFirestoreHelper();
  final Ref ref; // Ref instance to manage the global provider
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ReportsNotifier(this.ref) : super(const ReportsState());

  Future<void> fetchDeliveredRevenues({required String period}) async {
    try {
      DateTime now = DateTime.now();
      DateTime startDate;

      switch (period) {
        case 'Günlük':
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case 'Haftalık':
          startDate = now.subtract(Duration(days: now.weekday - 1));
          break;
        case 'Aylık':
          startDate = DateTime(now.year, now.month, 1);
          break;
        default:
          startDate = now;
      }

      // 'orders' koleksiyonunu alıyoruz
      final orderCollection = _firestoreHelper.getUserCollection('pastOrders');

      // Sadece 'status' alanı 'teslim edildi' olan siparişleri alıyoruz
      final querySnapshot = await orderCollection
          .where('closedAtDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .get();

      // Toplam hasılatı başlatıyoruz
      int totalRevenues = 0;

      // Her bir siparişin 'price' alanını topluyoruz
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;

        // 'price' null değilse toplamaya ekliyoruz
        if (data != null && data['totalPrice'] != null) {
          final totalPrice = data['totalPrice'] as int;
          totalRevenues += totalPrice;
        }
      }

      // State'i güncelliyoruz, sadece 'totalRevenues' alanını değiştiriyoruz
      print(totalRevenues);
      state = state.copyWith(totalRevenues: totalRevenues);
    } catch (e) {
      _handleError(e,
          'Teslim edilen siparişlerin toplam hasılatı hesaplanırken hata: $e');
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

  Future<void> fetchTotalOrder({required String period}) async {
    try {
      DateTime now = DateTime.now();
      DateTime startDate;

      switch (period) {
        case 'Günlük':
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case 'Haftalık':
          startDate = now.subtract(Duration(days: now.weekday - 1));
          break;
        case 'Aylık':
          startDate = DateTime(now.year, now.month, 1);
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
          final billItems = data['billItems'] as List<dynamic>;
          totalOrderCount += billItems.length;
        }
      }

      state = state.copyWith(totalOrder: totalOrderCount);
    } catch (e) {
      _handleError(e, 'Toplam Sipariş Sayısı Yükleme Hatası');
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

  Future<List<Map<String, dynamic>>> fetchEmployeesForCafe(
      String cafeId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('cafeId', isEqualTo: cafeId)
          .where('userType', isEqualTo: 'çalışan')
          .get();

      // Çalışanları liste olarak döndür
      final employeesList =
          querySnapshot.docs.map((doc) => doc.data()).toList();

      // State'i güncelle
      state = state.copyWith(employees: employeesList);
      // print('Çekilen çalışanlar: $employeesList');
      return employeesList;
    } catch (e) {
      print('Çalışanları getirme hatası: $e');
      throw e;
    }
  }

  Future<Map<String, int>> fetchDailySales(String period) async {
    Map<String, int> dailySales =
        {}; // Tarih bazında satış miktarlarını tutmak için bir harita
    DateTime now = DateTime.now();
    DateTime startDate;

    switch (period) {
      case 'Günlük':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'Haftalık':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        break;
      case 'Aylık':
        startDate = DateTime(now.year, now.month, 1);
        break;
      default:
        startDate = now;
    }

    final orderCollection = _firestoreHelper.getUserCollection('pastOrders');
    final querySnapshot = await orderCollection
        .where('closedAtDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .get();

    for (var doc in querySnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data != null &&
          data['totalPrice'] != null &&
          data['closedAtDate'] != null) {
        DateTime closedAtDate = (data['closedAtDate'] as Timestamp).toDate();
        String dayKey =
            "${closedAtDate.year}-${closedAtDate.month}-${closedAtDate.day}";

        dailySales[dayKey] =
            (dailySales[dayKey] ?? 0) + (data['totalPrice'] as int);
      }
    }

    return dailySales;
  }

  Future<void> fetchAndLoad(String period) async {
    ref.read(loadingProvider.notifier).setLoading(true); // isLoading set
    try {
      // Mevcut kullanıcının kafe ID'sini alıyoruz
      String? cafeId = await getCurrentUserCafeId();

      if (cafeId != null) {
        final dailySalesData = await fetchDailySales(period);
        await Future.wait([
          fetchDeliveredRevenues(period: period),
          fetchTotalProduct(),
          fetchTotalOrder(period: period),
          fetchEmployeesForCafe(cafeId),
        ]);

        state = state.copyWith(dailySales: dailySalesData);
      } else {
        print('Kafe ID bulunamadı');
      }
    } catch (e) {
      _handleError(e, 'Veri yükleme hatası');
    } finally {
      ref.read(loadingProvider.notifier).setLoading(false); // isLoading set
    }
  }

  /// Hata yönetimi
  void _handleError(Object e, String message) {
    print(
        '$message: $e'); // Hataları loglayın veya bir hata yönetimi mekanizması kullanın
  }

  Future<void> createEmployee({
    required String email,
    required String password,
    required String name,
    required String position,
    required String profileImage,
    required String cafeId, // Kafe ID'si ilişkisi için eklendi
  }) async {
    // TODO: on idTokenChanged sign out and sign in
    try {
      // Kullanıcıyı Firebase Authentication'a ekle
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Kullanıcı Auth ile başarıyla oluşturulursa, Firestore'a kaydet
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'position': position,
        'email': email,
        'profileImage': profileImage,
        'cafeId': cafeId, // Kafe ile ilişkilendirme
        'userType': 'çalışan',
      });
    } on FirebaseAuthException catch (e) {
      print('Error: ${e.message}');
      throw e;
    }
  }
}

class ReportsState extends Equatable {
  const ReportsState({
    this.totalOrder,
    this.totalRevenues,
    this.totalProduct,
    this.dailySales = const {},
    this.employees = const [], // Çalışanlar listesi
  });

  final int? totalOrder;
  final int? totalRevenues;
  final int? totalProduct;
  final Map<String, int> dailySales;
  final List<Map<String, dynamic>> employees;

  @override
  List<Object?> get props =>
      [totalOrder, totalRevenues, totalProduct, employees, dailySales];

  ReportsState copyWith({
    int? totalOrder,
    int? totalRevenues,
    int? totalProduct,
    Map<String, int>? dailySales,
    List<Map<String, dynamic>>? employees,
  }) {
    return ReportsState(
      totalOrder: totalOrder ?? this.totalOrder,
      totalRevenues: totalRevenues ?? this.totalRevenues,
      totalProduct: totalProduct ?? this.totalProduct,
      dailySales: dailySales ?? this.dailySales,
      employees: employees ?? this.employees,
    );
  }
}
