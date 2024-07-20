import 'package:altmisdokuzapp/product/model/category.dart';
import 'package:altmisdokuzapp/product/model/menu.dart';
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

  void selectCategory(String? categoryName) {
    state = state.copyWith(selectedValue: categoryName);
  }
}

class HomeState extends Equatable {
  const HomeState({this.orders, this.categories, this.selectedValue});

  final List<Menu>? orders;
  final List<Category>? categories;
  final String? selectedValue;

  @override
  List<Object?> get props => [orders, categories, selectedValue];

  HomeState copyWith({
    List<Menu>? orders,
    List<Category>? categories,
    String? selectedValue,
  }) {
    return HomeState(
      orders: orders ?? this.orders,
      categories: categories ?? this.categories,
      selectedValue: selectedValue ?? this.selectedValue,
    );
  }
}
