import 'package:altmisdokuzapp/featured/auth/login_view.dart';
import 'package:altmisdokuzapp/featured/responsive/responsive_layout.dart';
import 'package:altmisdokuzapp/featured/tab/tab_mobile_view.dart';
import 'package:altmisdokuzapp/featured/tab/tab_view.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Kullanıcı oturum açmışsa TabView sayfasına yönlendirin
      return const ResponsiveLayout(desktopBody: TabView(), mobileBody: TabMobileView());
    } else {
      // Kullanıcı oturum açmamışsa SignInView sayfasına yönlendirin
      return LoginView();
    }
  }
}
