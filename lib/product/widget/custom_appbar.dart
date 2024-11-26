import 'package:foomoons/featured/auth/login_view.dart';
import 'package:foomoons/featured/profile/profile_mobile_view.dart';
import 'package:foomoons/featured/profile/profile_view.dart';
import 'package:foomoons/featured/providers/login_notifier.dart';
import 'package:foomoons/featured/responsive/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _loginProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  return LoginNotifier();
});

class CustomAppbar extends ConsumerWidget {
  final bool showBackButton;
  final bool showDrawer;
  final String userType;
  const CustomAppbar(
      {super.key,
      required this.userType,
      required this.showBackButton,
      required this.showDrawer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sizeWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Container(
        width: sizeWidth * 0.8,
        padding: const EdgeInsets.symmetric(horizontal: 26),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(52),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 7,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                showDrawer == false
                    ? const SizedBox()
                    : IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () {
                          Scaffold.of(context).openDrawer(); // Drawer'ı aç
                        },
                      ),
                showBackButton
                    ? IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back_ios_new))
                    : const SizedBox(),
              ],
            ),
            Image.asset(
              'assets/images/logo.png',
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
            CircleAvatar(
              backgroundColor: Colors.grey[300],
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.person),
                onSelected: (String value) async {
                  // Seçilen değere göre yapılacak işlemler
                  if (value == 'Profile') {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const ResponsiveLayout(
                          desktopBody: ProfileView(),
                          mobileBody: ProfileMobileView()),
                    ));
                  } else if (value == 'Logout') {
                    await ref.watch(_loginProvider.notifier).signOut();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => LoginView(),
                      ),
                    );
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  if (userType == 'kafe')
                    const PopupMenuItem<String>(
                      value: 'Profile',
                      child: Text('Profile'),
                    ),
                  const PopupMenuItem<String>(
                    value: 'Logout',
                    child: Text('Logout'),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
