import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/screens/auth/login_screen.dart';
import '../home_screen.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late Rx<User?> _user;
  var isLoading = false.obs;

  @override
  void onReady() {
    super.onReady();
    _user = Rx<User?>(_auth.currentUser);
    _user.bindStream(_auth.authStateChanges());
    ever(_user, _setInitialScreen);
  }

  _setInitialScreen(User? user) {
    if (user == null) {
      Get.offAll(() => LoginScreen());
    } else {
      Get.offAll(() => HomeScreen());
    }
  }

  Future<void> signUpUser(String name, String email, String password) async {
    try {
      isLoading.value = true;

      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(name);
        await userCredential.user!.reload();
      }

      isLoading.value = false;

      Get.snackbar(
        'Sucessfuly',
        '   The account has been created successfully.!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      String errorMessage =
          ' An error occurred during registration; please try again later..';

      switch (e.code) {
        case 'weak-password':
          errorMessage =
              'The password is too weak; it must be 6 characters or longer.';
          break;
        case 'email-already-in-use':
          errorMessage = 'This email address is already registered with us.';
          break;
        case 'invalid-email':
          errorMessage = 'The email format is invalid.';
          break;
        case 'network-request-failed':
          errorMessage = 'Please ensure you are connected to the Internet.';
          break;
        default:
          errorMessage = e.message ?? errorMessage;
          if (errorMessage.contains(']')) {
            errorMessage = errorMessage.split(']').last.trim();
          }
      }

      Get.snackbar(
        'Registration error',
        errorMessage,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        '  Unexpected error',
        'Something went wrong; please try again ',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  /// 2. تسجيل الدخول (Sign In / loginUser)
  Future<void> loginUser(String email, String password) async {
    try {
      isLoading.value = true;

      await _auth.signInWithEmailAndPassword(email: email, password: password);

      isLoading.value = false;

      Get.snackbar(
        'Sucssefuly',
        ' Logged in successfully.!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      String errorMessage = ' Login failed .';

      switch (e.code) {
        case 'user-not-found':
          errorMessage =
              'There is no account associated with this email address.';
          break;
        case 'wrong-password':
          errorMessage = 'The password you entered is incorrect.';
          break;
        case 'invalid-email':
          errorMessage = 'The email format is invalid.';
          break;
        default:
          errorMessage = e.message ?? errorMessage;
          if (errorMessage.contains(']')) {
            errorMessage = errorMessage.split(']').last.trim();
          }
      }

      Get.snackbar(
        'Error in Login  ',
        errorMessage,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        '  An unexpected error occurred. .',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  Future<void> signInUser(String email, String password) async {
    await loginUser(email, password);
  }

  /// 3. استعادة كلمة المرور (Reset Password)
  Future<void> resetPassword(String email) async {
    if (email.isEmpty) {
      Get.snackbar(
        'Notice ',
        'Please enter your email address first..',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);

      Get.snackbar(
        ' Sent ',
        '  A password reset link has been sent to your email address .',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = '    Failed to send the reset link..';

      switch (e.code) {
        case 'user-not-found':
          errorMessage =
              ' thereis no account registered with this email address.';
          break;
        case 'invalid-email':
          errorMessage = 'the email format is invalid.';
          break;
        default:
          errorMessage = e.message ?? errorMessage;
          if (errorMessage.contains(']')) {
            errorMessage = errorMessage.split(']').last.trim();
          }
      }

      Get.snackbar(
        'خطأ',
        errorMessage,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error ',
        'An unexpected error occurred; please try again later.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
