// import 'package:altmisdokuzapp/featured/providers/reports_notifier.dart';
// import 'package:altmisdokuzapp/product/widget/analysis_card.dart';
// import 'package:altmisdokuzapp/product/widget/chart_section.dart';
// import 'package:altmisdokuzapp/product/widget/person_mobile_section.dart';
// import 'package:altmisdokuzapp/product/widget/person_section.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// final _reportsProvider =
//     StateNotifierProvider<ReportsNotifier, ReportsState>((ref) {
//   return ReportsNotifier(ref);
// });

// class ReportsView extends ConsumerStatefulWidget {
//   const ReportsView({super.key});

//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() => _ReportsViewState();
// }

// class _ReportsViewState extends ConsumerState<ReportsView> {
//   String selectedPeriod = 'Günlük';
//   @override
//   void initState() {
//     super.initState();

//     // Verileri sayfa yüklendiğinde çekiyoruz
//     Future.microtask(() {
//       ref.read(_reportsProvider.notifier).fetchAndLoad();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final reportsState = ref.watch(_reportsProvider);
//     final employees = reportsState.employees;
//     final sizeWidth = MediaQuery.of(context).size.width;
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         return Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//             child: sizeWidth < 1200
//                 ? gridAnalysisCard(
//                     reportsState, sizeWidth, employees, constraints)
//                 : reportsContent(
//                     reportsState, sizeWidth, employees, constraints));
//       },
//     );
//   }

//   Column gridAnalysisCard(ReportsState reportsState, double sizeWidth,
//       List<Map<String, dynamic>> employees, BoxConstraints constraints) {
//     return Column(
//       children: [
//         Expanded(
//           flex: 2,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               AnalysisCard(
//                 assetImage: 'assets/images/coffee_icon.png',
//                 cardSubtitle: '4% (son 30 gün)',
//                 cardPiece: reportsState.totalProduct.toString(),
//                 cardTitle: 'Toplam Ürün',
//                 subTitleIcon: const Icon(Icons.graphic_eq),
//               ),
//               SizedBox(
//                 width: sizeWidth * 0.015,
//               ),
//               AnalysisCard(
//                   cardTitle: 'Toplam Hasılat',
//                   assetImage: 'assets/images/dolar_icon.png',
//                   cardSubtitle: '26% (son 30 gün)',
//                   subTitleIcon: const Icon(Icons.graphic_eq),
//                   cardPiece: reportsState.totalRevenues.toString()),
//             ],
//           ),
//         ),
//         const SizedBox(height: 20),
//         Expanded(
//             flex: 2,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 AnalysisCard(
//                   assetImage: 'assets/images/order_icon.png',
//                   cardSubtitle: '4% (son 30 gün)',
//                   cardPiece: reportsState.totalOrder.toString(),
//                   cardTitle: 'Toplam Sipariş',
//                   subTitleIcon: const Icon(Icons.graphic_eq),
//                 ),
//                 SizedBox(
//                   width: sizeWidth * 0.015,
//                 ),
//                 const AnalysisCard(
//                   assetImage: 'assets/images/customer_icon.png',
//                   cardSubtitle: '4% (son 30 gün)',
//                   cardPiece: '65',
//                   cardTitle: 'Toplam Müşteri',
//                   subTitleIcon: Icon(Icons.graphic_eq),
//                 ),
//               ],
//             )),
//         const SizedBox(height: 20),
//         Expanded(
//           flex: 6,
//           child: // sizeWidth < 800
//               //     ? Column(
//               //         mainAxisSize: MainAxisSize.min,
//               //         children: [
//               //           PersonMobileSection(
//               //             employees: employees,
//               //             constraints: constraints,
//               //           ),
//               //           const SizedBox(height: 20),
//               //           const ChartSection(),
//               //         ],
//               //       )
//               //     :
//               Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               PersonSection(
//                 employees: employees,
//                 constraints: constraints,
//               ),
//               const SizedBox(
//                 width: 20,
//               ),
//               const ChartSection(),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Column reportsContent(ReportsState reportsState, double sizeWidth,
//       List<Map<String, dynamic>> employees, BoxConstraints constraints) {
//     return Column(
//       children: [
//         Expanded(
//           flex: 2,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               AnalysisCard(
//                 assetImage: 'assets/images/coffee_icon.png',
//                 cardSubtitle: '4% (son 30 gün)',
//                 cardPiece: reportsState.totalProduct.toString(),
//                 cardTitle: 'Toplam Ürün',
//                 subTitleIcon: const Icon(Icons.graphic_eq),
//               ),
//               SizedBox(
//                 width: sizeWidth * 0.015,
//               ),
//               AnalysisCard(
//                   cardTitle: 'Toplam Hasılat',
//                   assetImage: 'assets/images/dolar_icon.png',
//                   cardSubtitle: '26% (son 30 gün)',
//                   subTitleIcon: const Icon(Icons.graphic_eq),
//                   cardPiece: reportsState.totalRevenues.toString()),
//               SizedBox(
//                 width: sizeWidth * 0.015,
//               ),
//               AnalysisCard(
//                 assetImage: 'assets/images/order_icon.png',
//                 cardSubtitle: '4% (son 30 gün)',
//                 cardPiece: reportsState.totalOrder.toString(),
//                 cardTitle: 'Toplam Sipariş',
//                 subTitleIcon: const Icon(Icons.graphic_eq),
//               ),
//               SizedBox(
//                 width: sizeWidth * 0.015,
//               ),
//               const AnalysisCard(
//                 assetImage: 'assets/images/customer_icon.png',
//                 cardSubtitle: '4% (son 30 gün)',
//                 cardPiece: '65',
//                 cardTitle: 'Toplam Müşteri',
//                 subTitleIcon: Icon(Icons.graphic_eq),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 20),
//         Expanded(
//           flex: 6,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               PersonSection(
//                 constraints: constraints,
//                 employees: employees,
//               ),
//               const SizedBox(
//                 width: 20,
//               ),
//               const ChartSection(),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
