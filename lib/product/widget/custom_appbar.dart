import 'package:altmisdokuzapp/featured/auth/login_view.dart';
import 'package:altmisdokuzapp/featured/profile/profile_view.dart';
import 'package:altmisdokuzapp/featured/providers/login_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _loginProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  return LoginNotifier();
});

class CustomAppbar extends ConsumerWidget {
  final bool showBackButton;
  const CustomAppbar({super.key, required this.showBackButton});

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
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            showBackButton ? IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back_ios_new)): const SizedBox(),
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
                      builder: (context) => ProfileView(),
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
