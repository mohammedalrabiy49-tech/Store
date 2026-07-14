import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/auth_controller.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);

  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.restaurant,
                  size: 80,
                  color: Color(0xff0F964A),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Welcome Back',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 30),

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
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xff0F964A),
                        width: 2,
                      ),
                    ),
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
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xff0F964A),
                        width: 2,
                      ),
                    ),
                  ),
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Get.to(() => const ForgotPasswordScreen()),
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Color(0xff0F964A),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff0F964A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      String email = _emailController.text.trim();
                      String password = _passwordController.text;

                      if (email.isEmpty || password.isEmpty) {
                        Get.snackbar('Error', 'Please fill in all fields');
                        return;
                      }
                      _authController.loginUser(email, password);
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                TextButton(
                  onPressed: () => Get.to(() => SignUpScreen()),
                  child: const Text(
                    "Don't have an account? Register Now",
                    style: TextStyle(
                      color: Color(0xff0F964A),
                      fontWeight: FontWeight.bold,
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
