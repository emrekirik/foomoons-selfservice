import 'package:altmisdokuzapp/featured/menu/dialogs/add_category_dialog.dart';
import 'package:altmisdokuzapp/featured/menu/dialogs/add_order_dialog.dart';
import 'package:altmisdokuzapp/featured/menu/dialogs/add_product_dialog.dart';
import 'package:altmisdokuzapp/featured/menu/dialogs/add_table_dialog.dart';
import 'package:altmisdokuzapp/featured/menu/menu_notifier.dart';
import 'package:altmisdokuzapp/product/constants/color_constants.dart';
import 'package:altmisdokuzapp/product/widget/menu_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _menuProvider =
    StateNotifierProvider<MenuNotifier, MenuState>((ref) => MenuNotifier());

class MenuView extends ConsumerWidget {
  final String? successMessage;
  const MenuView({this.successMessage, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuNotifier = ref.watch(_menuProvider.notifier);
    final orderItem = ref.watch(_menuProvider).orders ?? [];
    final categories = ref.watch(_menuProvider).categories ?? [];
    final selectedCategory = ref.watch(_menuProvider).selectedValue;
    final tables = ref.watch(_menuProvider).tables ?? [];
    double deviceWidth = MediaQuery.of(context).size.width;

    // Seçili kategoriye göre ürünleri filtrele
    final filteredItems = selectedCategory == null ||
            selectedCategory == MenuNotifier.allCategories
        ? orderItem
        : orderItem.where((item) => item.category == selectedCategory).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          // Geniş ekran düzeni
          return Center(
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 30, bottom: 20, top: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: ColorConstants.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    width: deviceWidth * 0.6,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 10,
                                  child: SizedBox(
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
                                                    color:
                                                        ColorConstants.black),
                                              ),
                                            ),
                                          );
                                        } else {
                                          final category =
                                              categories[index - 1];
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: OutlinedButton(
                                              onPressed: () {
                                                menuNotifier.selectCategory(
                                                    category.name);
                                              },
                                              child: Text(
                                                category.name ?? '',
                                                style: const TextStyle(
                                                    color:
                                                        ColorConstants.black),
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  onSelected: (String value) {
                                    switch (value) {
                                      case 'Kategori Ekle':
                                        // Kategori ekleme işlemi
                                        showAddCategoryDialog(
                                            context, menuNotifier);
                                        break;
                                      case 'Ürün Ekle':
                                        // Ürün ekleme işlemi
                                        showAddProductDialog(
                                            context, menuNotifier, categories);
                                        break;
                                      default:
                                        // Diğer işlemler veya varsayılan durum
                                        break;
                                    }
                                  },
                                  itemBuilder: (BuildContext context) {
                                    return [
                                      const PopupMenuItem<String>(
                                        value: 'Kategori Ekle',
                                        child: Text('Kategori Ekle'),
                                      ),
                                      const PopupMenuItem<String>(
                                        value: 'Ürün Ekle',
                                        child: Text('Ürün Ekle'),
                                      ),
                                    ];
                                  },
                                  icon: const Icon(Icons.more_vert),
                                ),
                              ],
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
                                  item: item,
                                  menuNotifier: menuNotifier,
                                  categories: categories,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: deviceWidth * 0.01,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20, top: 20),
                  child: Container(
                    width: deviceWidth * 0.35,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: ColorConstants.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              children: [
                                const Expanded(
                                  flex: 8,
                                  child: Text(
                                    'Masalar',
                                    style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(60)),
                                  child: IconButton(
                                    onPressed: () {
                                      showAddTableDialog(context, menuNotifier);
                                    },
                                    icon: const Icon(
                                      Icons.add,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Expanded(
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
                                  child: Container(
                                    decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20)),
                                        image: DecorationImage(
                                            image: AssetImage(
                                                "assets/images/table_icon.png"),
                                            fit: BoxFit.cover)),
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 70),
                                      child: Center(
                                        child: Text(
                                          'Masa ${tables[index].tableId}',
                                          style: const TextStyle(
                                            fontSize: 20.0,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
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
                    const SizedBox(height: 20),
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
                      physics: const NeverScrollableScrollPhysics(),
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
                        return MenuCard(
                          item: item,
                          menuNotifier: menuNotifier,
                          categories: categories,
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 310, bottom: 20),
                      child: FloatingActionButton(
                        backgroundColor:
                            ColorConstants.floatingActionButtonColor,
                        onPressed: () {
                          showAddProductDialog(context, menuNotifier,
                              categories); // Yeni fonksiyonu kullanın
                        },
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Divider(),
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
                      physics: const NeverScrollableScrollPhysics(),
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
                    Padding(
                      padding: const EdgeInsets.only(left: 310, bottom: 20),
                      child: FloatingActionButton(
                        backgroundColor:
                            ColorConstants.floatingActionButtonColor,
                        onPressed: () {
                          showAddTableDialog(context, menuNotifier);
                        },
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
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
