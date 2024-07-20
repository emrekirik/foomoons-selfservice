import 'package:altmisdokuzapp/product/constants/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:altmisdokuzapp/featured/admin/admin_view.dart';
import 'package:altmisdokuzapp/featured/menu/menu_view.dart';
import 'package:altmisdokuzapp/featured/orders/offer_view.dart';

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
      _pageController.jumpToPage(_tabIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.appbackgroundColor,
      extendBody: true,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: _CustomAppbar(),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
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
                  OfferView(),
                ],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: CircleNavBar(
              activeIcons: const [
                Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Icon(Icons.menu_book, color: Colors.orangeAccent)),
                Padding(
                    padding: EdgeInsets.only(right: 30),
                    child: Icon(Icons.home, color: Colors.orangeAccent)),
                Padding(
                    padding: EdgeInsets.only(right: 100),
                    child: Icon(Icons.settings, color: Colors.orangeAccent)),
              ],
              inactiveIcons: const [
                Text("Menü"),
                Text("Siparişler"),
                Text("Raporlar"),
              ],
              color: Colors.white,
              height: 60,
              circleWidth: 60,
              activeIndex: _tabIndex,
              onTap: _onTabChanged,
              cornerRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(24),
                bottomLeft: Radius.circular(24),
              ),
              shadowColor: ColorConstants.appbackgroundColor,
              elevation: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomAppbar extends StatelessWidget {
  const _CustomAppbar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 7),
          child: Image.asset(
            'assets/images/logo.png',
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
    );
  }
}
