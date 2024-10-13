import 'package:altmisdokuzapp/featured/auth/login_view.dart';
import 'package:altmisdokuzapp/featured/profile/profile_view.dart';
import 'package:altmisdokuzapp/featured/providers/login_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



final _loginProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  return LoginNotifier(ref: ref);
});


class CustomAppbar extends ConsumerWidget {
  final bool showBackButton;
  const CustomAppbar({super.key, required this.showBackButton});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      automaticallyImplyLeading: showBackButton,
      leading: showBackButton
          ? IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back_ios))
          : SizedBox(),
      flexibleSpace: Container(
        margin: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(70),
            bottomRight: Radius.circular(70),
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
      ),
      title: Padding(
        padding: const EdgeInsets.only(top: 7),
        child: Image.asset(
          'assets/images/logo.png',
          width: 80,
          height: 80,
          fit: BoxFit.cover,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 400),
          child: CircleAvatar(
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
          ),
        )
      ],
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }
}
