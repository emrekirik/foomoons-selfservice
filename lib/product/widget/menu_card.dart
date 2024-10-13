import 'package:altmisdokuzapp/featured/tables/dialogs/update_product_dialog.dart';
import 'package:altmisdokuzapp/product/model/category.dart';
import 'package:altmisdokuzapp/product/model/menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class MenuCard extends ConsumerWidget {
  final Menu item;
  final List<Category> categories;
  const MenuCard(
      {required this.item,
      required this.categories,
      super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        final productId = item.id;
        if (productId == null) {
          print('id null geliyor');
          print('Menu Item: ${item.title}, ID: ${item.id}');
        } else {
          print('Menu Item: ${item.title}, ID: ${item.id}');
          showUpdateProductDialog(
            context,
            ref,
            categories,
            productId,
            item,
          );
        }
      },
      child: Card(
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
      ),
    );
  }
}
