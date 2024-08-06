import 'package:altmisdokuzapp/featured/menu/menu_notifier.dart';
import 'package:altmisdokuzapp/product/model/menu.dart';
import 'package:flutter/material.dart';

class MenuCard extends StatelessWidget {
  final Menu item;
  final MenuNotifier menuNotifier;
  const MenuCard({required this.item, required this.menuNotifier, super.key});

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
                image: item.image ?? 'assets/images/placeholder.png',
                width: double.infinity,
                height: 150,
                fit: BoxFit.cover,
                imageErrorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/images/food_placeholder.png', // Placeholder image path
                    width: double.infinity,
                    height: 150,
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
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            item.price != null ? '${item.price} ₺' : 'Fiyat Yok',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
