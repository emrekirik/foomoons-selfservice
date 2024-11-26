import 'package:foomoons/featured/admin/admin_mobile_view.dart';
import 'package:foomoons/featured/menu/menu_mobile_view.dart';
import 'package:foomoons/featured/providers/loading_notifier.dart';
import 'package:foomoons/featured/reports/reports_mobile_view.dart';
import 'package:foomoons/featured/stock/stock_mobile_view.dart';
import 'package:foomoons/featured/tables/tables_mobile_view.dart';
import 'package:foomoons/product/utility/firebase/user_firestore_helper.dart';
import 'package:foomoons/product/widget/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TabMobileView extends ConsumerStatefulWidget {
  const TabMobileView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TabMobileViewState();
}

class _TabMobileViewState extends ConsumerState<TabMobileView>
    with SingleTickerProviderStateMixin {
  int _tabIndex = 2; // Başlangıç sekmesi
  late PageController _pageController;
  NavigationRailLabelType labelType = NavigationRailLabelType.all;
  bool showLeading = false;
  bool showTrailing = false;
  double groupAlignment = -1.0;
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
      _pageController.jumpToPage(
        _tabIndex,
      );
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

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loadingProvider);
    double deviceWidth = MediaQuery.of(context).size.width;
    if (userDetails == null) {
      // Kullanıcı bilgileri yüklenmemişse gösterilecek içerik
      return  const SizedBox();
    }
    final String userType = userDetails?['userType'] ?? '';
    final List<NavigationRailDestination> navigationItems =
        _buildNavigationItems(userType);
    final List<Widget> pageViews = _buildPageViews(userType);

    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            if (isLoading)
              const LinearProgressIndicator(
                color: Colors.green,
                minHeight: 4,
              ),
            Expanded(
              child: Scaffold(
                backgroundColor: Colors.white,
                extendBody: true,
                appBar: PreferredSize(
                  preferredSize: const Size.fromHeight(70.0),
                  child: CustomAppbar(
                    userType: userType,
                    showDrawer: true,
                    showBackButton: false,
                  ),
                ),
                drawer: Drawer(
                  backgroundColor: Colors.white,
                  width: deviceWidth * 0.2,
                  child: NavigationRail(
                      selectedIndex: _tabIndex,
                      groupAlignment: groupAlignment,
                      onDestinationSelected: (int index) {
                        setState(() {
                          _onTabChanged(index);
                        });
                      },
                      labelType: labelType,
                      leading: showLeading
                          ? FloatingActionButton(
                              elevation: 0,
                              onPressed: () {
                                // Add your onPressed code here!
                              },
                              child: const Icon(Icons.add),
                            )
                          : const SizedBox(),
                      trailing: showTrailing
                          ? IconButton(
                              onPressed: () {
                                // Add your onPressed code here!
                              },
                              icon: const Icon(Icons.more_horiz_rounded),
                            )
                          : const SizedBox(),
                      destinations: navigationItems),
                ),
                body: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() {
                        _tabIndex = index;
                      });
                    },
                    children: pageViews),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<NavigationRailDestination> _buildNavigationItems(String userType) {
  if (userType == 'çalışan') {
    return [
      const NavigationRailDestination(
        icon: Icon(Icons.monitor_rounded),
        selectedIcon: Icon(Icons.monitor_rounded),
        label: Text('Siparişler'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.table_bar_outlined),
        selectedIcon: Icon(Icons.table_bar_outlined),
        label: Text('Adisyonlar'),
      ),
    ];
  } else if (userType == 'kafe') {
    return [
      const NavigationRailDestination(
        icon: Icon(Icons.restaurant_menu_sharp),
        selectedIcon: Icon(Icons.restaurant_menu),
        label: Text('Menu'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.monitor_rounded),
        selectedIcon: Icon(Icons.monitor_rounded),
        label: Text('Siparişler'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.table_bar_outlined),
        selectedIcon: Icon(Icons.table_bar_outlined),
        label: Text('Adisyonlar'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.article_outlined),
        selectedIcon: Icon(Icons.article_outlined),
        label: Text('Stok'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.insert_chart_outlined_rounded),
        selectedIcon: Icon(Icons.insert_chart_outlined_rounded),
        label: Text('Raporlar'),
      ),
    ];
  } else {
    return [];
  }
}

List<Widget> _buildPageViews(String userType) {
  final pages = [
    if (userType == 'kafe') const MenuMobileView(),
    const AdminMobileView(),
    const TablesMobileView(),
    if (userType == 'kafe') const StockMobileView(),
    if (userType == 'kafe') const ReportsMobileView()
  ];
  return pages;
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
