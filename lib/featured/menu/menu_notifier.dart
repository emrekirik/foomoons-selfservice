import 'package:altmisdokuzapp/product/model/category.dart';
import 'package:altmisdokuzapp/product/model/menu.dart';
import 'package:altmisdokuzapp/product/model/table.dart';
import 'package:altmisdokuzapp/product/utility/firebase/firebase_collections.dart';
import 'package:equatable/equatable.dart';
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
          return Menu.fromJson(snapshot.data()!);
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
