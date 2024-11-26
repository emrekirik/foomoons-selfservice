import 'package:foomoons/featured/providers/reports_notifier.dart';
import 'package:foomoons/product/widget/analysis_card.dart';
import 'package:foomoons/product/widget/chart_section.dart';
import 'package:foomoons/product/widget/person_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _reportsProvider =
    StateNotifierProvider<ReportsNotifier, ReportsState>((ref) {
  return ReportsNotifier(ref);
});

class ReportsView extends ConsumerStatefulWidget {
  const ReportsView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ReportsViewState();
}

class _ReportsViewState extends ConsumerState<ReportsView> {
  String selectedPeriod = 'Günlük';

  @override
  void initState() {
    super.initState();

    // Verileri sayfa yüklendiğinde çekiyoruz
    Future.microtask(() {
      ref.read(_reportsProvider.notifier).fetchAndLoad(selectedPeriod);
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
            child: sizeWidth < 1200
                ? gridAnalysisCard(reportsState, sizeWidth, employees,
                    constraints, yourDailSalesData)
                : reportsContent(
                    reportsState, sizeWidth, constraints, yourDailSalesData));
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
        Expanded(
          flex: 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              AnalysisCard(
                assetImage: 'assets/images/cash.png',
                cardSubtitle: selectedPeriod,
                cardPiece: '${reportsState.totalCash}₺',
                cardTitle: 'Nakit Ödeme',
                subTitleIcon: const Icon(Icons.graphic_eq),
              ),
              SizedBox(
                width: sizeWidth * 0.015,
              ),
              AnalysisCard(
                  cardTitle: 'Toplam Hasılat',
                  assetImage: 'assets/images/dolar_icon.png',
                  cardSubtitle: selectedPeriod,
                  subTitleIcon: const Icon(Icons.graphic_eq),
                  cardPiece: reportsState.totalRevenues.toString()),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AnalysisCard(
                  assetImage: 'assets/images/order_icon.png',
                  cardSubtitle: selectedPeriod,
                  cardPiece: reportsState.totalOrder.toString(),
                  cardTitle: 'Toplam Sipariş',
                  subTitleIcon: const Icon(Icons.graphic_eq),
                ),
                SizedBox(
                  width: sizeWidth * 0.015,
                ),
                AnalysisCard(
                  assetImage: 'assets/images/credit.png',
                  cardSubtitle: selectedPeriod,
                  cardPiece: '${reportsState.totalCredit}₺',
                  cardTitle: 'Kredi ile Ödeme',
                  subTitleIcon: const Icon(Icons.graphic_eq),
                ),
              ],
            )),
        const SizedBox(height: 20),
        Expanded(
          flex: 6,
          child: // sizeWidth < 800
              //     ? Column(
              //         mainAxisSize: MainAxisSize.min,
              //         children: [
              //           PersonMobileSection(
              //             employees: employees,
              //             constraints: constraints,
              //           ),
              //           const SizedBox(height: 20),
              //           const ChartSection(),
              //         ],
              //       )
              //     :
              Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              PersonSection(
                constraints: constraints,
              ),
              const SizedBox(
                width: 20,
              ),
              ChartSection(
                selectedPeriod: selectedPeriod,
                onPeriodChanged: (newPeriod) {
                  setState(() {
                    selectedPeriod = newPeriod;
                  });
                  ref.read(_reportsProvider.notifier).fetchAndLoad(newPeriod);
                },
                dailySales: dailySales,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Column reportsContent(ReportsState reportsState, double sizeWidth,
      BoxConstraints constraints, Map<String, int> dailySales) {
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              AnalysisCard(
                assetImage: 'assets/images/cash.png',
                cardSubtitle: selectedPeriod,
                cardPiece: '${reportsState.totalCash}₺',
                cardTitle: 'Nakit Ödeme',
                subTitleIcon: const Icon(Icons.graphic_eq),
              ),
              SizedBox(
                width: sizeWidth * 0.015,
              ),
              AnalysisCard(
                  cardTitle: 'Hasılat',
                  assetImage: 'assets/images/dolar_icon.png',
                  cardSubtitle: selectedPeriod,
                  subTitleIcon: const Icon(Icons.graphic_eq),
                  cardPiece: '${reportsState.totalRevenues}₺'),
              SizedBox(
                width: sizeWidth * 0.015,
              ),
              AnalysisCard(
                assetImage: 'assets/images/order_icon.png',
                cardSubtitle: selectedPeriod,
                cardPiece: reportsState.totalOrder.toString(),
                cardTitle: 'Sipariş',
                subTitleIcon: const Icon(Icons.graphic_eq),
              ),
              SizedBox(
                width: sizeWidth * 0.015,
              ),
              AnalysisCard(
                assetImage: 'assets/images/credit.png',
                cardSubtitle: selectedPeriod,
                cardPiece: '${reportsState.totalCredit}₺',
                cardTitle: 'Kredi ile Ödeme',
                subTitleIcon: const Icon(Icons.graphic_eq),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          flex: 6,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              PersonSection(
                constraints: constraints,
              ),
              const SizedBox(
                width: 20,
              ),
              ChartSection(
                selectedPeriod: selectedPeriod,
                onPeriodChanged: (newPeriod) {
                  setState(() {
                    selectedPeriod = newPeriod;
                  });
                  ref.read(_reportsProvider.notifier).fetchAndLoad(newPeriod);
                },
                dailySales: dailySales,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
