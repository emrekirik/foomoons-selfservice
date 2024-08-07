import 'package:flutter/material.dart';

class AnalysisCard extends StatelessWidget {
  final String cardTitle;
  final String assetImage;
  final String cardSubtitle;
  final Widget subTitleIcon;
  final String cardPiece;
  const AnalysisCard(
      {super.key,
      required this.cardTitle,
      required this.assetImage,
      required this.cardSubtitle,
      required this.subTitleIcon,
      required this.cardPiece});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          )
        ], color: Colors.white, borderRadius: BorderRadius.circular(30)),
        height: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage(assetImage),
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              Expanded(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cardPiece,
                    style: const TextStyle(
                        fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    cardTitle,
                    style: const TextStyle(fontSize: 18),
                  ),
                  ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: subTitleIcon,
                      title: Text(
                        cardSubtitle,
                        style: const TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w300),
                      )),
                ],
              ))
            ],
          ),
        ),
      ),
    );
  }
}
