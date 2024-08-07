import 'package:altmisdokuzapp/product/widget/personal_card_item.dart';
import 'package:flutter/material.dart';

class PersonSection extends StatelessWidget {
  const PersonSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
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
                      onPressed: () {},
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
                child: Container(
                  color: Colors.white,
                  child: GridView.builder(
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
                    itemCount: 8,
                    itemBuilder: (context, index) {
                      return const PersonalCardItem();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
