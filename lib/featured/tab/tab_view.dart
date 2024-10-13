import 'package:altmisdokuzapp/featured/menu/menu_view.dart';
import 'package:altmisdokuzapp/featured/providers/loading_notifier.dart';
import 'package:altmisdokuzapp/featured/stock/stock_view.dart';
import 'package:altmisdokuzapp/product/constants/color_constants.dart';
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

class _TabViewState extends ConsumerState<TabView>
    with SingleTickerProviderStateMixin {
  int _tabIndex = 2; // Başlangıç sekmesi
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loadingProvider);
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
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(30), // Köşe yuvarlama için
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: CurvedNavigationBar(
                    index: _tabIndex,
                    animationCurve: Curves.fastLinearToSlowEaseIn,
                    animationDuration: Duration(milliseconds: 800),
                    height: 75,
                    items: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Icon(
                            Icons.restaurant_menu,
                            size: 30,
                          ),
                          if (_tabIndex != 0) const Text('Menu'),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Icon(
                            Icons.monitor_rounded,
                            size: 30,
                          ),
                          if (_tabIndex != 1) const Text('Siparişler'),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Icon(
                            Icons.table_bar_outlined,
                            size: 30,
                          ),
                          if (_tabIndex != 2) const Text('Adisyonlar'),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Icon(
                            Icons.article_outlined,
                            size: 30,
                          ),
                          if (_tabIndex != 3) const Text('Stok'),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Icon(
                            Icons.insert_chart_outlined_rounded,
                            size: 30,
                          ),
                          if (_tabIndex != 4) const Text('Raporlar'),
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
            appBar: const PreferredSize(
              preferredSize: Size.fromHeight(70.0),
              child: CustomAppbar(
                showBackButton: false,
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _tabIndex = index;
                  });
                },
                children: const [
                  MenuView(),
                  AdminView(),
                  TablesView(),
                  StockView(),
                  ReportsView(),
                ],
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
