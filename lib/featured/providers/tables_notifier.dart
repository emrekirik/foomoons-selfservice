import 'dart:async';
import 'dart:convert';
import 'package:altmisdokuzapp/featured/providers/admin_notifier.dart';
import 'package:altmisdokuzapp/featured/providers/loading_notifier.dart';
import 'package:altmisdokuzapp/product/model/area.dart';
import 'package:altmisdokuzapp/product/model/category.dart';
import 'package:altmisdokuzapp/product/model/menu.dart';
import 'package:altmisdokuzapp/product/model/table.dart';
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
  final UserFirestoreHelper _firestoreHelper = UserFirestoreHelper();
  final Ref ref; // Ref instance to manage the global provider
  final uuid = const Uuid();
  bool _isFirstLoad = true;
  StreamSubscription? _orderSubscription;
  List<app.Order> _previousOrders = [];
  bool isLoading = false;

  TablesNotifier(this.ref) : super(const TablesState());

  @override
  void dispose() {
    _orderSubscription?.cancel(); // Firestore dinleyicisini iptal et
    super.dispose(); // StateNotifier'ın dispose metodunu çağır
  }

  /// Masaları (tables) Firebase'den getirir.
  Future<void> fetchTable() async {
    try {
      final tableCollection = _firestoreHelper.getUserCollection('tables');
      final response = await tableCollection
          .withConverter<CoffeTable>(
            fromFirestore: (snapshot, options) =>
                CoffeTable.fromJson(snapshot.data()!),
            toFirestore: (value, options) => value.toJson(),
          )
          .get();

      final tables = response.docs.map((e) => e.data()).toList();
      tables.sort((a, b) =>
          a.tableId!.compareTo(b.tableId!)); // TableId'ye göre sıralama

      state = state.copyWith(tables: tables);
    } catch (e) {
      _handleError(e, 'Masaları getirme hatası');
    }
  }

  Future<void> fetchArea() async {
    try {
      final areaCollection = _firestoreHelper.getUserCollection('areas');
      final response = await areaCollection
          .withConverter<Area>(
            fromFirestore: (snapshot, options) =>
                Area.fromJson(snapshot.data()!),
            toFirestore: (value, options) => value.toJson(),
          )
          .get();
      final areas = response.docs.map((e) => e.data()).toList();
      state = state.copyWith(areas: areas);
    } catch (e) {}
  }

  /// Kullanıcıya özel sipariş akışını takip eder
  void fetchOrdersStream() {
    final currentUser =
        _firestoreHelper.currentUser; // Oturum açmış kullanıcıyı kontrol et
    if (currentUser == null) {
      print('No authenticated user'); // Kullanıcı oturumu yoksa işlemi durdur
      return;
    }

    final orderCollectionReference =
        _firestoreHelper.getUserCollection('orders');

    _orderSubscription =
        orderCollectionReference.snapshots().listen((snapshot) {
      final values = snapshot.docs.map((doc) {
        return const app.Order()
            .fromFirebase(doc as DocumentSnapshot<Map<String, dynamic>>);
      }).toList();

      if (!_isFirstLoad) {
        if (values.length > _previousOrders.length) {}
      } else {
        _isFirstLoad = false;
      }

      _previousOrders = values;
      state = state.copyWith(orders: values);

      // startCentralCountdown();
    });
  }

  Future<void> fetchTableBill(String tableId) async {
    try {
      // 'bills' koleksiyonundaki ilgili masanın adisyonunu çekiyoruz
      final billDocument =
          _firestoreHelper.getUserDocument('bills', tableId.toString());
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
        fetchTable(),
        fetchArea(),
      ]);
    } catch (e) {
      _handleError(e, 'Veri yükleme hatası');
    } finally {
      ref.read(loadingProvider.notifier).setLoading(false); // isLoading set
    }
  }

  Future<bool> addTable(CoffeTable table) async {
    try {
      final tableCollection = _firestoreHelper.getUserCollection('tables');

      // Aynı ID'ye sahip bir masa var mı kontrol et
      final querySnapshot =
          await tableCollection.where('tableId', isEqualTo: table.tableId).get();

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
  Future<void> addItemToBill(String tableId, Menu item) async {
    state = state.copyWith(isLoading: true);
    try {
      final billDocument =
          _firestoreHelper.getUserDocument('bills', tableId.toString());
      final doc = await billDocument.get();

      List<Map<String, dynamic>> currentBillItems = [];
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        currentBillItems =
            (data['billItems'] as List<dynamic>).cast<Map<String, dynamic>>();
      }

      // Yeni item'e benzersiz bir itemId ekliyoruz
      final newItem = item.copyWith(id: uuid.v4());

      currentBillItems.add(newItem.toJson()); // Yeni item'i ekliyoruz

      await billDocument.set({
        'tableId': tableId,
        'billItems': currentBillItems,
      });

      // State'i güncelliyoruz
      state = state.copyWith(tableBills: {
        ...state.tableBills,
        tableId: currentBillItems.map((item) => Menu.fromJson(item)).toList(),
      });
      await fetchTableBill(tableId);
    } catch (e) {
      _handleError(e, 'Hesaba ürün ekleme hatası');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Hesaptan ürün çıkarma işlemi
  Future<void> removeItemFromBill(String tableId, String itemId) async {
    state = state.copyWith(isLoading: true);
    try {
      final billDocument =
          _firestoreHelper.getUserDocument('bills', tableId.toString());
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

  String generateQRCode(String tableId) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception(
          'No authenticated user'); // Eğer oturum açmış kullanıcı yoksa hata ver
    }

    final String businessId = user.uid;

    // businessId ve tableId'yi şifreliyoruz
    final String token =
        base64Encode(utf8.encode('businessId:$businessId,tableId:$tableId'));

    final Uri menuUrl = Uri(
      scheme: 'http',
      host: 'foomoons.com', // veya IP adresi
      path: '/menu/', // yerel sunucunuzun port numarası
    );
    final String finalUrl = '$menuUrl#/table?token=$token';
    print(finalUrl);
    return finalUrl;
  }

  /// Yeni bir bölgeyi Firebase'e eklemek için fonksiyon
  Future<void> addAreaToFirebase(String areaName) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Kullanıcı oturum açmamış');
      }

      // Mevcut kullanıcının `tables` koleksiyonuna ulaş
      final tablesCollection = _firestoreHelper.getUserCollection('areas');

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
      final billDocument =
          _firestoreHelper.getUserDocument('bills', tableId.toString());
      final doc = await billDocument.get();

      List<Map<String, dynamic>> currentBillItems = [];
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        currentBillItems =
            (data['billItems'] as List<dynamic>).cast<Map<String, dynamic>>();
      }

      // Güncellenen öğeyi eski listenin içinde bul ve değiştir.
      currentBillItems = currentBillItems.map((item) {
        if (item['id'] == updatedItem.id) {
          return updatedItem.toJson(); // Status güncellendiği yeni öğe
        }
        return item;
      }).toList();

      await billDocument.set({
        'tableId': tableId,
        'billItems': currentBillItems,
      });

      state = state.copyWith(tableBills: {
        ...state.tableBills,
        tableId: currentBillItems.map((item) => Menu.fromJson(item)).toList(),
      });

      print(
          'Öğe güncellendi: ${updatedItem.title}, Status: ${updatedItem.status}');
    } catch (e) {
      print('Hesap öğesi güncellenirken hata oluştu: $e');
    }
  }

  Future<bool> hesabiKapat(String tableId) async {
    ref.read(loadingProvider.notifier).setLoading(true); // isLoading set
    try {
      // 'bills' koleksiyonundaki belgeyi alıyoruz
      final billDocument = _firestoreHelper.getUserDocument('bills', tableId);
      final doc = await billDocument.get();

      if (!doc.exists)
        return false; // Eğer adisyon mevcut değilse işlemi durdur

      final data = doc.data() as Map<String, dynamic>;
      final currentBillItems = (data['billItems'] as List<dynamic>)
          .map((item) => Menu.fromJson(item as Map<String, dynamic>))
          .toList();

      // Tüm öğelerin `status` alanını kontrol et
      final areAllPaid =
          currentBillItems.every((item) => item.status == 'ödendi');

      if (areAllPaid) {
        // Benzersiz bir belge ID'si oluşturuyoruz
        final String uniqueId = uuid.v4();

        // Toplam tutarı hesapla
        final totalPrice = currentBillItems.fold<double>(
          0.0,
          (sum, item) =>
              sum + (item.price ?? 0), // Fiyat null ise 0 olarak ekle
        );

        // 'pastOrders' koleksiyonundaki ilgili belgeye referans oluşturuyoruz
        final pastOrdersDocument =
            _firestoreHelper.getUserDocument('pastOrders', uniqueId);

        // 'pastOrders' koleksiyonuna belge ekliyoruz
        await pastOrdersDocument.set({
          'tableId': tableId,
          'billItems': currentBillItems.map((item) => item.toJson()).toList(),
          'closedAtDate':
              Timestamp.fromDate(DateTime.now()), // Hesabı kapama tarihi
          'uniqueId': uniqueId, // Ekstra olarak belge ID'sini de kaydediyoruz
          'totalPrice': totalPrice, // Adisyonun toplam tutarını kaydediyoruz
        });

        // 'bills' koleksiyonundan bu masaya ait tüm adisyon öğelerini sil
        await billDocument.delete();

        // State güncellemesi
        state = state.copyWith(
          tableBills: {...state.tableBills}..remove(tableId),
        );

        print('Hesap başarıyla kapatıldı ve geçmiş siparişlere taşındı.');
        return true; // Başarılı işlemi bildir
      } else {
        print('Tüm öğeler henüz ödenmediği için hesap kapatılamaz.');
        return false; // Hesap kapatılamadı, işlemi bildir
      }
    } catch (e) {
      print('Hesap kapatma hatası: $e');
      return false; // Hata durumunda işlemi bildir
    } finally {
      ref.read(loadingProvider.notifier).setLoading(false); // isLoading set
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
