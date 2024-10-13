import 'package:altmisdokuzapp/featured/providers/menu_notifier.dart';
import 'package:altmisdokuzapp/product/model/category.dart';
import 'package:altmisdokuzapp/product/model/menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _menuProvider = StateNotifierProvider<MenuNotifier, MenuState>((ref) {
  return MenuNotifier(ref);
});

class AddProductDialog extends ConsumerStatefulWidget {
  final List<Category> categories;
  const AddProductDialog({super.key, required this.categories});

  @override
  _AddProductDialogState createState() => _AddProductDialogState();
}

class _AddProductDialogState extends ConsumerState<AddProductDialog> {
  late TextEditingController titleController;
  late TextEditingController priceController;
  late TextEditingController prepTimeController;
  late TextEditingController categoryController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    priceController = TextEditingController();
    prepTimeController = TextEditingController();
    categoryController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    priceController.dispose();
    prepTimeController.dispose();
    categoryController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menuState = ref.watch(_menuProvider);
    final menuNotifier = ref.read(_menuProvider.notifier);

    return AlertDialog(
      title: const Text('Ürün Ekle'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            GestureDetector(
              onTap: () async {
                await menuNotifier.pickAndUploadImage();
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 100,
                    backgroundImage: menuState.photoURL != null
                        ? NetworkImage(menuState.photoURL!)
                        : const AssetImage(
                            'assets/images/food_placeholder.png'),
                  ),
                  if (menuState.isUploading)
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
              decoration: const InputDecoration(labelText: 'Ürün Fiyatı'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: prepTimeController,
              decoration: const InputDecoration(
                  labelText: 'Ürün Min Hazırlanma Süresi'),
              keyboardType: TextInputType.number,
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Ürün Kategorisi'),
              items: widget.categories.map((category) {
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
          onPressed: menuState.isUploading
              ? null // Eğer hala resim yükleniyorsa butonu devre dışı bırak
              : () async {
                  // Eğer fotoğraf yüklenmemişse uyarı veriyoruz
                  if (menuState.photoURL == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Lütfen bir fotoğraf seçin')),
                    );
                    return; // Fotoğraf yüklenmediyse işlemi durdur
                  }

                  final newProduct = Menu(
                    title: titleController.text,
                    price: int.tryParse(priceController.text),
                    image: menuState.photoURL,
                    preparationTime:
                        int.tryParse(prepTimeController.text)! * 60,
                    category: categoryController.text,
                  );
                  await menuNotifier.addProduct(newProduct);
                  await menuNotifier.fetchProducts();
                  Navigator.of(context).pop();
                },
          child: const Text('Kaydet'),
        ),
      ],
    );
  }
}

void showAddProductDialog(BuildContext context, List<Category> categories) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AddProductDialog(categories: categories);
    },
  );
}
