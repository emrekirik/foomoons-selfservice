import 'package:foomoons/featured/providers/loading_notifier.dart';
import 'package:foomoons/featured/providers/menu_notifier.dart';
import 'package:foomoons/featured/tables/dialogs/add_category_dialog.dart';
import 'package:foomoons/product/constants/color_constants.dart';
import 'package:foomoons/product/model/category.dart';
import 'package:foomoons/product/model/menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _menuProvider = StateNotifierProvider<MenuNotifier, MenuState>((ref) {
  return MenuNotifier(ref);
});

/// MenuView Widget
class MenuMobileView extends ConsumerStatefulWidget {
  final String? successMessage;
  const MenuMobileView({this.successMessage, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MenuMobileViewState();
}

class _MenuMobileViewState extends ConsumerState<MenuMobileView> {
  int selected = 0;
  late TextEditingController searchContoller;
  String searchQuery = '';
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    searchContoller = TextEditingController();

    Future.microtask(() {
      ref.read(_menuProvider.notifier).fetchAndload();
      if (selected == 0) {
        ref
            .read(_menuProvider.notifier)
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
    final menuNotifier = ref.watch(
        _menuProvider.notifier); //TODO: hata olursa buraya bi bak watch yap
    final menuState = ref.watch(_menuProvider);
    final productItem = menuState.products ?? [];
    final categories = menuState.categories ?? [];
    final selectedCategory = menuState.selectedValue;
    double deviceWidth = MediaQuery.of(context).size.width;

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
            child: Row(
              children: [
                searchQuery.isNotEmpty || deviceWidth < 600
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
                                  padding: EdgeInsets.symmetric(vertical: 19),
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
                Expanded(
                  child: Column(
                    children: [
                      // Kategori Seçici ve Popup Menü
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: deviceWidth < 750 ? 200 : 400,
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
                                        _addProductDialog(
                                            context,
                                            isUploading,
                                            categories,
                                            menuNotifier);
                                        setState(() {});
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
                      Expanded(
                        flex: 10,
                        child: GridView.builder(
                          padding: const EdgeInsets.all(10),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                                (constraints.maxWidth / 140).floor(),
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.8,
                          ),
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = filteredItems[index];
                            return isLoading
                                ? const SizedBox()
                                : InkWell(
                                    onTap: () async {
                                      final productId = item.id;
                                      if (productId == null) {
                                        print('id null geliyor');
                                        print(
                                            'Menu Item: ${item.title}, ID: ${item.id}');
                                      } else {
                                        print(
                                            'Menu Item: ${item.title}, ID: ${item.id}');
            
                                        _updateProductDialog(context, item,
                                            categories, productId);
                                        ref
                                            .read(_menuProvider.notifier)
                                            .resetPhotoUrl();
                                        setState(() {});
                                      }
                                    },
                                    child: MenuItem(item: item),
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
        );
      },
    );
  }

  Future<dynamic> _updateProductDialog(BuildContext context, Menu item,
      List<Category> categories, String productId) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        late TextEditingController titleController;
        late TextEditingController priceController;
        late TextEditingController prepTimeController;
        late TextEditingController categoryController;
        late TextEditingController stockController;
        // Mevcut ürünü dolduruyoruz
        final initialPrepTimeInMinutes = (item.preparationTime ?? 0) / 60;
        titleController = TextEditingController(text: item.title);
        priceController = TextEditingController(text: item.price?.toString());
        prepTimeController = TextEditingController(
            text: initialPrepTimeInMinutes.toStringAsFixed(0));
        categoryController = TextEditingController(text: item.category);
        stockController = TextEditingController(
            text: item.stock?.toString() ?? 'Stok Girişi Yok');

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Ürün Güncelle'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          isUploading = true;
                        });
                        await ref
                            .read(_menuProvider.notifier)
                            .pickAndUploadImage();
                        setState(() {
                          isUploading = false;
                        });
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 100,
                            backgroundImage: (ref
                                        .watch(_menuProvider)
                                        .photoURL !=
                                    null)
                                ? NetworkImage(
                                    ref.watch(_menuProvider).photoURL!)
                                : (item.image != null
                                    ? NetworkImage(item.image!)
                                    : const AssetImage(
                                            'assets/images/food_placeholder.png')
                                        as ImageProvider),
                          ),
                          if (isUploading)
                            const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                        ],
                      ),
                    ),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Ürün İsmi'),
                    ),
                    TextField(
                      controller: priceController,
                      decoration:
                          const InputDecoration(labelText: 'Ürün Fiyatı'),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: prepTimeController,
                      decoration: const InputDecoration(
                          labelText: 'Ürün Min Hazırlanma Süresi'),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: stockController,
                      decoration: const InputDecoration(labelText: 'Stok'),
                      keyboardType: TextInputType.number,
                    ),
                    DropdownButtonFormField<String>(
                      decoration:
                          const InputDecoration(labelText: 'Ürün Kategorisi'),
                      items: categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category.name,
                          child: Text(category.name ?? ''),
                        );
                      }).toList(),
                      value: item.category,
                      onChanged: (value) {
                        categoryController.text = value ?? '';
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('İptal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await ref
                        .read(_menuProvider.notifier)
                        .deleteProduct(productId, context);
                    Navigator.of(context).pop(); // Dialog'u kapat
                  },
                  child: const Text('Ürünü Sil'),
                ),
                ElevatedButton(
                  onPressed: isUploading
                      ? null // Eğer hala resim yükleniyorsa butonu devre dışı bırak
                      : () async {
                          final updatedProduct = Menu(
                            title: titleController.text,
                            price: int.tryParse(priceController.text),
                            image:
                                ref.watch(_menuProvider).photoURL ?? item.image,
                            preparationTime:
                                int.tryParse(prepTimeController.text)! * 60,
                            category: categoryController.text,
                            stock: int.tryParse(stockController.text),
                          );
                          await ref.read(_menuProvider.notifier).updateProduct(
                              productId, updatedProduct, context);
                              
                          ref.read(_menuProvider.notifier).resetPhotoUrl();
                          Navigator.of(context).pop();
                        },
                  child: const Text('Kaydet'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<dynamic> _addProductDialog(BuildContext context, bool isUploading,
      List<Category> categories, MenuNotifier menuNotifier) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        // Text editing controllers are initialized inside the function.
        TextEditingController titleController = TextEditingController();
        TextEditingController priceController = TextEditingController();
        TextEditingController prepTimeController = TextEditingController();
        TextEditingController categoryController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Ürün Ekle'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // StatefulBuilder ile yalnızca bu kısmı güncelleriz
                    GestureDetector(
                      onTap: () async {
                        setState(
                          () {
                            isUploading = true;
                            print('Uploading started'); // Log ekleyin
                          },
                        );
                        await ref
                            .read(_menuProvider.notifier)
                            .pickAndUploadImage();

                        setState(() {
                          isUploading = false;
                          print('Uploading stop'); // Log ekleyin
                        });
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 100,
                            backgroundImage:
                                ref.watch(_menuProvider).photoURL != null
                                    ? NetworkImage(
                                        ref.watch(_menuProvider).photoURL!)
                                    : const AssetImage(
                                        'assets/images/food_placeholder.png'),
                          ),
                          if (isUploading)
                            const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                        ],
                      ),
                    ),

                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Ürün İsmi'),
                    ),
                    TextField(
                      controller: priceController,
                      decoration:
                          const InputDecoration(labelText: 'Ürün Fiyatı'),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: prepTimeController,
                      decoration: const InputDecoration(
                          labelText: 'Ürün Min Hazırlanma Süresi'),
                      keyboardType: TextInputType.number,
                    ),
                    DropdownButtonFormField<String>(
                      decoration:
                          const InputDecoration(labelText: 'Ürün Kategorisi'),
                      items: categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category.name,
                          child: Text(category.name ?? ''),
                        );
                      }).toList(),
                      onChanged: (value) {
                        categoryController.text = value ?? '';
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('İptal'),
                ),
                ElevatedButton(
                  onPressed: isUploading
                      ? null
                      : () async {
                          // Girdilerin doğrulaması
                          if (titleController.text.isEmpty ||
                              priceController.text.isEmpty ||
                              prepTimeController.text.isEmpty ||
                              categoryController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Lütfen tüm alanları doldurun')),
                            );
                            return; // İşlemi durdur
                          }

                          final newProduct = Menu(
                            title: titleController.text,
                            price: int.tryParse(priceController.text),
                            image: ref.watch(_menuProvider).photoURL,
                            preparationTime:
                                int.tryParse(prepTimeController.text)! * 60,
                            category: categoryController.text,
                          );

                          await menuNotifier.addProduct(newProduct);
                          Navigator.of(context).pop();
                        },
                  child: const Text('Kaydet'),
                )
              ],
            );
          },
        );
      },
    );
  }
}

class MenuItem extends StatelessWidget {
  const MenuItem({
    super.key,
    required this.item,
  });

  final Menu item;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: FadeInImage.assetNetwork(
                placeholder:
                    'assets/images/food_placeholder.png', // Geçici resim yolu
                image: item.image ?? 'assets/images/food_placeholder.png',
                width: double.infinity,
                height: 130,
                fit: BoxFit.cover,
                imageErrorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/images/food_placeholder.png', // Placeholder image path
                    width: double.infinity,
                    height: 120,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              item.title ?? '',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            item.price != null ? '${item.price} ₺' : 'Fiyat Yok',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
