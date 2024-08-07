import 'package:altmisdokuzapp/product/widget/analysis_card.dart';
import 'package:altmisdokuzapp/product/widget/chart_section.dart';
import 'package:altmisdokuzapp/product/widget/person_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReportsView extends ConsumerWidget {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sizeWidth = MediaQuery.of(context).size.width;
    final sizeHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        SizedBox(
          height: sizeHeight * 0.01,
        ),
        Expanded(
          flex: 2,  
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const AnalysisCard(
                  assetImage: 'assets/images/coffee_icon.png',
                  cardSubtitle: '4% (son 30 gün)',
                  cardPiece: '56',
                  cardTitle: 'Toplam Ürün',
                  subTitleIcon: Icon(Icons.graphic_eq),
                ),
                SizedBox(
                  width: sizeWidth * 0.015,
                ),
                const AnalysisCard(
                    cardTitle: 'Toplam Hasılat',
                    assetImage: 'assets/images/dolar_icon.png',
                    cardSubtitle: '26% (son 30 gün)',
                    subTitleIcon: Icon(Icons.graphic_eq),
                    cardPiece: '126k'),
                SizedBox(
                  width: sizeWidth * 0.015,
                ),
                const AnalysisCard(
                  assetImage: 'assets/images/order_icon.png',
                  cardSubtitle: '4% (son 30 gün)',
                  cardPiece: '279',
                  cardTitle: 'Toplam Sipariş',
                  subTitleIcon: Icon(Icons.graphic_eq),
                ),
                SizedBox(
                  width: sizeWidth * 0.015,
                ),
                const AnalysisCard(
                  assetImage: 'assets/images/customer_icon.png',
                  cardSubtitle: '4% (son 30 gün)',
                  cardPiece: '65',
                  cardTitle: 'Toplam Müşteri',
                  subTitleIcon: Icon(Icons.graphic_eq),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const PersonSection(),
                SizedBox(
                  width: sizeWidth * 0.015,
                ),
                const ChartSection(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

