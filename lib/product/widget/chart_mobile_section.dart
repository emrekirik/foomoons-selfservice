import 'package:flutter/material.dart';

class ChartMobileSection extends StatefulWidget {
  final String selectedPeriod;
  final ValueChanged<String> onPeriodChanged;
  final Map<String, int> dailySales;

  const ChartMobileSection({
    required this.dailySales,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    super.key,
  });

  @override
  State<ChartMobileSection> createState() => _ChartMobileSectionState();
}

class _ChartMobileSectionState extends State<ChartMobileSection> {
  late String dropdownValue;

  @override
  void initState() {
    super.initState();
    dropdownValue = widget.selectedPeriod;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: ListTile(
                  title: Text(
                    '',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(7),
                  ),
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
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // SizedBox(
        //   height: 200, // Grafik yüksekliği
        //   child: LineChart(
        //     LineChartData(
        //       gridData: FlGridData(
        //         show: true,
        //         drawVerticalLine: true,
        //         horizontalInterval: 1,
        //         verticalInterval: 1,
        //         getDrawingHorizontalLine: (value) {
        //           return const FlLine(
        //             color: Color(0xff37434d),
        //             strokeWidth: 1,
        //           );
        //         },
        //         getDrawingVerticalLine: (value) {
        //           return const FlLine(
        //             color: Color(0xff37434d),
        //             strokeWidth: 1,
        //           );
        //         },
        //       ),
        //       titlesData: FlTitlesData(
        //         bottomTitles: AxisTitles(
        //           sideTitles: SideTitles(
        //             showTitles: true,
        //             getTitlesWidget: (value, meta) {
        //               final index = value.toInt();
        //               final dates = widget.dailySales.keys.toList();
        //               if (index < dates.length) {
        //                 final date = DateTime.parse(dates[index]);
        //                 return Text('${date.day}/${date.month}');
        //               }
        //               return const Text('');
        //             },
        //             interval: 1,
        //             reservedSize: 30,
        //           ),
        //         ),
        //         leftTitles: AxisTitles(
        //           sideTitles: SideTitles(
        //             showTitles: true,
        //             getTitlesWidget: (value, meta) {
        //               // Sadece belirli aralıklarla başlık gösterin
        //               if (value % 100 == 0) {
        //                 return Text('${value.toInt()}',
        //                     style: const TextStyle(fontSize: 10));
        //               }
        //               return const Text(''); // Diğer durumlarda başlık gösterme
        //             },
        //             interval: 200, // 100 birimlik aralıklarla başlıkları göster
        //             reservedSize: 32, // Kenarda daha az boşluk bırakın
        //           ),
        //         ),
        //         topTitles: const AxisTitles(
        //           sideTitles: SideTitles(showTitles: false),
        //         ),
        //         rightTitles: const AxisTitles(
        //           sideTitles: SideTitles(showTitles: false),
        //         ),
        //       ),
        //       borderData: FlBorderData(
        //         show: true,
        //         border: Border.all(color: const Color(0xff37434d)),
        //       ),
        //       minX: 0,
        //       maxX: (widget.dailySales.isNotEmpty
        //               ? widget.dailySales.length - 1
        //               : 1)
        //           .toDouble(),
        //       minY: 0,
        //       maxY: widget.dailySales.isNotEmpty
        //           ? widget.dailySales.values
        //               .reduce((a, b) => a > b ? a : b)
        //               .toDouble()
        //           : 6, // Varsayılan maxY değeri
        //       lineBarsData: [
        //         LineChartBarData(
        //           spots: widget.dailySales.isNotEmpty
        //               ? widget.dailySales.entries
        //                   .toList()
        //                   .asMap()
        //                   .entries
        //                   .map((entry) {
        //                   final index = entry.key.toDouble();
        //                   final value = entry.value.value.toDouble();
        //                   return FlSpot(index, value);
        //                 }).toList()
        //               : [
        //                   FlSpot(0, 0)
        //                 ], // Eğer `dailySales` boşsa varsayılan bir nokta
        //           isCurved: true,
        //           gradient: LinearGradient(
        //             colors: [Colors.blue.withOpacity(0.5), Colors.blueAccent],
        //           ),
        //           barWidth: 3,
        //           isStrokeCapRound: true,
        //           belowBarData: BarAreaData(
        //             show: true,
        //             gradient: LinearGradient(
        //               colors: [
        //                 Colors.blue.withOpacity(0.2),
        //                 Colors.blue.withOpacity(0.1),
        //               ],
        //             ),
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
