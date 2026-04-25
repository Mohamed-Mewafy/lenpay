import 'package:flutter/material.dart';

enum SnackbarType { success, error, info }

class CustomSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    SnackbarType type = SnackbarType.info,
  }) {
    Color backgroundColor;
    Color iconColor;
    IconData icon;

    switch (type) {
      case SnackbarType.success:
        backgroundColor = Colors.green;
        iconColor = Colors.white;
        icon = Icons.check_circle_outline_rounded;
        break;
      case SnackbarType.error:
        backgroundColor = Colors.redAccent;
        iconColor = Colors.white;
        icon = Icons.error_outline_rounded;
        break;
      case SnackbarType.info:
        backgroundColor = Colors.blueAccent;
        iconColor = Colors.white;
        icon = Icons.info_outline_rounded;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        elevation: 10,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        duration: const Duration(seconds: 3),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    );
  }
}
