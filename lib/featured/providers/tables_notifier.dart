import 'dart:async';
import 'dart:convert';
import 'package:altmisdokuzapp/featured/providers/admin_notifier.dart';
import 'package:altmisdokuzapp/featured/providers/loading_notifier.dart';
import 'package:altmisdokuzapp/product/model/area.dart';
import 'package:altmisdokuzapp/product/model/category.dart';
import 'package:altmisdokuzapp/product/model/menu.dart';
import 'package:altmisdokuzapp/product/model/table.dart';
import 'package:altmisdokuzapp/product/utility/firebase/firestore_helper.dart';
import 'package:altmisdokuzapp/product/utility/firebase/user_firestore_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:altmisdokuzapp/product/model/order.dart' as app;
import 'package:uuid/uuid.dart';

final _adminProvider = StateNotifierProvider<AdminNotifier, HomeState>((ref) {
  return AdminNotifier(ref);
});

final _tablesProvider =
    StateNotifierProvider<TablesNotifier, TablesState>((ref) {
  return TablesNotifier(ref);
});

class TablesNotifier extends StateNotifier<TablesState> {
  static const String allCategories = 'Tüm Kategoriler';
  static const String allTables = 'Masalar';
  final UserFirestoreHelper _userHelper = UserFirestoreHelper();
  final Ref ref; // Ref instance to manage the global provider
  final uuid = const Uuid();
  StreamSubscription? _orderSubscription;
  bool isLoading = false;
  final FirestoreHelper _firestoreHelper = FirestoreHelper();

  TablesNotifier(this.ref) : super(const TablesState());

  @override
  void dispose() {
    _orderSubscription?.cancel(); // Firestore dinleyicisini iptal et
    super.dispose(); // StateNotifier'ın dispose metodunu çağır
  }

  /// Masaları (tables) Firebase'den getirir.
  Future<void> fetchTablesBasedOnUserType() async {
    try {
      final userDetails = await _userHelper.getCurrentUserDetails();
      final tables = await _firestoreHelper.fetchCollection(
        _getPathForUser(userDetails, 'tables'),
        (data) => CoffeTable.fromJson(data),
      );

      tables.sort((a, b) =>
          int.tryParse(a.tableId!.split(' ').last)?.compareTo(
            int.tryParse(b.tableId!.split(' ').last) ?? 0,
          ) ??
          0);

      state = state.copyWith(tables: tables);
    } catch (e) {
      _handleError(e, 'Masaları getirirken hata oluştu');
    }
  }

  Future<void> fetchArea() async {
    try {
      // Kullanıcı bilgilerini al
      final userDetails = await _userHelper.getCurrentUserDetails();
      final areaQuery = _getAreaQuery(userDetails);

      // Firestore'dan alanları getir
      final response = await areaQuery.get();
      final areas = response.docs.map((e) => e.data()).toList();

      // State'i güncelle
      state = state.copyWith(areas: areas);
    } catch (e) {
      _handleError(e, 'Bölgeleri getirme hatası');
    }
  }

  /// Kullanıcı tipine göre `areas` sorgusunu döner
  Query<Area> _getAreaQuery(Map<String, dynamic>? userDetails) {
    final String? cafeId = userDetails?['cafeId'];
    final String userType = userDetails?['userType'] ?? '';

    if (userType == 'kafe') {
      // Kafe kullanıcısı için kendi koleksiyonunu döner
      return FirebaseFirestore.instance
          .collection('users')
          .doc(_userHelper.currentUser!.uid)
          .collection('areas')
          .withConverter<Area>(
            fromFirestore: (snapshot, options) =>
                Area.fromJson(snapshot.data()!),
            toFirestore: (value, options) => value.toJson(),
          );
    } else if (userType == 'çalışan' && cafeId != null) {
      // Çalışan kullanıcı için bağlı olduğu kafe koleksiyonunu döner
      return FirebaseFirestore.instance
          .collection('users')
          .doc(cafeId)
          .collection('areas')
          .withConverter<Area>(
            fromFirestore: (snapshot, options) =>
                Area.fromJson(snapshot.data()!),
            toFirestore: (value, options) => value.toJson(),
          );
    } else {
      throw Exception('Yetkisiz kullanıcı');
    }
  }

