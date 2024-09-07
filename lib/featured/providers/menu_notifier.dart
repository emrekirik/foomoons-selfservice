import 'dart:convert';
import 'package:altmisdokuzapp/product/model/category.dart';
import 'package:altmisdokuzapp/product/model/menu.dart';
import 'package:altmisdokuzapp/product/model/table.dart';
import 'package:altmisdokuzapp/product/utility/firebase/user_firestore_helper.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final menuProvider = StateNotifierProvider<MenuNotifier, MenuState>((ref) {
  return MenuNotifier();
});

class MenuNotifier extends StateNotifier<MenuState> {
  static const String allCategories = 'Tüm Kategoriler';
  final UserFirestoreHelper _firestoreHelper = UserFirestoreHelper();

  MenuNotifier() : super(const MenuState()) {
    // Veriler başlatılıyor
    fetchProducts();
    fetchCategories();
    fetchTable();
  }

  void resetState() {
    state = const MenuState(); // Reset to the initial state
  }

  /// Siparişleri (orders) Firebase'den getirir.
  Future<void> fetchProducts() async {
    try {
      final productCollection = _firestoreHelper.getUserCollection('products');
      final response = await productCollection
          .withConverter<Menu>(
            fromFirestore: (snapshot, options) {
              final menu = Menu.fromJson(snapshot.data()!);
              return menu.copyWith(id: snapshot.id); // ID ekleme
            },
            toFirestore: (value, options) => value.toJson(),
          )
          .get();

      final orders = response.docs.map((e) => e.data()).toList();
      state = state.copyWith(orders: orders);
    } catch (e) {
      _handleError(e, 'Siparişleri getirme hatası');
    }
  }

  /// Kategorileri (categories) Firebase'den getirir.
  Future<void> fetchCategories() async {
    try {
      final categoryCollection = _firestoreHelper.getUserCollection('categories');
      final response = await categoryCollection
          .withConverter<Category>(
            fromFirestore: (snapshot, options) => Category.fromJson(snapshot.data()!),
            toFirestore: (value, options) => value.toJson(),
          )
          .get();

      final categories = response.docs.map((e) => e.data()).toList();
      state = state.copyWith(categories: categories);
    } catch (e) {
      _handleError(e, 'Kategorileri getirme hatası');
    }
  }

  /// Masaları (tables) Firebase'den getirir.
  Future<void> fetchTable() async {
    try {
      final tableCollection = _firestoreHelper.getUserCollection('tables');
      final response = await tableCollection
          .withConverter<CoffeTable>(
            fromFirestore: (snapshot, options) => CoffeTable.fromJson(snapshot.data()!),
            toFirestore: (value, options) => value.toJson(),
          )
          .get();

      final tables = response.docs.map((e) => e.data()).toList();
      tables.sort((a, b) => a.tableId!.compareTo(b.tableId!)); // TableId'ye göre sıralama
      state = state.copyWith(tables: tables);
    } catch (e) {
      _handleError(e, 'Masaları getirme hatası');
    }
  }

  /// Kategori ekleme işlemi
  Future<void> addCategory(Category category) async {
    try {
      final categoryCollection = _firestoreHelper.getUserCollection('categories');
      final docRef = await categoryCollection.add(category.toJson());
      final newCategory = category.copyWith(id: docRef.id);
      state = state.copyWith(categories: [...?state.categories, newCategory]);
    } catch (e) {
      _handleError(e, 'Kategori Ekleme Hatası');
    }
  }

  /// Add Product (Menu) for the current user
  Future<void> addProduct(Menu newProduct) async {
    try {
      final productCollection = _firestoreHelper.getUserCollection('products');
      final docRef = await productCollection.add(newProduct.toJson());
      final newProductWithId = newProduct.copyWith(id: docRef.id);
      state = state.copyWith(orders: [...?state.orders, newProductWithId]);
    } catch (e) {
      _handleError(e, 'Ürün ekleme hatası');
    }
  }

  /// Masa ekleme işlemi
  Future<void> addTable(CoffeTable table) async {
    try {
      final tableCollection = _firestoreHelper.getUserCollection('tables');
      final docRef = await tableCollection.add(table.toJson());
      final newTableWithId = table.copyWith(id: docRef.id);
      state = state.copyWith(tables: [...?state.tables, newTableWithId]);
    } catch (e) {
      _handleError(e, 'Masa ekleme hatası');
    }
  }

