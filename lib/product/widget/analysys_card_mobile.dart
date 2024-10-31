import 'package:altmisdokuzapp/featured/providers/loading_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnalysysCardMobile extends ConsumerWidget {
  final String cardTitle;
  final String assetImage;
  final String cardSubtitle;
  final Widget subTitleIcon;
  final String cardPiece;

  const AnalysysCardMobile(
      {super.key,
      required this.cardTitle,
      required this.assetImage,
      required this.cardSubtitle,
      required this.subTitleIcon,
      required this.cardPiece});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(loadingProvider);
    final deviceWidth = MediaQuery.of(context).size.width;
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            deviceWidth < 850
                ? const SizedBox()
                : Expanded(
                    child: Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage(assetImage),
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
            isLoading
                ? const SizedBox()
                : Expanded(
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
                    ),
                  )
          ],
        ),
      ),
    );
  }
}
