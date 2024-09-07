import 'package:altmisdokuzapp/product/constants/color_constants.dart';
import 'package:altmisdokuzapp/product/widget/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileView extends ConsumerWidget {
  ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;

    final List<IconData> icons = [
      Icons.person,
      Icons.lock,
      Icons.check_circle,
      Icons.phone,
      Icons.email,
      Icons.settings,
      Icons.star,
      Icons.face,
    ];
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: CustomAppbar(
          showBackButton: true,
        ),
      ),
      backgroundColor: ColorConstants.appbackgroundColor.withOpacity(0.15),
      body: Center(
        child: Container(
          width: deviceWidth * 0.55,
          height: deviceHeight * 0.9,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Colors.white,
                ColorConstants.white,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            color: ColorConstants.loginCardBackgroundColorr,
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
          child: Row(
            children: [
              Expanded(
                  child: Column(
                children: [
                  Expanded(
                    child: CircleAvatar(
                      radius: deviceWidth * 0.11,
                      backgroundImage: const NetworkImage(
                          'assets/images/personal_placeholder.png'),
                    ),
                  ),
                  Divider(
                    indent: deviceWidth * 0.04,
                    endIndent: deviceWidth * 0.04,
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: deviceWidth * 0.035,
                          vertical: deviceHeight * 0.02),
                      child: Column(
                        children: [
                          _CustomTitle(
                            deviceHeight: deviceHeight,
                            title: 'YETKİLER',
                          ),
                          SizedBox(height: deviceHeight * 0.05),
                          Expanded(
                            child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount:
                                    4, // Her satırda kaç item olacağını belirler
                                crossAxisSpacing: 30, // Yatay boşluk
                                mainAxisSpacing: 30, // Dikey boşluk
                              ),
                              itemCount: icons
                                  .length, // Toplamda kaç item olduğunu belirtir
                              itemBuilder: (context, index) {
                                return Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey.shade300,
                                    border: Border.all(
                                        color: Colors.black, width: 2),
                                  ),
                                  child: Icon(
                                    icons[
                                        index], // Simgeyi listedeki index'e göre seç
                                    size: 10,
                                    color: Colors.black,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: deviceWidth * 0.035,
                    vertical: deviceWidth * 0.02,
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _CustomTitle(
                              deviceHeight: deviceHeight,
                              title: 'Ünvan: ',
                            ),
                            SizedBox(height: deviceHeight * 0.02),
                            const _CustomText(
                                title: 'İsim: ', desc: 'Emre Kirik'),
                            SizedBox(height: deviceHeight * 0.01),
                            const _CustomText(
                                title: 'Telefon: ', desc: '05425671946'),
                            SizedBox(height: deviceHeight * 0.01),
                            const _CustomText(
                                title: 'Email: ',
                                desc: 'mertkirik46@gmail.com'),
                            SizedBox(height: deviceHeight * 0.01),
                            SizedBox(
                              height: deviceHeight * 0.01,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                          flex: 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _CustomTitle(
                                deviceHeight: deviceHeight,
                                title: 'İşletme Bilgileri',
                              ),
                              SizedBox(height: deviceHeight * 0.02),
                              CircleAvatar(
                                radius: deviceWidth * 0.05,
                                backgroundImage: const NetworkImage(
                                    'assets/images/personal_placeholder.png'),
                              ),
                              SizedBox(height: deviceHeight * 0.02),
                              const _CustomText(
                                  title: 'İşletme Adı: ', desc: 'Soul Mate'),
                              SizedBox(height: deviceHeight * 0.02),
                              const _CustomText(
                                title: 'İşletme Adresi: ',
                                desc:
                                    '100. Yıl Mah. 1025. SK. No: 15 78100 Merkez 78000, 78100 Merkez/Karabük',
                              ),
                              SizedBox(height: deviceHeight * 0.02),
                              const _CustomText(
                                  title: 'İşletme Hakkında: ',
                                  desc:
                                      'Kurumsal alt yapı çalışmaları yaklaşık olarak 3 sene süren ve deneme mağazaları hariç ilk Franchise mağazası 2013 yılında açılan Soulmate Coffee, bir CADOSA A.Ş. (Çalışkan, Doğru, Samimi) markasıdır.')
                            ],
                          ))
                    ],
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

class _CustomText extends StatelessWidget {
  final String title;
  final String desc;
  const _CustomText({
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.ubuntu(
              textStyle: const TextStyle(fontSize: 20),
              fontWeight: FontWeight.bold),
        ),
        Flexible(
          child: Text(
            desc.length > 60 ? '${desc.substring(0, 60)}...' : desc,
            style: GoogleFonts.ubuntu(textStyle: TextStyle(fontSize: 20)),
          ),
        ),
      ],
    );
  }
}

class _CustomTitle extends StatelessWidget {
  final String title;
  final double deviceHeight;

  const _CustomTitle({
    required this.title,
    required this.deviceHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: deviceHeight * 0.05,
      decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              ColorConstants.titleContainerColor,
              ColorConstants.titleContainerColorSecond,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(30)),
      child: Center(
        child: Text(
          title,
          style: GoogleFonts.ubuntu(
              textStyle: const TextStyle(color: Colors.white),
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// GridView.builder(
//   gridDelegate:
//       const SliverGridDelegateWithFixedCrossAxisCount(
//     crossAxisCount: 2,
//     crossAxisSpacing: 10,
//     mainAxisSpacing: 10,
//     childAspectRatio: 7 / 2,
//   ),
//   itemBuilder: (context, index) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         return CircleAvatar(
//           radius: 20,
//           backgroundColor: Colors.black,
//         );
//       },
//     );
//   },
// )

