import 'package:altmisdokuzapp/product/constants/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:circle_nav_bar/circle_nav_bar.dart';
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
      _pageController.jumpToPage(_tabIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.appbackgroundColor.withOpacity(0.15),
      extendBody: true,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: _CustomAppbar(),
      ),
      body: Column(
        children: [
          Expanded(
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 34),
            child: CircleNavBar(
              activeIcons: const [
                Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: Icon(Icons.menu_book, color: ColorConstants.appbackgroundColor),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 200),
                  child: Icon(Icons.home, color: ColorConstants.appbackgroundColor),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 100),
                  child: Icon(Icons.settings, color: ColorConstants.appbackgroundColor),
                ),
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
              shadowColor: ColorConstants.black.withOpacity(0.5),
              elevation: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomAppbar extends StatelessWidget  {
  const _CustomAppbar();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.20),
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
              offset: Offset(0, 3),
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
