import 'package:altmisdokuzapp/featured/providers/login_notifier.dart';
import 'package:altmisdokuzapp/featured/responsive/responsive_layout.dart';
import 'package:altmisdokuzapp/featured/tab/tab_mobile_view.dart';
import 'package:altmisdokuzapp/featured/tab/tab_view.dart';
import 'package:altmisdokuzapp/product/constants/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

final _loginProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  return LoginNotifier();
});

class LoginView extends ConsumerWidget {
  LoginView({super.key});

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;

    final loginNotifier = ref.watch(_loginProvider.notifier);
    final loginState = ref.watch(_loginProvider);
    final showPassword = ValueNotifier(false);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: ColorConstants.thirdColor,
      body: deviceHeight > 500
          ? _LoginContent(
              deviceWidth: deviceWidth,
              emailController: emailController,
              showPassword: showPassword,
              passwordController: passwordController,
              loginNotifier: loginNotifier,
              loginState: loginState,
            )
          : SingleChildScrollView(
              child: _LoginContent(
                deviceWidth: deviceWidth,
                emailController: emailController,
                showPassword: showPassword,
                passwordController: passwordController,
                loginNotifier: loginNotifier,
                loginState: loginState,
              ),
            ),
    );
  }
}

class _LoginContent extends StatelessWidget {
  const _LoginContent({
    super.key,
    required this.deviceWidth,
    required this.emailController,
    required this.showPassword,
    required this.passwordController,
    required this.loginNotifier,
    required this.loginState,
  });

  final double deviceWidth;
  final TextEditingController emailController;
  final ValueNotifier<bool> showPassword;
  final TextEditingController passwordController;
  final LoginNotifier loginNotifier;
  final LoginState loginState;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: deviceWidth < 350 ? deviceWidth < 280 ? 16/30: 16/25: 16 / 20,
        child: Container(
          height: deviceWidth < 600 ? double.infinity : null,
          decoration: BoxDecoration(
            color: ColorConstants.white,
            borderRadius: BorderRadius.circular(30),
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
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 30,
              ),
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  height: deviceWidth * 0.1,
                  fit: BoxFit.cover,
                ),
              ),
              Center(
                child: Text(
                  "FOO Moons'da oturum aç",
                  style: GoogleFonts.ubuntu(
                    textStyle: TextStyle(
                        fontSize: deviceWidth < 600 ? 24 : 30,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(
                height: deviceWidth * 0.03,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: deviceWidth * 0.1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Email',
                      style: GoogleFonts.ubuntu(
                        textStyle: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
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
                      child: TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 24.0),
                          hintText: 'Enter your email',
                          fillColor: Colors.white, // Arka plan rengi
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: const BorderSide(
                              color: Colors
                                  .white, // Normalde (aktifken) çerçeve rengi
                              width: 2.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: const BorderSide(
                              color: Colors
                                  .white, // Odaklanıldığında çerçeve rengi
                              width: 2.0,
                            ),
                          ),
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'Şifre',
                      style: GoogleFonts.ubuntu(
                        textStyle: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                        decoration: BoxDecoration(
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
                        child: ValueListenableBuilder(
                          valueListenable: showPassword,
                          builder: (context, value, child) {
                            return TextField(
                              controller: passwordController,
                              obscureText: !value,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.only(
                                    bottom: 28, right: 4, top: 12),
                                hintText: 'Enter your password',
                                fillColor: Colors.white, // Arka plan rengi
                                filled: true,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: const BorderSide(
                                    color: Colors
                                        .white, // Normalde (aktifken) çerçeve rengi
                                    width: 2.0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: const BorderSide(
                                    color: Colors
                                        .white, // Odaklanıldığında çerçeve rengi
                                    width: 2.0,
                                  ),
                                ),
                                prefixIcon: const Icon(Icons.password),
                                suffix: InkWell(
                                  onTap: () {
                                    showPassword.value = !showPassword.value;
                                  },
                                  child: Icon(
                                    value
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                          },
                        )),
                    SizedBox(
                      height: deviceWidth * 0.1,
                    ),
                    Center(
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorConstants.secondColor,
                          ),
                          onPressed: loginState.isLoading
                              ? null
                              : () async {
                                  final message = await loginNotifier.login(
                                    email: emailController.text,
                                    password: passwordController.text,
                                  );

                                  if (message!.contains('Success')) {
                                    Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const ResponsiveLayout(
                                                    desktopBody: TabView(),
                                                    mobileBody:
                                                        TabMobileView())));
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(message),
                                    ),
                                  );
                                },
                          child: const Text(
                            'Giriş Yap',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
