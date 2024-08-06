import 'package:flutter/material.dart';

class ReportsView extends StatelessWidget {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    final sizeWidth = MediaQuery.of(context).size.width;
    final sizeHeight = MediaQuery.of(context).size.width;

    return Column(
      children: [
        SizedBox(
          height: sizeHeight * 0.01,
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const _CustomCard(
                  assetImage: 'assets/images/coffee_icon.png',
                  cardSubtitle: '4% (son 30 gün)',
                  cardPiece: '56',
                  cardTitle: 'Toplam Ürün',
                  subTitleIcon: Icon(Icons.graphic_eq),
                ),
                SizedBox(
                  width: sizeWidth * 0.015,
                ),
                const _CustomCard(
                    cardTitle: 'Toplam Hasılat',
                    assetImage: 'assets/images/dolar_icon.png',
                    cardSubtitle: '26% (son 30 gün)',
                    subTitleIcon: Icon(Icons.graphic_eq),
                    cardPiece: '126k'),
                SizedBox(
                  width: sizeWidth * 0.015,
                ),
                const _CustomCard(
                  assetImage: 'assets/images/order_icon.png',
                  cardSubtitle: '4% (son 30 gün)',
                  cardPiece: '279',
                  cardTitle: 'Toplam Sipariş',
                  subTitleIcon: Icon(Icons.graphic_eq),
                ),
                SizedBox(
                  width: sizeWidth * 0.015,
                ),
                const _CustomCard(
                  assetImage: 'assets/images/customer_icon.png',
                  cardSubtitle: '4% (son 30 gün)',
                  cardPiece: '65',
                  cardTitle: 'Toplam Müşteri',
                  subTitleIcon: Icon(Icons.graphic_eq),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const _PersonSection(),
                SizedBox(
                  width: sizeWidth * 0.015,
                ),
                const _ChartSection(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ChartSection extends StatefulWidget {
  const _ChartSection();

  @override
  State<_ChartSection> createState() => _ChartSectionState();
}

class _ChartSectionState extends State<_ChartSection> {
  @override
  Widget build(BuildContext context) {
    String dropdownValue = 'Aylık';
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
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        flex: 12,
                        child: ListTile(
                          title: Text(
                            'Hasılat',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          subtitle:
                              Text('Lorem ipsum dolar sit amet, consectetur'),
                          subtitleTextStyle: TextStyle(
                              fontSize: 15,
                              color: Colors.grey,
                              fontWeight: FontWeight.w300),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(7)),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                            dropdownColor: Colors.grey.shade100,
                            value: dropdownValue,
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.blue,
                            ),
                            iconSize: 24,
                            elevation: 16,
                            style: const TextStyle(color: Colors.black),
                            onChanged: (String? newValue) {
                              setState(() {
                                dropdownValue = newValue!;
                              });
                            },
                            items: <String>['Aylık', 'Haftalık', 'Günlük']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          )),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: const Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: Text('Income'),
                          leading: Icon(
                            Icons.square,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          title: Text('Expense'),
                          leading: Icon(
                            Icons.square,
                            color: Colors.purple,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          title: Text('126,000'),
                          leading: Icon(
                            Icons.graphic_eq,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          title: Text('126,000'),
                          leading: Icon(
                            Icons.graphic_eq,
                            color: Colors.purple,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 12,
                child: Container(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PersonSection extends StatefulWidget {
  const _PersonSection();

  @override
  State<_PersonSection> createState() => _PersonSectionState();
}

class _PersonSectionState extends State<_PersonSection> {
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
                  // Container(
                  //   height: 50,
                  //   width: 50,
                  //   decoration: BoxDecoration(
                  //       color: Colors.grey.shade100,
                  //       borderRadius: BorderRadius.circular(60)),
                  //   child: const Icon(
                  //     Icons.add,
                  //   ),
                  // ),
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
                    physics: NeverScrollableScrollPhysics(),
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
                      return _PersonelCard();
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

class _CustomCard extends StatelessWidget {
  final String cardTitle;
  final String assetImage;
  final String cardSubtitle;
  final Widget subTitleIcon;
  final String cardPiece;
  const _CustomCard(
      {required this.cardTitle,
      required this.assetImage,
      required this.cardSubtitle,
      required this.subTitleIcon,
      required this.cardPiece});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          )
        ], color: Colors.white, borderRadius: BorderRadius.circular(30)),
        height: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage(assetImage),
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              Expanded(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cardPiece,
                    style: const TextStyle(
                        fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    cardTitle,
                    style: TextStyle(fontSize: 18),
                  ),
                  ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: subTitleIcon,
                      title: Text(
                        cardSubtitle,
                        style: const TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w300),
                      )),
                ],
              ))
            ],
          ),
        ),
      ),
    );
  }
}

class _PersonelCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade100,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const CircleAvatar(
                  backgroundImage:
                      AssetImage('assets/images/personal_placeholder.png'),
                  radius: 70,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            flex: 2,
            child: InkWell(
              onTap: () {
                _PersonelShowDialog(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(30)),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('İsim Soyisim', style: TextStyle(fontSize: 18)),
                    Text(
                      'ÜNVAN',
                      style: TextStyle(
                        fontSize: 14,
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
  }

  Future<dynamic> _PersonelShowDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Bilgileri Güncelle'),
          content: const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(labelText: 'Profil Resmi'),
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'İsim Soyisim'),
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Ünvan'),
                  keyboardType: TextInputType.number,
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
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }
}
