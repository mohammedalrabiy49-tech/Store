import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/auth_controller.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({Key? key}) : super(key: key);

  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _cleanErrorMessage(String rawError) {
    String error = rawError.toLowerCase();

    if (error.contains('weak-password') || error.contains('weak password')) {
      return 'Password should be at least 6 characters.';
    } else if (error.contains('email-already-in-use') ||
        error.contains('already in use')) {
      return 'This email address is already registered.';
    } else if (error.contains('invalid-email') ||
        error.contains('invalid email')) {
      return 'The email address is invalid.';
    } else if (error.contains('network-request-failed')) {
      return 'Network error. Please check your internet connection.';
    }

    if (rawError.contains(']')) {
      return rawError.split(']').last.trim();
    }

    return rawError;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff0F964A),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign up to get started managing your restaurant',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 30),

                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(
                      Icons.person_outline,
                      color: Color(0xff0F964A),
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),

                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: Color(0xff0F964A),
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),

                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: Color(0xff0F964A),
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 30),

                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff0F964A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      String name = _nameController.text.trim();
                      String email = _emailController.text.trim();
                      String password = _passwordController.text;

                      if (name.isEmpty || email.isEmpty || password.isEmpty) {
                        Get.snackbar(
                          'Error',
                          'Please fill in all fields',
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Colors.redAccent,
                          colorText: Colors.white,
                        );
                        return;
                      }

                      try {
                        await _authController.signUpUser(name, email, password);
                      } catch (e) {
                        String friendlyError = _cleanErrorMessage(e.toString());
                        Get.snackbar(
                          'Sign Up Error',
                          friendlyError,
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Colors.redAccent,
                          colorText: Colors.white,
                        );
                      }
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
