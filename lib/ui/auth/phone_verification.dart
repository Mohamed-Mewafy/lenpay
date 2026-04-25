import 'package:flutter/material.dart';
import 'package:lenpay/l10n/app_localizations.dart';
import 'package:lenpay/ui/auth/login.dart';
import 'package:lenpay/util/route_transitions.dart';
import 'package:lenpay/widget/custom_snackbar.dart';
import 'package:lenpay/data/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class PhoneVerificationPage extends StatefulWidget {
  final String name;
  final String email;
  final String phone;
  final String password;

  const PhoneVerificationPage({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
  });

  @override
  State<PhoneVerificationPage> createState() => _PhoneVerificationPageState();
}

class _PhoneVerificationPageState extends State<PhoneVerificationPage> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = true;
  bool _emailSent = false;
  bool _hasError = false;
  String _statusMessage = 'Creating your account...';

  @override
  void initState() {
    super.initState();
    _createAccount();
  }

  Future<void> _createAccount() async {
    try {
      setState(() {
        _statusMessage = 'Creating your account...';
      });
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: widget.email,
            password: widget.password,
          )
          .timeout(const Duration(seconds: 20));

      debugPrint('Signup: user created with uid=${userCredential.user?.uid}');

      if (userCredential.user == null) {
        throw FirebaseAuthException(
          code: 'user-creation-failed',
          message: 'Unable to create user account.',
        );
      }

      await userCredential.user!.updateDisplayName(widget.name);

      if (!mounted) return;
      setState(() {
        _statusMessage = 'Saving your profile...';
      });

      bool profileSaved = false;
      try {
        await _firebaseService.initializeUserData(
          uid: userCredential.user!.uid,
          name: widget.name,
          email: widget.email,
          phone: widget.phone,
        );
        profileSaved = true;
        debugPrint('Signup: profile saved for uid=${userCredential.user!.uid}');
      } catch (e) {
        debugPrint('Signup profile save failed: $e');
        if (mounted) {
          setState(() {
            _statusMessage =
                'Account created, but failed to save profile data. Please check your internet connection or Firebase Console setup.';
          });
          CustomSnackbar.show(
            context,
            message:
                'Failed to save profile data. Please check your internet connection or Firebase Console setup.'
                    .tr(context),
            type: SnackbarType.error,
          );
        }
      }

      if (!mounted) return;
      setState(() {
        _statusMessage = 'Sending verification email...';
      });

      await userCredential.user!.sendEmailVerification().timeout(
        const Duration(seconds: 30),
      );

      debugPrint('Signup: verification email sent');

      if (!mounted) return;
      await FirebaseAuth.instance.signOut();
      setState(() {
        _isLoading = false;
        _emailSent = true;
        _statusMessage = profileSaved
            ? 'Verification email sent. Please check your inbox.'
            : 'Verification email sent. Profile save failed, please log in after verifying your email.';
      });

      if (!mounted) return;
      CustomSnackbar.show(
        context,
        message: 'Verification email sent!',
        type: SnackbarType.success,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message = 'An error occurred';
      if (e.code == 'weak-password') {
        message = 'Password is too weak.';
      }
      if (e.code == 'email-already-in-use') {
        message = 'Email already in use.';
      }
      if (e.code == 'invalid-email') {
        message = 'Please enter a valid email address.';
      }
      if (e.code == 'operation-not-allowed') {
        message = 'Email sign-up is not enabled.';
      }

      setState(() {
        _isLoading = false;
        _hasError = true;
        _statusMessage = message;
      });
      CustomSnackbar.show(context, message: message, type: SnackbarType.error);
    } on TimeoutException {
      if (!mounted) return;
      const String message =
          'Connection timeout. Please check your internet connection.';
      setState(() {
        _isLoading = false;
        _hasError = true;
        _statusMessage = message;
      });
      CustomSnackbar.show(context, message: message, type: SnackbarType.error);
    } catch (e) {
      if (!mounted) return;
      final String message = 'Error: ${e.toString()}';
      setState(() {
        _isLoading = false;
        _hasError = true;
        _statusMessage = message;
      });
      CustomSnackbar.show(context, message: message, type: SnackbarType.error);
    } finally {
      if (mounted && _isLoading) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: _isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.blueAccent),
                  const SizedBox(height: 20),
                  Text(
                    _statusMessage.tr(context),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _hasError ? Icons.error_outline : Icons.email_outlined,
                    size: 72,
                    color: _hasError ? Colors.redAccent : Colors.blueAccent,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _statusMessage.tr(context),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      if (_emailSent) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          AppRoutes.fade(page: const Login()),
                          (route) => false,
                        );
                        return;
                      }
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      _emailSent
                          ? 'Go to Sign In'.tr(context)
                          : 'Try Again'.tr(context),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
