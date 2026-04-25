import 'package:flutter/material.dart';
import 'package:lenpay/l10n/app_localizations.dart';
import 'package:lenpay/ui/auth/email_verification.dart';
import 'package:lenpay/ui/auth/signup.dart';
import 'package:lenpay/ui/navbar/navbar.dart';
import 'package:lenpay/util/route_transitions.dart';
import 'package:lenpay/widget/custom_snackbar.dart';
import 'package:lenpay/widget/interactive_button.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      CustomSnackbar.show(
        context,
        message: 'Please fill in all fields'.tr(context),
        type: SnackbarType.info,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Authenticate with Firebase with timeout
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password)
          .timeout(const Duration(seconds: 30));

      final User? user = userCredential.user;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'Unable to sign in user.',
        );
      }

      if (!user.emailVerified) {
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          AppRoutes.fade(
            page: EmailVerificationPage(
              email: email,
              password: password,
              name: user.displayName,
            ),
          ),
          (route) => false,
        );
        return;
      }

      // 2. Save Logged In state
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      if (!mounted) return;

      // 3. Navigate to Dashboard
      Navigator.pushAndRemoveUntil(
        context,
        AppRoutes.fade(page: const MainNavigation()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String message = "An error occurred";
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.'.tr(context);
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided.'.tr(context);
      } else if (e.code == 'invalid-email') {
        message = 'The email address is badly formatted.'.tr(context);
      }
      CustomSnackbar.show(context, message: message, type: SnackbarType.error);
    } on TimeoutException {
      CustomSnackbar.show(
        context,
        message: 'Connection timeout. Please check your internet connection.'
            .tr(context),
        type: SnackbarType.error,
      );
    } catch (e) {
      CustomSnackbar.show(
        context,
        message: "Error: ${e.toString()}",
        type: SnackbarType.error,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // 1. Logo/Icon Header
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 80,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Welcome Back'.tr(context),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Sign in to your account to continue'.tr(context),
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),

              const SizedBox(height: 40),

              // 2. Email Field
              _buildLabel('Email Address'.tr(context)),
              _buildInputField(
                controller: _emailController,
                hint: 'example@gmail.com'.tr(context),
                icon: Icons.alternate_email_rounded,
                isDark: isDark,
              ),

              const SizedBox(height: 25),

              // 3. Password Field
              _buildLabel('Password'.tr(context)),
              _buildInputField(
                controller: _passwordController,
                hint: '********'.tr(context),

                icon: Icons.lock_outline_rounded,
                isDark: isDark,
                obscure: _obscurePassword,
                suffix: IconButton(
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.grey,
                  ),
                ),
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text('Forgot Password?'.tr(context)),
                ),
              ),

              const SizedBox(height: 30),

              // 4. Login Button
              InteractiveButton(
                text: 'Sign In'.tr(context),
                isLoading: _isLoading,
                onPressed: _handleLogin,
                color: Colors.blueAccent,
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account?".tr(context)),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      AppRoutes.slideUp(page: const SignUp()),
                    ),
                    child: Text(
                      'Sign Up'.tr(context),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    bool obscure = false,
    Widget? suffix,
  }) {
    return Center(
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1C1F2E)
              : Colors.grey.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white10
                : Colors.black.withValues(alpha: 0.05),
          ),
        ),
        child: TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.blueAccent, size: 22),
            suffixIcon: suffix,
            border: InputBorder.none,
            hintText: hint,
          ),
        ),
      ),
    );
  }
}
