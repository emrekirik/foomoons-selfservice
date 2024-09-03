import 'dart:convert';
import 'package:altmisdokuzapp/product/model/category.dart';
import 'package:altmisdokuzapp/product/model/menu.dart';
import 'package:altmisdokuzapp/product/model/table.dart';
import 'package:altmisdokuzapp/product/utility/firebase/firebase_collections.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final menuProvider = StateNotifierProvider<MenuNotifier, MenuState>((ref) {
  return MenuNotifier();
});

class MenuNotifier extends StateNotifier<MenuState> {
  static const String allCategories = 'Tüm Kategoriler';

  MenuNotifier() : super(const MenuState()) {
    fetchOrder();
    fetchCategories();
    fetchTable();
  }

  Future<void> fetchOrder() async {
    try {
      final orderCollectionReference = FirebaseCollections.order.reference;
      final response = await orderCollectionReference.withConverter<Menu>(
        fromFirestore: (snapshot, options) {
          final menu = Menu.fromJson(snapshot.data()!);

          return menu.copyWith(
              id: snapshot.id); // Burada id'yi snapshot'tan alıyoruz
        },
        toFirestore: (value, options) {
          return value.toJson();
        },
      ).get();

      if (response.docs.isNotEmpty) {
        final values = response.docs.map((e) => e.data()).toList();

        state = state.copyWith(orders: values);
      } else {
        state = state.copyWith(orders: []);
      }
    } catch (e) {
      _handleError(e, 'Siparişleri getirme hatası');
    }
  }

// Menu orders listesini güncelleyen method
  void updateMenuOrders(List<Menu> updatedOrders) {
    state = state.copyWith(orders: updatedOrders);
  }

    String generateQRCode(int tableId) {
    final String token = base64Encode(utf8.encode('tableId:$tableId'));
    final Uri menuUrl = Uri(
      scheme: 'http',
      host: '192.168.1.123', // veya IP adresi
      port: 8080, // yerel sunucunuzun port numarası
    );
    final String finalUrl = menuUrl.toString() + '#/table?token=$token';
    return finalUrl;
  }




  Future<void> fetchTable() async {
    try {
      final tableCollectionReference = FirebaseCollections.table.reference;
      final response = await tableCollectionReference.withConverter<CoffeTable>(
        fromFirestore: (snapshot, options) {
          return CoffeTable.fromJson(snapshot.data()!);
        },
        toFirestore: (value, options) {
          return value.toJson();
        },
      ).get();

      if (response.docs.isNotEmpty) {
        final values = response.docs.map((e) => e.data()).toList();
        values.sort((a, b) => a.tableId!.compareTo(b.tableId!));
        state = state.copyWith(tables: values);
      } else {
        state = state.copyWith(tables: []);
      }
    } catch (e) {
      _handleError(e, 'Masaları getirme hatası');
    }
  }

  Future<void> fetchCategories() async {
    try {
      final categoryCollectionReference =
          FirebaseCollections.category.reference;
      final response =
          await categoryCollectionReference.withConverter<Category>(
        fromFirestore: (snapshot, options) {
          return Category.fromJson(snapshot.data()!);
        },
        toFirestore: (value, options) {
          return value.toJson();
        },
      ).get();

      if (response.docs.isNotEmpty) {
        final values = response.docs.map((e) => e.data()).toList();
        state = state.copyWith(categories: values);
      } else {
        state = state.copyWith(categories: []);
      }
    } catch (e) {
      _handleError(e, 'Kategorileri getirme hatası');
    }
  }
  

  Future<void> addCategory(Category category) async {
    try {
      final categoryCollectionReference =
          FirebaseCollections.category.reference;
      await categoryCollectionReference.add(category.toJson());
      // ID'yi ayarla ve yeni kategoriye ekle

      // Yeni kategoriyi mevcut listeye ekleyin ve state'i güncelleyin
      state = state.copyWith(categories: [...?state.categories, category]);
    } catch (e) {
      _handleError(e, 'Kategory Ekleme Hatası');
    }
  }

  Future<void> addProduct(Menu newProduct) async {
    try {
      final orderCollectionReference = FirebaseCollections.order.reference;
      await orderCollectionReference.add(newProduct.toJson());

      state = state.copyWith(orders: [...?state.orders, newProduct]);
    } catch (e) {
      _handleError(e, 'Ürün ekleme hatası');
    }
  }

  Future<void> addTable(CoffeTable table) async {
    try {
      final tableCollectionReference = FirebaseCollections.table.reference;
      await tableCollectionReference.add(table.toJson());

      state = state.copyWith(tables: [...?state.tables, table]);
    } catch (e) {
      _handleError(e, 'Masa ekleme hatası');
    }
  }

  Future<void> addItemToBill(int tableId, Menu item) async {
    try {
      final tableBillCollectionReference =
          FirebaseCollections.tableBill.reference.doc(tableId.toString());
      final doc = await tableBillCollectionReference.get();

      List<Menu> currentBillItems = [];
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        currentBillItems = (data['billItems'] as List<dynamic>)
            .map((item) => Menu.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      currentBillItems.add(item);
      await tableBillCollectionReference.set({
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

  Future<void> updateProduct(
      String productId, Menu updatedMenu, BuildContext context) async {
    try {
      final orderCollectionReference = FirebaseCollections.order.reference;

      // Güncellemek istediğiniz ürün belgesi referansı
      final productDocumentReference = orderCollectionReference.doc(productId);

      // Ürün belgesini yeni verilerle güncelle

      await productDocumentReference.update(updatedMenu.toJson());

      // Güncellenen verilerin state'te yansımasını sağlamak için siparişleri yeniden çek
      await fetchOrder();

      // Güncelleme başarılı olduğunda kullanıcıyı yeni sayfaya yönlendir ve mesajı ilet
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ürün başarıyla Güncellendi')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        _handleError(e, 'Ürünü güncelleme hatası');
      }
    }
  }

  Future<void> deleteProduct(String productId, BuildContext context) async {
    try {
      final orderCollectionReference = FirebaseCollections.order.reference;

      // Silmek istediğiniz ürün belgesi referansı
      final productDocumentReference = orderCollectionReference.doc(productId);

      // Ürün belgesini Firestore'dan sil
      await productDocumentReference.delete();

      // Silme işlemi sonrasında sipariş listesini güncellemek için fetchOrder'ı çağırın
      await fetchOrder();

      // Silme başarılı olduğunda kullanıcıya bir mesaj gösterin
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

  Future<void> removeItemFromBill(int tableId, Menu item) async {
    try {
      final tableBillCollectionReference =
          FirebaseCollections.tableBill.reference.doc(tableId.toString());
      final doc = await tableBillCollectionReference.get();

      List<Menu> currentBillItems = [];
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        currentBillItems = (data['billItems'] as List<dynamic>)
            .map((item) => Menu.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      currentBillItems.remove(item);
      await tableBillCollectionReference.set({
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

  Future<void> fetchTableBill(int tableId) async {
    try {
      final tableBillCollectionReference =
          FirebaseCollections.tableBill.reference.doc(tableId.toString());
      final doc = await tableBillCollectionReference.get();

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

  Menu? getProductById(String productId) {
    return state.orders?.firstWhere((menu) => menu.id == productId);
  }

  void selectCategory(String? categoryName) {
    state = state.copyWith(selectedValue: categoryName);
  }

  void _handleError(Object e, String message) {
    // Hatanızı kayıt hizmetine loglayın

    // Gerekirse hatayı yansıtmak için durumu güncelleyin
    // state = state.copyWith(errorMessage: '$message: $e');
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
