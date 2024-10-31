import 'package:altmisdokuzapp/featured/providers/reports_notifier.dart';
import 'package:altmisdokuzapp/product/widget/analysys_card_mobile.dart';
import 'package:altmisdokuzapp/product/widget/chart_mobile_section.dart';
import 'package:altmisdokuzapp/product/widget/person_mobile_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _reportsProvider =
    StateNotifierProvider<ReportsNotifier, ReportsState>((ref) {
  return ReportsNotifier(ref);
});

class ReportsMobileView extends ConsumerStatefulWidget {
  const ReportsMobileView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ReportsMobileViewState();
}

class _ReportsMobileViewState extends ConsumerState<ReportsMobileView> {
  String selectPeriod = 'Günlük';
  @override
  void initState() {
    super.initState();

    // Verileri sayfa yüklendiğinde çekiyoruz
    Future.microtask(() {
      ref.read(_reportsProvider.notifier).fetchAndLoad(selectPeriod);
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportsState = ref.watch(_reportsProvider);
    final employees = reportsState.employees;
    final sizeWidth = MediaQuery.of(context).size.width;
    final yourDailSalesData = ref.watch(_reportsProvider).dailySales;
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16), color: Colors.white),
              child: SingleChildScrollView(
                child: gridAnalysisCard(reportsState, sizeWidth, employees,
                    constraints, yourDailSalesData),
              ),
            ));
      },
    );
  }

  Column gridAnalysisCard(
      ReportsState reportsState,
      double sizeWidth,
      List<Map<String, dynamic>> employees,
      BoxConstraints constraints,
      Map<String, int> dailySales) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            AnalysysCardMobile(
              assetImage: 'assets/images/coffee_icon.png',
              cardSubtitle: selectPeriod,
              cardPiece: reportsState.totalProduct.toString(),
              cardTitle: 'Toplam Ürün',
              subTitleIcon: const Icon(Icons.graphic_eq),
            ),
            SizedBox(
              width: sizeWidth * 0.015,
            ),
            AnalysysCardMobile(
                cardTitle: 'Toplam Hasılat',
                assetImage: 'assets/images/dolar_icon.png',
                cardSubtitle: selectPeriod,
                subTitleIcon: const Icon(Icons.graphic_eq),
                cardPiece: reportsState.totalRevenues.toString()),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            AnalysysCardMobile(
              assetImage: 'assets/images/order_icon.png',
              cardSubtitle: selectPeriod,
              cardPiece: reportsState.totalOrder.toString(),
              cardTitle: 'Toplam Sipariş',
              subTitleIcon: const Icon(Icons.graphic_eq),
            ),
            SizedBox(
              width: sizeWidth * 0.015,
            ),
             AnalysysCardMobile(
              assetImage: 'assets/images/customer_icon.png',
              cardSubtitle: selectPeriod,
              cardPiece: '65',
              cardTitle: 'Toplam Müşteri',
              subTitleIcon: const Icon(Icons.graphic_eq),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ChartMobileSection(
              selectedPeriod: selectPeriod,
              onPeriodChanged: (newPeriod) {
                setState(() {
                  selectPeriod = newPeriod;
                });
                ref.read(_reportsProvider.notifier).fetchAndLoad(newPeriod);
              },
              dailySales: dailySales,
            ),
            const SizedBox(height: 20),
            PersonMobileSection(
              employees: employees,
              constraints: constraints,
            ),
          ],
        )
      ],
    );
  }
}
