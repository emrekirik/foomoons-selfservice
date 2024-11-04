import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ChartSection extends StatefulWidget {
  final String selectedPeriod;
  final ValueChanged<String> onPeriodChanged;
  final Map<String, int> dailySales;
  const ChartSection(
      {required this.dailySales,
      required this.onPeriodChanged,
      required this.selectedPeriod,
      super.key});

  @override
  State<ChartSection> createState() => _ChartSectionState();
}

class _ChartSectionState extends State<ChartSection> {
  late String dropdownValue;
  int touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    dropdownValue = widget.selectedPeriod;
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    print(widget.dailySales);
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Expanded(
                    child:  ListTile(
                      title: Text(
                        'Hasılat',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      // subtitle:
                      //     Text('Lorem ipsum dolar sit amet, consectetur'),
                      // subtitleTextStyle: TextStyle(
                      //     fontSize: 15,
                      //     color: Colors.grey,
                      //     fontWeight: FontWeight.w300),
                    ),
                  ),
                  Container(
                    width: deviceWidth * 0.2,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(7)),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                      dropdownColor: Colors.grey.shade100,
                      value: dropdownValue,
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.blue,
                      ),
                      iconSize: 24,
                      elevation: 16,
                      style: const TextStyle(color: Colors.black),
                      onChanged: (String? newValue) {
                        setState(() {
                          dropdownValue = newValue!;
                        });
                        widget.onPeriodChanged(newValue!);
                      },
                      items: <String>['Aylık', 'Haftalık', 'Günlük']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    )),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: widget.dailySales.values.isNotEmpty
                        ? widget.dailySales.values
                                .reduce((a, b) => a > b ? a : b) *
                            1.2
                        : 100,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipRoundedRadius: 8,
                        tooltipPadding: const EdgeInsets.all(8),
                        tooltipMargin: 8,
                        fitInsideHorizontally: true,
                        fitInsideVertically: true,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final day =
                              widget.dailySales.keys.elementAt(groupIndex);
                          final price = widget.dailySales[day];
                          return BarTooltipItem(
                            '$day\n',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            children: [
                              TextSpan(
                                text: '$price₺',
                                style: const TextStyle(
                                  color: Colors.yellowAccent,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      touchCallback: (FlTouchEvent event, barTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              barTouchResponse == null ||
                              barTouchResponse.spot == null) {
                            touchedIndex = -1;
                            return;
                          }
                          touchedIndex =
                              barTouchResponse.spot!.touchedBarGroupIndex;
                        });
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            final days = [
                              "Pzt",
                              "Sal",
                              "Çrş",
                              "Prş",
                              "Cum",
                              "Cmt",
                              "Paz"
                            ];
                            return Text(days[value.toInt()]);
                          },
                          reservedSize: 28,
                        ),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: false,
                    ),
                    barGroups: List.generate(
                      widget.dailySales.entries.length,
                      (index) {
                        final entry =
                            widget.dailySales.entries.elementAt(index);
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: entry.value.toDouble(),
                              color: touchedIndex == index
                                  ? Colors.redAccent
                                  : Colors.blue,
                              width: 32,
                              borderSide: touchedIndex == index
                                  ? const BorderSide(
                                      color: Colors.redAccent,
                                      width: 4,
                                    )
                                  : const BorderSide(width: 0),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
