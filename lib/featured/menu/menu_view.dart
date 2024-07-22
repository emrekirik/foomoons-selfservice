import 'package:altmisdokuzapp/featured/menu/add_order_dialog.dart';
import 'package:altmisdokuzapp/featured/menu/add_product_dialog.dart';
import 'package:altmisdokuzapp/featured/menu/add_table_dialog.dart';
import 'package:altmisdokuzapp/featured/menu/menu_notifier.dart';
import 'package:altmisdokuzapp/product/constants/color_constants.dart';
import 'package:altmisdokuzapp/product/widget/menu_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _menuProvider =
    StateNotifierProvider<MenuNotifier, HomeState>((ref) => MenuNotifier());

class MenuView extends ConsumerWidget {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuNotifier = ref.watch(_menuProvider.notifier);
    final orderItem = ref.watch(_menuProvider).orders ?? [];
    final categories = ref.watch(_menuProvider).categories ?? [];
    final selectedCategory = ref.watch(_menuProvider).selectedValue;
    final tables = ref.watch(_menuProvider).tables ?? [];
    print("Tables in UI: ${tables.length}");

    // Seçili kategoriye göre ürünleri filtrele
    final filteredItems = selectedCategory == null ||
            selectedCategory == MenuNotifier.allCategories
        ? orderItem
        : orderItem.where((item) => item.category == selectedCategory).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          // Geniş ekran düzeni
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    flex: 70,
                    child: Container(
                      width: constraints.maxWidth * 0.7,
                      color: Colors.white, // Ekranın %70'i kadar genişlik ver
                      child: Column(
                        children: [
                          SizedBox(height: 20),
                          SizedBox(
                            height: 50,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: categories.length +
                                  1, // Tüm Ürünler butonu için +1
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: OutlinedButton(
                                      onPressed: () {
                                        menuNotifier.selectCategory(
                                            MenuNotifier.allCategories);
                                      },
                                      child: const Text(
                                        'Tüm ürünler',
                                        style: TextStyle(
                                            color: ColorConstants.black),
                                      ),
                                    ),
                                  );
                                } else {
                                  final category = categories[index - 1];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: OutlinedButton(
                                      onPressed: () {
                                        menuNotifier
                                            .selectCategory(category.name);
                                      },
                                      child: Text(
                                        category.name ?? '',
                                        style: const TextStyle(
                                            color: ColorConstants.black),
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                          Expanded(
                            child: GridView.builder(
                              padding: const EdgeInsets.all(10),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: (constraints.maxWidth / 200)
                                    .floor(), // Sütun sayısını ayarla
                                crossAxisSpacing:
                                    10, // Öğeler arasındaki yatay boşluk
                                mainAxisSpacing:
                                    10, // Öğeler arasındaki dikey boşluk
                                childAspectRatio: 0.7,
                              ),
                              itemCount: filteredItems.length,
                              itemBuilder: (context, index) {
                                final item = filteredItems[index];
                                return MenuCard(
                                    item: item, menuNotifier: menuNotifier);
                              },
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 1050, bottom: 20),
                            child: FloatingActionButton(
                                onPressed: () {
                                  showAddProductDialog(context, menuNotifier,
                                      categories); // Yeni fonksiyonu kullanın
                                },
                                child: const Icon(Icons.add)),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: ColorConstants.appbackgroundColor,
                    ),
                  ),
                  Expanded(
                    flex: 30,
                    child: Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          const Text(
                            'Masalar',
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: (constraints.maxWidth / 300)
                                      .floor(), // Burada sütun sayısını ayarlayabilirsiniz
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 1.0,
                                ),
                                itemCount: tables.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return InkWell(
                                    onTap: () {
                                      final tableId = tables[index].tableId;
                                      if (tableId != null) {
                                        showAddOrderDialog(
                                            context, ref, tableId, orderItem);
                                      } else {
                                        // Masa ID'si null ise yapılacak işlemler
                                      }
                                    },
                                    child: Card(
                                      color: ColorConstants.appbackgroundColor,
                                      child: Center(
                                        child: Text(
                                          'Masa ${tables[index].tableId}',
                                          style: const TextStyle(
                                            fontSize: 20.0,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 400, bottom: 20),
                            child: FloatingActionButton(
                                onPressed: () {
                                  showAddTableDialog(context, menuNotifier);
                                },
                                child: const Icon(Icons.add)),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          // Dar ekran düzeni
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount:
                            categories.length + 1, // Tüm Ürünler butonu için +1
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: OutlinedButton(
                                onPressed: () {
                                  menuNotifier.selectCategory(
                                      MenuNotifier.allCategories);
                                },
                                child: const Text(
                                  'Tüm ürünler',
                                  style: TextStyle(color: ColorConstants.black),
                                ),
                              ),
                            );
                          } else {
                            final category = categories[index - 1];
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: OutlinedButton(
                                onPressed: () {
                                  menuNotifier.selectCategory(category.name);
                                },
                                child: Text(
                                  category.name ?? '',
                                  style: const TextStyle(
                                      color: ColorConstants.black),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(10),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4, // Sütun sayısını ayarla
                        crossAxisSpacing: 10, // Öğeler arasındaki yatay boşluk
                        mainAxisSpacing: 10, // Öğeler arasındaki dikey boşluk
                        childAspectRatio: 0.7,
                      ),
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        return MenuCard(item: item, menuNotifier: menuNotifier);
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 310, bottom: 20),
                      child: FloatingActionButton(
                        onPressed: () {
                          showAddProductDialog(context, menuNotifier,
                              categories); // Yeni fonksiyonu kullanın
                        },
                        child: const Icon(Icons.add),
                      ),
                    ),
                    Divider(),
                    const Padding(
                      padding: EdgeInsets.only(top: 20, bottom: 20),
                      child: Text(
                        'Masalar',
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(8.0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                            4, // Burada sütun sayısını ayarlayabilirsiniz
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: tables.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          color: ColorConstants.appbackgroundColor,
                          child: Center(
                            child: Text(
                              'Masa ${tables[index].tableId}',
                              style: const TextStyle(
                                fontSize: 20.0,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 310, bottom: 20),
                      child: FloatingActionButton(
                        onPressed: () {
                          showAddTableDialog(context, menuNotifier);
                        },
                        child: Icon(Icons.add),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
