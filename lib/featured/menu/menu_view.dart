import 'package:altmisdokuzapp/featured/providers/loading_notifier.dart';
import 'package:altmisdokuzapp/featured/providers/menu_notifier.dart';
import 'package:altmisdokuzapp/featured/tables/dialogs/add_category_dialog.dart';
import 'package:altmisdokuzapp/featured/tables/dialogs/add_product_dialog.dart';
import 'package:altmisdokuzapp/product/constants/color_constants.dart';
import 'package:altmisdokuzapp/product/widget/menu_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _menuProvider = StateNotifierProvider<MenuNotifier, MenuState>((ref) {
  return MenuNotifier(ref);
});

/// MenuView Widget
class MenuView extends ConsumerStatefulWidget {
  final String? successMessage;
  const MenuView({this.successMessage, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MenuViewState();
}

class _MenuViewState extends ConsumerState<MenuView> {
  int selected = 0;
  late TextEditingController searchContoller;
  String searchQuery = '';
  @override
  void initState() {
    super.initState();
    searchContoller = TextEditingController();
    Future.microtask(() {
      ref.read(_menuProvider.notifier).fetchAndload();
      if (selected == 0) {
        ref
            .watch(_menuProvider.notifier)
            .selectCategory(MenuNotifier.allCategories);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    searchContoller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loadingProvider);
    final menuNotifier = ref.read(
        _menuProvider.notifier); //TODO: hata olursa buraya bi bak watch yap
    final menuState = ref.watch(_menuProvider);
    final productItem = menuState.products ?? [];
    final categories = menuState.categories ?? [];
    final selectedCategory = menuState.selectedValue;

    // Filter items based on the search query, ignoring the selected category during search
    final filteredItems = productItem.where((item) {
      // If search query is not empty, ignore category and search across all products
      if (searchQuery.isNotEmpty) {
        return item.title!.toLowerCase().contains(searchQuery.toLowerCase());
      }

      // If search query is empty, filter based on the selected category
      final isCategoryMatch = selectedCategory == null ||
              selectedCategory == MenuNotifier.allCategories
          ? true
          : item.category == selectedCategory;
      return isCategoryMatch;
    }).toList();
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
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
              child: Row(
                children: [
                  searchQuery.isNotEmpty
                      ? const SizedBox()
                      : Container(
                          width: 240,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(
                                  12,
                                ),
                                bottomLeft: Radius.circular(12)),
                            color: Colors.white,
                            border: const Border(
                              right: BorderSide(
                                color: Colors.black12,
                                width: 1,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.withOpacity(0.4),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(4, 0)),
                            ],
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Container(
                                  width: double.maxFinite,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: selected == 0
                                          ? const BorderSide(
                                              color: Colors.orange, width: 5)
                                          : const BorderSide(
                                              color: Colors.black12,
                                              width: 1,
                                            ),
                                    ),
                                  ),
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                        overlayColor: Colors.grey,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8))),
                                    onPressed: () {
                                      setState(() {
                                        selected = 0;
                                      });
                                      menuNotifier.selectCategory(
                                          MenuNotifier.allCategories);
                                    },
                                    child: const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 19),
                                      child: Text(
                                        'Tüm ürünler',
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: ColorConstants.black),
                                      ),
                                    ),
                                  ),
                                ),
                                ListView.builder(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  scrollDirection: Axis.vertical,
                                  itemCount: categories.length,
                                  itemBuilder: (context, index) {
                                    index++;
                                    final category = categories[index - 1];
                                    return Container(
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: selected == index
                                              ? const BorderSide(
                                                  color: Colors.orange,
                                                  width: 5)
                                              : const BorderSide(
                                                  color: Colors.black12,
                                                  width: 1,
                                                ),
                                        ),
                                      ),
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                          overlayColor: Colors.grey,
                                          surfaceTintColor: Colors.blue,
                                          padding: EdgeInsets.zero,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            selected = index;
                                          });
                                          menuNotifier
                                              .selectCategory(category.name);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 19),
                                          child: Text(
                                            category.name ?? '',
                                            style: const TextStyle(
                                                fontSize: 20,
                                                color: ColorConstants.black),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                  Expanded(
                    child: Column(
                      children: [
                        // Kategori Seçici ve Popup Menü
                        Container(
                          height: 68,
                          decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(12)),
                              color: Colors.white,
                              border: const Border(
                                  bottom: BorderSide(
                                color: Colors.black12,
                                width: 1,
                              )),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey
                                      .withOpacity(0.4), // Gölgenin rengi
                                  spreadRadius: 1, // Gölgenin yayılma alanı
                                  blurRadius: 5, // Gölgenin yumuşaklığı
                                  offset: const Offset(0, 4),
                                ),
                              ]),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: 400,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: TextField(
                                    controller: searchContoller,
                                    decoration: InputDecoration(
                                      hintText: 'Ara...',
                                      prefixIcon: const Icon(Icons.search),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onChanged: (query) {
                                      setState(() {
                                        searchQuery =
                                            query; // Update search query
                                      });
                                    },
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  children: [
                                    // Popup Menü
                                    PopupMenuButton<String>(
                                      onSelected: (String value) {
                                        switch (value) {
                                          case 'Kategori Ekle':
                                            showAddCategoryDialog(
                                                context, menuNotifier);
                                            break;
                                          case 'Ürün Ekle':
                                            showAddProductDialog(
                                                context, categories);
                                            break;
                                          default:
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
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 10,
                          child: GridView.builder(
                            padding: const EdgeInsets.all(10),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount:
                                  (constraints.maxWidth / 180).floor(),
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.8,
                            ),
                            itemCount: filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = filteredItems[index];
                              return isLoading
                                  ? const SizedBox()
                                  : MenuCard(
                                      item: item,
                                      categories: categories,
                                    );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