  /// Hesaba ürün ekleme işlemi
  Future<void> addItemToBill(int tableId, Menu item) async {
    try {
      final billDocument = _firestoreHelper.getUserDocument('bills', tableId.toString());
      final doc = await billDocument.get();

      List<Menu> currentBillItems = [];
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        currentBillItems = (data['billItems'] as List<dynamic>)
            .map((item) => Menu.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      currentBillItems.add(item);
      await billDocument.set({
        'tableId': tableId,
        'billItems': currentBillItems.map((item) => item.toJson()).toList(),
      });

      state = state.copyWith(tableBills: {
        ...state.tableBills,
        tableId: currentBillItems,
      });
    } catch (e) {
      _handleError(e, 'Hesaba ürün ekleme hatası');
    }
  }

  /// Ürün güncelleme işlemi
  Future<void> updateProduct(String productId, Menu updatedMenu, BuildContext context) async {
    try {
      final productDocument = _firestoreHelper.getUserDocument('products', productId);
      await productDocument.update(updatedMenu.toJson());
      await fetchProducts(); // Siparişleri güncelle

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

  /// Ürün silme işlemi
  Future<void> deleteProduct(String productId, BuildContext context) async {
    try {
      final productDocument = _firestoreHelper.getUserDocument('products', productId);
      await productDocument.delete();
      await fetchProducts(); // Sipariş listesini güncelle

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ürün başarıyla silindi')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        _handleError(e, 'Ürünü silme hatası');
      }
    }
  }

  /// Hesaptan ürün çıkarma işlemi
  Future<void> removeItemFromBill(int tableId, Menu item) async {
    try {
      final billDocument = _firestoreHelper.getUserDocument('bills', tableId.toString());
      final doc = await billDocument.get();

      List<Menu> currentBillItems = [];
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        currentBillItems = (data['billItems'] as List<dynamic>)
            .map((item) => Menu.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      currentBillItems.remove(item);
      await billDocument.set({
        'tableId': tableId,
        'billItems': currentBillItems.map((item) => item.toJson()).toList(),
      });

      state = state.copyWith(tableBills: {
        ...state.tableBills,
        tableId: currentBillItems,
      });
    } catch (e) {
      _handleError(e, 'Hesaptan ürün çıkarma hatası');
    }
  }

  /// Belirli bir masanın adisyonunu getirir
  Future<void> fetchTableBill(int tableId) async {
    try {
      final billDocument = _firestoreHelper.getUserDocument('bills', tableId.toString());
      final doc = await billDocument.get();

      List<Menu> currentBillItems = [];
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        currentBillItems = (data['billItems'] as List<dynamic>)
            .map((item) => Menu.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      state = state.copyWith(tableBills: {
        ...state.tableBills,
        tableId: currentBillItems,
      });
    } catch (e) {
      _handleError(e, 'Adisyonu getirme hatası');
    }
  }

  String generateQRCode(int tableId) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('No authenticated user'); // Eğer oturum açmış kullanıcı yoksa hata ver
    }

    final String businessId = user.uid;

    // businessId ve tableId'yi şifreliyoruz
    final String token = base64Encode(utf8.encode('businessId:$businessId,tableId:$tableId'));

    final Uri menuUrl = Uri(
      scheme: 'http',
      host: '192.168.1.135', // veya IP adresi
      port: 8080, // yerel sunucunuzun port numarası
    );
    final String finalUrl = menuUrl.toString() + '#/table?token=$token';
    return finalUrl;
  }

  Menu? getProductById(String productId) {
    return state.orders?.firstWhere(
      (menu) => menu.id == productId,
      orElse: () => Menu(), // Return a default `Menu` object instead of `null`
    );
  }

  /// Seçili kategoriyi günceller
  void selectCategory(String? categoryName) {
    state = state.copyWith(selectedValue: categoryName);
  }

  /// Hata yönetimi
  void _handleError(Object e, String message) {
    print('$message: $e'); // Hataları loglayın veya bir hata yönetimi mekanizması kullanın
  }
}

class MenuState extends Equatable {
  const MenuState({
    this.orders,
    this.categories,
    this.selectedValue,
    this.tables,
    this.tableBills = const {},
  });

  final List<Menu>? orders;
  final List<Category>? categories;
  final String? selectedValue;
  final List<CoffeTable>? tables;
  final Map<int, List<Menu>> tableBills;

  @override
  List<Object?> get props =>
      [orders, categories, selectedValue, tables, tableBills];

  MenuState copyWith({
    List<Menu>? orders,
    List<Category>? categories,
    String? selectedValue,
    List<CoffeTable>? tables,
    Map<int, List<Menu>>? tableBills,
  }) {
    return MenuState(
      orders: orders ?? this.orders,
      categories: categories ?? this.categories,
      selectedValue: selectedValue ?? this.selectedValue,
      tables: tables ?? this.tables,
      tableBills: tableBills ?? this.tableBills,
    );
  }

  List<Menu> getTableBill(int tableId) {
    return tableBills[tableId] ?? [];
  }
}
