import 'package:altmisdokuzapp/product/model/category.dart';
import 'package:altmisdokuzapp/product/model/menu.dart';
import 'package:altmisdokuzapp/product/model/table.dart';
import 'package:altmisdokuzapp/product/utility/firebase/firebase_collections.dart';
import 'package:altmisdokuzapp/product/utility/firebase/firebase_utility.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final menuProvider = StateNotifierProvider<MenuNotifier, HomeState>((ref) {
  return MenuNotifier();
});

class MenuNotifier extends StateNotifier<HomeState> with FirebaseUtility {
  static const String allCategories = 'All Categories';

  MenuNotifier() : super(const HomeState()) {
    fetchOrder();
    fetchCategories();
    fetchTable();
  }

  Future<void> fetchOrder() async {
    try {
      final orderCollectionReference = FirebaseCollections.order.reference;
      final response = await orderCollectionReference.withConverter(
        fromFirestore: (snapshot, options) {
          return const Menu().fromFirebase(snapshot);
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
      // Hata yönetimi yapabilirsiniz, örneğin loglama veya kullanıcıya hata mesajı gösterme
      print('Fetch order error: $e');
    }
  }
   Future<void> fetchTable() async {
    try {
      final tableCollectionReference = FirebaseCollections.table.reference;
      final response = await tableCollectionReference.withConverter(
        fromFirestore: (snapshot, options) {
          return CoffeTable().fromFirebase(snapshot);
        },
        toFirestore: (value, options) {
          return value.toJson();
        },
      ).get();

      if (response.docs.isNotEmpty) {
        final values = response.docs.map((e) => e.data()).toList();
        values.sort((a, b) => a.tableId!.compareTo(b.tableId!)); // Tabloları küçükten büyüğe sırala
        state = state.copyWith(tables: values);
        print("Tables fetched: ${values.length}"); // Tabloların alındığını kontrol etmek için debug log
      } else {
        state = state.copyWith(tables: []);
        print("No tables found"); // Tabloların bulunmadığını kontrol etmek için debug log
      }
    } catch (e) {
      print('Fetch table error: $e');
    }
  }



  Future<void> fetchCategories() async {
    try {
      final categoryCollectionReference = FirebaseCollections.category.reference;
      final response = await categoryCollectionReference.withConverter<Category>(
        fromFirestore: (snapshot, options) {
          return const Category().fromFirebase(snapshot);
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
      // Hata yönetimi yapabilirsiniz, örneğin loglama veya kullanıcıya hata mesajı gösterme
      print('Fetch categories error: $e');
    }
  }

  Future<void> addProduct(Menu newProduct) async {
    try {
      final orderCollectionReference = FirebaseCollections.order.reference;
      await orderCollectionReference.add(newProduct.toJson());

      // Yeni ürün eklenince state'i güncelle
      state = state.copyWith(orders: [...?state.orders, newProduct]);
    } catch (e) {
      // Hata yönetimi yapabilirsiniz, örneğin loglama veya kullanıcıya hata mesajı gösterme
      print('Add product error: $e');
    }
  }
   Future<void> addTable(CoffeTable tableId) async {
    try {
      final orderCollectionReference = FirebaseCollections.table.reference;
      await orderCollectionReference.add(tableId.toJson());

      // Yeni ürün eklenince state'i güncelle
      state = state.copyWith(tables: [...?state.tables, tableId]);
    } catch (e) {
      // Hata yönetimi yapabilirsiniz, örneğin loglama veya kullanıcıya hata mesajı gösterme
      print('Add product error: $e');
    }
  }
  

  void selectCategory(String? categoryName) {
    state = state.copyWith(selectedValue: categoryName);
  }
}

class HomeState extends Equatable {
  const HomeState({this.orders, this.categories, this.selectedValue, this.tables});

  final List<Menu>? orders;
  final List<Category>? categories;
  final String? selectedValue;
  final List<CoffeTable>? tables;

  @override
  List<Object?> get props => [orders, categories, selectedValue, tables];

  HomeState copyWith({
    List<Menu>? orders,
    List<Category>? categories,
    String? selectedValue,
    List<CoffeTable>? tables,
  }) {
    return HomeState(
      orders: orders ?? this.orders,
      categories: categories ?? this.categories,
      selectedValue: selectedValue ?? this.selectedValue,
      tables: tables ?? this.tables,
    );
  }
}
