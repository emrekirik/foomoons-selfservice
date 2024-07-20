import 'package:altmisdokuzapp/featured/menu/menu_notifier.dart';
import 'package:altmisdokuzapp/product/constants/color_constants.dart';
import 'package:altmisdokuzapp/product/widget/menu_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:altmisdokuzapp/featured/menu/add_product_dialog.dart'; // Yeni dosyayı import edin

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

    // Seçili kategoriye göre ürünleri filtrele
    final filteredItems = selectedCategory == null || selectedCategory == MenuNotifier.allCategories
        ? orderItem
        : orderItem.where((item) => item.category == selectedCategory).toList();

    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = (screenWidth / 150)
        .floor(); // Adjust 150 to control the number of columns

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddProductDialog(context, menuNotifier, categories); // Yeni fonksiyonu kullanın
        },
        backgroundColor: ColorConstants.appbackgroundColor,
        child: const Icon(Icons.add, color: Colors.white,),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20),
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length + 1, // Tüm Ürünler butonu için +1
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: OutlinedButton(
                        onPressed: () {
                          menuNotifier.selectCategory(MenuNotifier.allCategories);
                        },
                        child: const Text('Tüm ürünler', style: TextStyle(color: ColorConstants.black),),
                      ),
                    );
                  } else {
                    final category = categories[index - 1];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: OutlinedButton(
                        onPressed: () {
                          menuNotifier.selectCategory(category.name);
                        },
                        child: Text(category.name ?? '', style: const TextStyle(color: ColorConstants.black),),
                      ),
                    );
                  }
                },
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount, // Number of columns
                  crossAxisSpacing: 10, // Horizontal spacing between items
                  mainAxisSpacing: 10, // Vertical spacing between items
                  childAspectRatio: 0.8, // Aspect ratio for square cells
                ),
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  return MenuCard(item: item, menuNotifier: menuNotifier);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
