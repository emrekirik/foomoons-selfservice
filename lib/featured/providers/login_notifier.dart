import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';


class LoginNotifier extends StateNotifier<LoginState> {
  final FirebaseAuth _auth;
// Change Reader to Ref

  LoginNotifier({
    FirebaseAuth? auth,
    required Ref ref, // Change Reader to Ref
  })  : _auth = auth ?? FirebaseAuth.instance,
        super(LoginState());

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );


      return 'Success';
    } on FirebaseAuthException catch (e) {
      if (email.isEmpty || password.isEmpty) {
        return 'E-posta ya da şifre alanı boş bırakılamaz';
      } else {
        if (e.code == 'user-not-found') {
          return 'Bu e-posta için kullanıcı bulunamadı.';
        } else if (e.code == 'wrong-password') {
          return 'Bu kullanıcı için yanlış şifre girildi.';
        } else if (e.code == 'invalid-email') {
          return 'Geçersiz e-posta formatı.';
        } else if (e.code == 'invalid-credential') {
          return 'Sağlanan kimlik bilgileri geçersiz';
        } else if (e.code == 'wrong-password') {
          return 'Girilen şifre yanlış';
        } else {
          return e.message;
        }
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  void toggleObscureText() {
    state = state.copyWith(isObscured: !state.isObscured);
  }
}

class LoginState {
  final bool isLoading;
  final bool isObscured;

  LoginState({
    this.isLoading = false,
    this.isObscured = true,
  });

  LoginState copyWith({
    String? errorMessage,
    bool? isLoading,
    bool? isObscured,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      isObscured: isObscured ?? this.isObscured,
    );
  }
}
