import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lenpay/l10n/app_localizations.dart';
import 'package:lenpay/data/firebase_service.dart';
import 'package:lenpay/ui/auth/email_verification.dart';
import 'package:lenpay/util/route_transitions.dart';
import 'package:lenpay/widget/custom_snackbar.dart';
import 'package:lenpay/widget/interactive_button.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  final FirebaseService _firebaseService = FirebaseService();

  Future<void> _handleSignUp() async {
    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim();
    final String phone = _phoneController.text.trim();
    final String password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      CustomSnackbar.show(
        context,
        message: 'Please fill in all fields'.tr(context),
        type: SnackbarType.info,
      );
      return;
    }

    if (!phone.startsWith('+')) {
      CustomSnackbar.show(
        context,
        message: 'Phone number must start with country code (e.g., +20)'.tr(
          context,
        ),
        type: SnackbarType.error,
      );
      return;
    }

    if (password.length < 6) {
      CustomSnackbar.show(
        context,
        message: 'Password must be at least 6 characters.'.tr(context),
        type: SnackbarType.error,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      if (userCredential.user == null) {
        throw FirebaseAuthException(
          code: 'unknown-error',
          message: 'Unable to create user account.',
        );
      }

      await userCredential.user!.updateDisplayName(name);

      if (!mounted) return;

      // Initialize user data in Firestore with error handling
      try {
        await _firebaseService.initializeUserData(
          uid: userCredential.user!.uid,
          name: name,
          email: email,
          phone: phone,
        );
      } catch (e) {
        debugPrint('Firestore initializeUserData error: $e');
        if (mounted) {
          CustomSnackbar.show(
            context,
            message:
                'Account created, but failed to save profile data. Please check your internet connection or Firebase Console setup.'
                    .tr(context),
            type: SnackbarType.error,
          );
        }
      }

      if (!mounted) return;

      // Stop loading before navigation
      setState(() => _isLoading = false);

      CustomSnackbar.show(
        context,
        message: 'Account created successfully. Verification code sent.'.tr(
          context,
        ),
        type: SnackbarType.success,
      );

      Navigator.pushAndRemoveUntil(
        context,
        AppRoutes.fade(
          page: EmailVerificationPage(
            email: email,
            password: password,
            name: name,
          ),
        ),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String message = "An error occurred";
      if (e.code == 'weak-password') {
        message = 'Password is too weak.'.tr(context);
      } else if (e.code == 'email-already-in-use') {
        message = 'Email already in use.'.tr(context);
      } else if (e.code == 'invalid-email') {
        message = 'Please enter a valid email address.'.tr(context);
      } else if (e.code == 'operation-not-allowed') {
        message = 'Email sign-up is not enabled.'.tr(context);
      } else if (e.code == 'network-request-failed' || e.code == 'timeout') {
        message = 'Connection timeout. Please check your internet connection.'
            .tr(context);
      } else if (e.message != null && e.message!.isNotEmpty) {
        message = e.message!;
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
        message: 'Error: ${e.toString()}',
        type: SnackbarType.error,
      );
    } finally {
      // Only reset loading if still loading (avoids setState after navigation)
      if (mounted && _isLoading) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create Account'.tr(context),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Join LenPay and start managing your finances easily'.tr(
                  context,
                ),
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 40),
              const SizedBox(height: 20),

              _buildLabel('Full Name'.tr(context)),
              _buildInputField(
                controller: _nameController,
                hint: 'John Doe'.tr(context),
                icon: Icons.person_outline_rounded,
                isDark: isDark,
              ),
              const SizedBox(height: 20),

              _buildLabel('Email Address'.tr(context)),
              _buildInputField(
                controller: _emailController,
                hint: 'example@mail.com'.tr(context),
                icon: Icons.alternate_email_rounded,
                isDark: isDark,
              ),
              const SizedBox(height: 20),

              _buildLabel('Phone Number'.tr(context)),
              _buildInputField(
                controller: _phoneController,
                hint: '+02 01 234 567 89'.tr(context),

                icon: Icons.phone_android_rounded,
                isDark: isDark,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),

              _buildLabel('Password'.tr(context)),
              _buildInputField(
                controller: _passwordController,
                hint: '••••••••'.tr(context),
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

              const SizedBox(height: 40),

              InteractiveButton(
                text: 'Sign Up'.tr(context),
                isLoading: _isLoading,
                onPressed: _handleSignUp,
                color: Colors.blueAccent,
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an account?'.tr(context)),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Sign In'.tr(context),
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
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1C1F2E)
            : Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blueAccent, size: 22),
          suffixIcon: suffix,
          border: InputBorder.none,
          hintText: hint,
        ),
      ),
    );
  }
}
