import 'package:altmisdokuzapp/featured/menu/menu_view.dart';
import 'package:altmisdokuzapp/featured/providers/loading_notifier.dart';
import 'package:altmisdokuzapp/featured/reports/reports_mobile_view.dart';
import 'package:altmisdokuzapp/featured/stock/stock_view.dart';
import 'package:altmisdokuzapp/product/constants/color_constants.dart';
import 'package:altmisdokuzapp/product/utility/firebase/user_firestore_helper.dart';
import 'package:altmisdokuzapp/product/widget/custom_appbar.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:altmisdokuzapp/featured/admin/admin_view.dart';
import 'package:altmisdokuzapp/featured/tables/tables_view.dart';
import 'package:altmisdokuzapp/featured/reports/reports_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TabView extends ConsumerStatefulWidget {
  const TabView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TabViewState();
}

class _TabViewState extends ConsumerState<TabView> {
  int _tabIndex = 2; // Başlangıç sekmesi
  late PageController _pageController;
  final UserFirestoreHelper _userHelper = UserFirestoreHelper();
  Map<String, dynamic>? userDetails;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _tabIndex);
    _loadUserDetails();
  }

  void _onTabChanged(int index) {
    setState(() {
      _tabIndex = index;
      _pageController.jumpToPage(_tabIndex);
    });
  }

  Future<void> _loadUserDetails() async {
    userDetails = await _userHelper.getCurrentUserDetails();
    // Eğer userType garson ise _tabIndex'i 0 yap
    if (userDetails?['userType'] == 'çalışan') {
      setState(() {
        _tabIndex = 0;
        _pageController =
            PageController(initialPage: _tabIndex); // PageController'ı güncelle
      });
    } else {
      setState(() {});
    }
  }

  List<Widget> _buildNavigationItems(String userType, double deviceWidth) {
    // "çalışan" için farklı, "kafe" için farklı sekmeler döndürüyoruz
    if (userType == 'çalışan') {
      return [
        _buildNavItem(Icons.monitor_rounded, 'Siparişler', 0, deviceWidth),
        _buildNavItem(Icons.table_bar_outlined, 'Adisyonlar', 1, deviceWidth),
      ];
    } else if (userType == 'kafe') {
      return [
        _buildNavItem(Icons.restaurant_menu, 'Menu', 0, deviceWidth),
        _buildNavItem(Icons.monitor_rounded, 'Siparişler', 1, deviceWidth),
        _buildNavItem(Icons.table_bar_outlined, 'Adisyonlar', 2, deviceWidth),
        _buildNavItem(Icons.article_outlined, 'Stok', 3, deviceWidth),
        _buildNavItem(
            Icons.insert_chart_outlined_rounded, 'Raporlar', 4, deviceWidth),
      ];
    } else {
      return []; // Desteklenmeyen kullanıcı tipi
    }
  }

  Widget _buildNavItem(
      IconData icon, String label, int index, double deviceWidth) {
    return Column(
      mainAxisAlignment:
          deviceWidth < 600 ? MainAxisAlignment.center : MainAxisAlignment.end,
      children: [
        Icon(icon, size: 30),
        if (_tabIndex != index && deviceWidth >= 600)
          Text(label), // Label sadece seçili değilse gösterilir
      ],
    );
  }

  List<Widget> _buildPageViews(String userType, double deviceWidth) {
    final pages = [
      if (userType == 'kafe') const MenuView(),
      const AdminView(),
      const TablesView(),
      if (userType == 'kafe') const StockView(),
      if (userType == 'kafe')
        deviceWidth < 800 ? const ReportsMobileView() : const ReportsView(),
    ];
    return pages;
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loadingProvider);
    double deviceWidth = MediaQuery.of(context).size.width;

    if (userDetails == null) {
      // Kullanıcı bilgileri yüklenmemişse gösterilecek içerik
      return const Center(child: CircularProgressIndicator());
    }

    final String userType = userDetails?['userType'] ?? '';

    final List<Widget> navigationItems =
        _buildNavigationItems(userType, deviceWidth);
    final List<Widget> pageViews = _buildPageViews(userType, deviceWidth);

    return Column(
      children: [
        if (isLoading)
          const LinearProgressIndicator(
            color: Colors.green,
            minHeight: 4,
          ),
        Expanded(
          child: Scaffold(
            backgroundColor:
                ColorConstants.appbackgroundColor.withOpacity(0.15),
            extendBody: true,
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: CurvedNavigationBar(
                    index: _tabIndex,
                    animationCurve: Curves.fastLinearToSlowEaseIn,
                    animationDuration: const Duration(milliseconds: 800),
                    height: 75,
                    items: navigationItems,
                    backgroundColor:
                        ColorConstants.appbackgroundColor.withOpacity(0.15),
                    onTap: (index) {
                      _onTabChanged(index);
                    },
                  ),
                ),
              ),
            ),
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(70.0),
              child: CustomAppbar(
                userType: userType,
                showDrawer: false,
                showBackButton: false,
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: pageViews,
              ),
            ),
          ),
        ),
      ],
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
