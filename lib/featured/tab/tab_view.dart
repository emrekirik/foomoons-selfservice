import 'package:altmisdokuzapp/product/constants/color_constants.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:altmisdokuzapp/featured/admin/admin_view.dart';
import 'package:altmisdokuzapp/featured/menu/menu_view.dart';
import 'package:altmisdokuzapp/featured/reports/reports_view.dart';

class TabView extends StatefulWidget {
  const TabView({super.key});

  @override
  State<TabView> createState() => _TabViewState();
}

class _TabViewState extends State<TabView> with SingleTickerProviderStateMixin {
  int _tabIndex = 1; // Başlangıç sekmesi
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _tabIndex);
  }

  void _onTabChanged(int index) {
    setState(() {
      _tabIndex = index;
      _pageController.animateToPage(_tabIndex,duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.appbackgroundColor.withOpacity(0.15),
      extendBody: true,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 30,
        ),
        child: CustomPaint(
          painter: SideShadowPainter(),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30), // Köşe yuvarlama için
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: CurvedNavigationBar(
                index: _tabIndex,
                animationCurve: Curves.linear,
                height: 75,
                items: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Icon(
                        Icons.menu_book,
                        size: 30,
                      ),
                      if (_tabIndex != 0) const Text('Menü'),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Icon(
                        Icons.home,
                        size: 30,
                      ),
                      if (_tabIndex != 1) const Text('Anasayfa'),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Icon(
                        Icons.report,
                        size: 30,
                      ),
                      if (_tabIndex != 2) const Text('Raporlar'),
                    ],
                  ),
                ],
                backgroundColor:
                    ColorConstants.appbackgroundColor.withOpacity(0.15),
                onTap: (index) {
                  _onTabChanged(index);
                },
              ),
            ),
          ),
        ),
      ),
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: _CustomAppbar(),
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _tabIndex = index;
            });
          },
          children: const [
            MenuView(),
            AdminView(),
            ReportsView(),
          ],
        ),
      ),
    );
  }
}

class _CustomAppbar extends StatelessWidget {
  const _CustomAppbar();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        margin: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(70),
            bottomRight: Radius.circular(70),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
      ),
      title: Padding(
        padding: const EdgeInsets.only(top: 7),
        child: Image.asset(
          'assets/images/logo.png',
          width: 80,
          height: 80,
          fit: BoxFit.cover,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }
}

class SideShadowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);

    // Sol gölge
    canvas.drawRect(
      Rect.fromLTRB(-7, 0, 0, size.height),
      paint,
    );

    // Sağ gölge
    canvas.drawRect(
      Rect.fromLTRB(size.width, 0, size.width + 7, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
