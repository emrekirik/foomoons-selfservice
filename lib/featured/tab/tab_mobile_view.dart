import 'package:altmisdokuzapp/featured/admin/admin_mobile_view.dart';
import 'package:altmisdokuzapp/featured/menu/menu_mobile_view.dart';
import 'package:altmisdokuzapp/featured/providers/loading_notifier.dart';
import 'package:altmisdokuzapp/featured/reports/reports_mobile_view.dart';
import 'package:altmisdokuzapp/featured/stock/stock_mobile_view.dart';
import 'package:altmisdokuzapp/featured/tables/tables_mobile_view.dart';
import 'package:altmisdokuzapp/product/utility/firebase/user_firestore_helper.dart';
import 'package:altmisdokuzapp/product/widget/custom_appbar.dart';
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
    _loadUserDetails();
    _pageController = PageController(initialPage: _tabIndex);
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
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loadingProvider);
    final String userType = userDetails?['userType'] ?? '';
    double deviceWidth = MediaQuery.of(context).size.width;
    return Column(
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
              preferredSize: Size.fromHeight(70.0),
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
                destinations: const <NavigationRailDestination>[
                  NavigationRailDestination(
                    icon: Icon(Icons.restaurant_menu_sharp),
                    selectedIcon: Icon(Icons.restaurant_menu),
                    label: Text('Menu'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.monitor_rounded),
                    selectedIcon: Icon(Icons.monitor_rounded),
                    label: Text('Siparişler'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.table_bar_outlined),
                    selectedIcon: Icon(Icons.table_bar_outlined),
                    label: Text('Adisyonlar'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.article_outlined),
                    selectedIcon: Icon(Icons.article_outlined),
                    label: Text('Stok'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.insert_chart_outlined_rounded),
                    selectedIcon: Icon(Icons.insert_chart_outlined_rounded),
                    label: Text('Raporlar'),
                  ),
                ],
              ),
            ),
            body: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _tabIndex = index;
                });
              },
              children: const [
                MenuMobileView(),
                AdminMobileView(),
                TablesMobileView(),
                StockMobileView(),
                ReportsMobileView()
              ],
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