  Future<void> fetchTableBill(String tableId) async {
    try {
      final userDetails = await _userHelper.getCurrentUserDetails();
      final String userType = userDetails?['userType'] ?? '';
      final String? cafeId = userDetails?['cafeId'];
      late DocumentReference billDocument;

      if (userType == 'kafe') {
        // 'bills' koleksiyonundaki ilgili masanın adisyonunu çekiyoruz
        billDocument = _userHelper.getUserDocument('bills', tableId.toString());
      } else if (userType == 'çalışan' && cafeId != null) {
        billDocument = FirebaseFirestore.instance
            .collection('users')
            .doc(cafeId)
            .collection('bills')
            .doc(tableId);
      } else {
        throw Exception('Geçersiz kullanıcı tipi');
      }

      final doc = await billDocument.get();
      List<Menu> currentBillItems = [];
      if (doc.exists) {
        // Eğer belge varsa, mevcut adisyon öğelerini alıyoruz
        final data = doc.data() as Map<String, dynamic>;
        currentBillItems = (data['billItems'] as List<dynamic>)
            .map((item) => Menu.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      // State'i güncelliyoruz
      state = state.copyWith(
        tableBills: {
          ...state.tableBills,
          tableId: currentBillItems,
        },
      );
    } catch (e) {
      _handleError(e, 'Adisyon verilerini getirme hatası');
    }
  }

  Future<void> fetchAndLoad() async {
    ref.read(loadingProvider.notifier).setLoading(true); // isLoading set
    try {
      await Future.wait([
        fetchTablesBasedOnUserType(),
        fetchArea(),
      ]);
    } catch (e) {
      _handleError(e, 'Veri yükleme hatası');
    } finally {
      ref.read(loadingProvider.notifier).setLoading(false); // isLoading set
    }
  }

  String _getPathForUser(Map<String, dynamic>? userDetails, String collection) {
    if (userDetails?['userType'] == 'kafe') {
      return 'users/${_userHelper.currentUser!.uid}/$collection';
    } else if (userDetails?['userType'] == 'çalışan' &&
        userDetails?['cafeId'] != null) {
      return 'users/${userDetails!['cafeId']}/$collection';
    } else {
      throw Exception('Yetkisiz kullanıcı');
    }
  }

  Future<bool> addTable(CoffeTable table) async {
    try {
      final tableCollection = _userHelper.getUserCollection('tables');

      // Aynı ID'ye sahip bir masa var mı kontrol et
      final querySnapshot = await tableCollection
          .where('tableId', isEqualTo: table.tableId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Aynı ID’ye sahip masa varsa `false` döndür
        return false;
      }

      // Masa ekle
      final docRef = await tableCollection.add(table.toJson());
      final newTableWithId = table.copyWith(id: docRef.id);
      state = state.copyWith(tables: [...?state.tables, newTableWithId]);
      return true; // Başarıyla eklenirse `true` döndür
    } catch (e) {
      _handleError(e, 'Masa ekleme hatası');
      return false;
    }
  }

  void selectArea(String? areaName) {
    state = state.copyWith(selectedValue: areaName);
  }

  /// Hesaba ürün ekleme işlemi
  /// Hesaba ürün ekleme işlemi
  Future<void> addItemToBill(String tableId, Menu item) async {
    state = state.copyWith(isLoading: true);

    try {
      // Kullanıcı bilgilerini al
      final userDetails = await _userHelper.getCurrentUserDetails();

      // Firestore'da hedef belgeyi al
      final billDocument = _getBillDocument(userDetails, tableId);

      // Mevcut adisyonu getir
      final currentBillItems = await _fetchCurrentBillItems(billDocument);

      // Yeni item'e benzersiz bir ID ekle
      final newItem = item.copyWith(id: _generateUniqueId());
      currentBillItems.add(newItem.toJson());

      // Firestore'da güncelle
      await _updateBillDocument(billDocument, tableId, currentBillItems);

      // State'i güncelle
      _updateStateWithBillItems(tableId, currentBillItems);

      print('Ürün başarıyla hesaba eklendi: ${item.title}');
    } catch (e) {
      _handleError(e, 'Hesaba ürün ekleme hatası');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Kullanıcı bilgilerine göre Firestore belge referansı döndürür
  DocumentReference<Map<String, dynamic>> _getBillDocument(
      Map<String, dynamic>? userDetails, String tableId) {
    if (userDetails?['userType'] == 'kafe') {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(_userHelper.currentUser!.uid)
          .collection('bills')
          .doc(tableId);
    } else if (userDetails?['userType'] == 'çalışan' &&
        userDetails?['cafeId'] != null) {
      final cafeId = userDetails!['cafeId'];
      return FirebaseFirestore.instance
          .collection('users')
          .doc(cafeId)
          .collection('bills')
          .doc(tableId);
    } else {
      throw Exception('Yetkisiz kullanıcı');
    }
  }

  /// Mevcut adisyonu Firestore'dan getirir
  Future<List<Map<String, dynamic>>> _fetchCurrentBillItems(
      DocumentReference<Map<String, dynamic>> billDocument) async {
    final doc = await billDocument.get();

    if (!doc.exists) return [];
    final data = doc.data() as Map<String, dynamic>;
    return (data['billItems'] as List<dynamic>)
        .cast<Map<String, dynamic>>(); // Adisyon öğelerini döndür
  }

  /// Benzersiz bir ID oluşturur
  String _generateUniqueId() {
    return uuid.v4();
  }

  /// Firestore belgeyi günceller
  Future<void> _updateBillDocument(
      DocumentReference<Map<String, dynamic>> billDocument,
      String tableId,
      List<Map<String, dynamic>> billItems) async {
    await billDocument.set({
      'tableId': tableId,
      'billItems': billItems,
    });
  }

  /// State'i günceller
  void _updateStateWithBillItems(
      String tableId, List<Map<String, dynamic>> billItems) {
    state = state.copyWith(tableBills: {
      ...state.tableBills,
      tableId: billItems.map((item) => Menu.fromJson(item)).toList(),
    });
  }

  /// Hesaptan ürün çıkarma işlemi
  Future<void> removeItemFromBill(String tableId, String itemId) async {
    state = state.copyWith(isLoading: true);
    try {
      final billDocument =
          _userHelper.getUserDocument('bills', tableId.toString());
      final doc = await billDocument.get();

      List<Map<String, dynamic>> currentBillItems = [];
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        currentBillItems =
            (data['billItems'] as List<dynamic>).cast<Map<String, dynamic>>();
      }

      // itemId üzerinden silme işlemi gerçekleştiriyoruz
      currentBillItems.removeWhere((menuItem) => menuItem['id'] == itemId);

      await billDocument.set({
        'tableId': tableId,
        'billItems': currentBillItems,
      });

      // State'i güncelliyoruz
      state = state.copyWith(tableBills: {
        ...state.tableBills,
        tableId: currentBillItems.map((item) => Menu.fromJson(item)).toList(),
      });

      print('Öğe başarıyla silindi: $itemId');
    } catch (e) {
      print('Hesaptan ürün silme hatası: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<String> generateQRCode(String tableId) async {
    try {
      // Kullanıcı detaylarını al
      final userDetails = await _userHelper.getCurrentUserDetails();

      String businessId;

      if (userDetails?['userType'] == 'kafe') {
        // Eğer kullanıcı türü 'kafe' ise kendi UID'sini kullan
        businessId = FirebaseAuth.instance.currentUser!.uid;
      } else if (userDetails?['userType'] == 'çalışan' &&
          userDetails?['cafeId'] != null) {
        // Eğer kullanıcı türü 'çalışan' ise cafeId'yi kullan
        businessId = userDetails!['cafeId'];
      } else {
        throw Exception('Yetkisiz kullanıcı');
      }

      // businessId ve tableId'yi şifreliyoruz
      final String token =
          base64Encode(utf8.encode('businessId:$businessId,tableId:$tableId'));

      final Uri menuUrl = Uri(
        scheme: 'http',
        host: 'foomoons.com', // veya IP adresi
        path: '/menu/', // API'nin path kısmı
      );
      final String finalUrl = '$menuUrl#/table?token=$token';
      print(finalUrl);

      return finalUrl;
    } catch (e) {
      print('QR kod oluşturma hatası: $e');
      rethrow;
    }
  }

  /// Yeni bir bölgeyi Firebase'e eklemek için fonksiyon
  Future<void> addAreaToFirebase(String areaName) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Kullanıcı oturum açmamış');
      }

      // Mevcut kullanıcının `tables` koleksiyonuna ulaş
      final tablesCollection = _userHelper.getUserCollection('areas');

      // `areas` adında bir alt koleksiyon oluştur ve yeni bölgeyi ekle
      await tablesCollection.add({'name': areaName});
      fetchArea();

      print('Yeni bölge Firebase\'e başarıyla eklendi: $areaName');
    } catch (e) {
      print('Bölge ekleme hatası: $e');
    }
  }

  /// Bill öğesinin `status` alanını günceller
  Future<void> updateBillItemStatus(String tableId, Menu updatedItem) async {
    try {
      // Kullanıcı bilgilerini al ve Firestore belge referansını al
      final userDetails = await _userHelper.getCurrentUserDetails();
      final billDocument = _getBillDocument(userDetails, tableId);

      // Mevcut adisyon öğelerini getir
      final currentBillItems = await _fetchCurrentBillItems(billDocument);

      // Güncellenen öğeyi liste içinde değiştir
      final updatedBillItems = _updateItemInList(currentBillItems, updatedItem);

      // Firestore'da güncellenmiş öğeleri kaydet
      await _updateBillDocument(billDocument, tableId, updatedBillItems);

      // State'i güncelle
      _updateStateWithBillItems(tableId, updatedBillItems);

      print(
          'Öğe güncellendi: ${updatedItem.title}, Status: ${updatedItem.status}');
    } catch (e) {
      print('Hesap öğesi güncellenirken hata oluştu: $e');
    }
  }

  /// Liste içindeki bir öğeyi günceller
  List<Map<String, dynamic>> _updateItemInList(
      List<Map<String, dynamic>> currentBillItems, Menu updatedItem) {
    return currentBillItems.map((item) {
      if (item['id'] == updatedItem.id) {
        return updatedItem.toJson(); // Güncellenmiş öğeyi döndür
      }
      return item; // Diğer öğeleri olduğu gibi döndür
    }).toList();
  }

  Future<bool> hesabiKapat(String tableId) async {
    ref.read(loadingProvider.notifier).setLoading(true);
    try {
      // Kullanıcı bilgilerini al
      final userDetails = await _userHelper.getCurrentUserDetails();

      // Firestore referanslarını al
      final billDocument = _getBillDocument(userDetails, tableId);
      final pastOrdersCollection = _getPastOrdersCollection(userDetails);

      // Mevcut adisyon öğelerini al
      final currentBillItems = await _fetchBillItems(billDocument);

      if (currentBillItems.isEmpty) {
        return false; // Eğer adisyon boşsa işlemi durdur
      }

      // Hesap bilgilerini geçmiş siparişlere taşı
      await _moveToPastOrders(
        pastOrdersCollection,
        tableId,
        currentBillItems,
      );

      // 'bills' koleksiyonundan masayı sil
      await _deleteBill(billDocument);

      // State güncelle
      _updateStateAfterBillClose(tableId);

      print('Hesap başarıyla kapatıldı ve geçmiş siparişlere taşındı.');
      return true;
    } catch (e) {
      print('Hesap kapatma hatası: $e');
      return false;
    } finally {
      ref.read(loadingProvider.notifier).setLoading(false);
    }
  }

  /// Belirtilen adisyon belgesini sil
  Future<void> _deleteBill(
      DocumentReference<Map<String, dynamic>> billDocument) async {
    await billDocument.delete();
  }

  /// State güncellemesi
  void _updateStateAfterBillClose(String tableId) {
    state = state.copyWith(
      tableBills: {...state.tableBills}..remove(tableId),
    );
  }

  /// Hesap öğelerini geçmiş siparişlere taşı
  Future<void> _moveToPastOrders(
      CollectionReference<Map<String, dynamic>> pastOrdersCollection,
      String tableId,
      List<Menu> billItems) async {
    final String uniqueId = uuid.v4();
    final totalPrice = billItems.fold<double>(
      0.0,
      (sum, item) => sum + (item.price ?? 0),
    );

    await pastOrdersCollection.doc(uniqueId).set({
      'tableId': tableId,
      'billItems': billItems.map((item) => item.toJson()).toList(),
      'closedAtDate': Timestamp.fromDate(DateTime.now()),
      'uniqueId': uniqueId,
      'totalPrice': totalPrice,
    });
  }

  /// Belirtilen belgeden adisyon öğelerini getir
  Future<List<Menu>> _fetchBillItems(
      DocumentReference<Map<String, dynamic>> billDocument) async {
    final doc = await billDocument.get();
    if (!doc.exists) {
      return [];
    }

    final data = doc.data() as Map<String, dynamic>;
    return (data['billItems'] as List<dynamic>)
        .map((item) => Menu.fromJson(item as Map<String, dynamic>))
        .where((item) => item.status == 'ödendi') // Sadece 'ödendi' olanları al
        .toList();
  }

  /// Kullanıcı bilgilerine göre 'pastOrders' referansını al
  CollectionReference<Map<String, dynamic>> _getPastOrdersCollection(
      Map<String, dynamic>? userDetails) {
    if (userDetails?['userType'] == 'kafe') {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(_userHelper.currentUser!.uid)
          .collection('pastOrders');
    } else if (userDetails?['userType'] == 'çalışan' &&
        userDetails?['cafeId'] != null) {
      final cafeId = userDetails!['cafeId'];
      return FirebaseFirestore.instance
          .collection('users')
          .doc(cafeId)
          .collection('pastOrders');
    } else {
      throw Exception('Yetkisiz kullanıcı');
    }
  }

  /// Hata yönetimi
  void _handleError(Object e, String message) {
    print(
        '$message: $e'); // Hataları loglayın veya bir hata yönetimi mekanizması kullanın
  }
}

class TablesState extends Equatable {
  const TablesState({
    this.menus,
    this.orders,
    this.categories,
    this.selectedValue,
    this.tables,
    this.tableBills = const {},
    this.isLoading = false,
    this.areas,
  });

  final List<app.Order>? orders;
  final List<Menu>? menus;
  final List<Category>? categories;
  final String? selectedValue;
  final List<CoffeTable>? tables;
  final Map<String, List<Menu>> tableBills;
  final bool isLoading;
  final List<Area>? areas;

  @override
  List<Object?> get props =>
      [orders, categories, selectedValue, tables, tableBills, menus, isLoading];

  TablesState copyWith(
      {List<app.Order>? orders,
      List<Menu>? menus,
      List<Category>? categories,
      String? selectedValue,
      List<CoffeTable>? tables,
      Map<String, List<Menu>>? tableBills,
      bool? isLoading,
      List<Area>? areas}) {
    return TablesState(
      orders: orders ?? this.orders,
      menus: menus ?? this.menus,
      categories: categories ?? this.categories,
      selectedValue: selectedValue ?? this.selectedValue,
      tables: tables ?? this.tables,
      tableBills: tableBills ?? this.tableBills,
      isLoading: isLoading ?? this.isLoading,
      areas: areas ?? this.areas,
    );
  }

  List<Menu> getTableBill(String tableId) {
    return tableBills[tableId] ?? [];
  }
}
