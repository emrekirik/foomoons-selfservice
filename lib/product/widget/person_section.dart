import 'package:altmisdokuzapp/featured/providers/reports_notifier.dart';
import 'package:altmisdokuzapp/featured/reports/dialogs/add_personal_dialog.dart';
import 'package:altmisdokuzapp/product/widget/personal_card_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _reportsProvider =
    StateNotifierProvider<ReportsNotifier, ReportsState>((ref) {
  return ReportsNotifier(ref);
});

class PersonSection extends ConsumerWidget {
  final List<Map<String, dynamic>> employees;
  const PersonSection({super.key, required this.employees});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Çalışanları alıyoruz
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              const SizedBox(
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: ListTile(
                      title: Text(
                        'Personel Bilgileri',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Lorem ipsum dolar sit amet, consectetur'),
                      subtitleTextStyle: TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                          fontWeight: FontWeight.w300),
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
                        addPersonalDialog(
                            context, ref.read(_reportsProvider.notifier));
                      },
                      icon: const Icon(
                        Icons.add,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                flex: 8,
                child: employees.isNotEmpty // Çalışanlar varsa göster
                    ? GridView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(10),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4, // Sütun sayısını ayarla
                          crossAxisSpacing:
                              10, // Öğeler arasındaki yatay boşluk
                          mainAxisSpacing: 10, // Öğeler arasındaki dikey boşluk
                          childAspectRatio: 0.7,
                        ),
                        itemCount: employees.length,
                        itemBuilder: (context, index) {
                          final employee = employees[index];
                          return PersonalCardItem(
                            name: employee['name'] ?? 'Bilinmiyor',
                            position: employee['position'] ?? 'Bilinmiyor',
                            profileImage: employee['profileImage'] ??
                                '', // varsayılan bir resim ekleyebilirsiniz
                          );
                        },
                      )
                    : const Center(
                        child: Text('Henüz personel bilgisi yok'),
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
