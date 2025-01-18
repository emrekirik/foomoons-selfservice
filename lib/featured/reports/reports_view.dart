import 'package:foomoons/featured/providers/reports_notifier.dart';
import 'package:foomoons/product/widget/analysis_card.dart';
import 'package:foomoons/product/widget/chart_section.dart';
import 'package:foomoons/product/widget/person_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  late TimeOfDay startTime;
  late TimeOfDay endTime;
  final String _startTimeKey = 'start_time';
  final String _endTimeKey = 'end_time';
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadSavedTimes();
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  Future<void> _loadSavedTimes() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Varsayılan değerler
    int startHour = 0;
    int startMinute = 0;
    int endHour = 23;
    int endMinute = 59;

    // Kaydedilmiş değerleri al
    if (prefs.containsKey('${_startTimeKey}_hour')) {
      startHour = prefs.getInt('${_startTimeKey}_hour')!;
      startMinute = prefs.getInt('${_startTimeKey}_minute')!;
    } else {
      // İlk kez çalıştığında varsayılan değerleri kaydet
      await prefs.setInt('${_startTimeKey}_hour', startHour);
      await prefs.setInt('${_startTimeKey}_minute', startMinute);
    }

    if (prefs.containsKey('${_endTimeKey}_hour')) {
      endHour = prefs.getInt('${_endTimeKey}_hour')!;
      endMinute = prefs.getInt('${_endTimeKey}_minute')!;
    } else {
      // İlk kez çalıştığında varsayılan değerleri kaydet
      await prefs.setInt('${_endTimeKey}_hour', endHour);
      await prefs.setInt('${_endTimeKey}_minute', endMinute);
    }

    if (mounted) {
      setState(() {
        startTime = TimeOfDay(hour: startHour, minute: startMinute);
        endTime = TimeOfDay(hour: endHour, minute: endMinute);
      });

      // Verileri yükle
      ref.read(_reportsProvider.notifier).fetchAndLoad(
        selectedPeriod,
        startTime: startTime,
        endTime: endTime,
      );
    }
  }

  Future<void> _saveTimeRange(TimeOfDay time, bool isStartTime) async {
    final prefs = await SharedPreferences.getInstance();
    final key = isStartTime ? _startTimeKey : _endTimeKey;
    
    await Future.wait([
      prefs.setInt('${key}_hour', time.hour),
      prefs.setInt('${key}_minute', time.minute),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
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
                  ref.read(_reportsProvider.notifier).fetchAndLoad(
                    selectedPeriod,
                    startTime: startTime,
                    endTime: endTime,
                  );
                },
                dailySales: dailySales,
                startTime: startTime,
                endTime: endTime,
                onStartTimeChanged: (newTime) async {
                  await _saveTimeRange(newTime, true);
                  setState(() {
                    startTime = newTime;
                  });
                  ref.read(_reportsProvider.notifier).fetchAndLoad(
                    selectedPeriod,
                    startTime: newTime,
                    endTime: endTime,
                  );
                },
                onEndTimeChanged: (newTime) async {
                  await _saveTimeRange(newTime, false);
                  setState(() {
                    endTime = newTime;
                  });
                  ref.read(_reportsProvider.notifier).fetchAndLoad(
                    selectedPeriod,
                    startTime: startTime,
                    endTime: newTime,
                  );
                },
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
                  ref.read(_reportsProvider.notifier).fetchAndLoad(
                    selectedPeriod,
                    startTime: startTime,
                    endTime: endTime,
                  );
                },
                dailySales: dailySales,
                startTime: startTime,
                endTime: endTime,
                onStartTimeChanged: (newTime) async {
                  await _saveTimeRange(newTime, true);
                  setState(() {
                    startTime = newTime;
                  });
                  ref.read(_reportsProvider.notifier).fetchAndLoad(
                    selectedPeriod,
                    startTime: newTime,
                    endTime: endTime,
                  );
                },
                onEndTimeChanged: (newTime) async {
                  await _saveTimeRange(newTime, false);
                  setState(() {
                    endTime = newTime;
                  });
                  ref.read(_reportsProvider.notifier).fetchAndLoad(
                    selectedPeriod,
                    startTime: startTime,
                    endTime: newTime,
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
