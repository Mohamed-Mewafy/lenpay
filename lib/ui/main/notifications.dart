import 'package:flutter/material.dart';
import 'package:lenpay/l10n/app_localizations.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F111A) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Notifications'.tr(context),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildSectionHeader('Today'.tr(context)),
          _buildNotificationItem(
            context,
            isDark,
            title: 'Salary Received'.tr(context),
            message: 'Your salary of \$3,200.00 has been credited to your account.'.tr(context),
            time: "10:30 AM",
            icon: Icons.account_balance_wallet_rounded,
            iconColor: Colors.green,
          ),
          _buildNotificationItem(
            context,
            isDark,
            title: 'Security Alert'.tr(context),
            message: 'New login detected on Chrome Windows. Was this you?'.tr(context),
            time: "09:12 AM",
            icon: Icons.shield_rounded,
            iconColor: Colors.orange,
            isUnread: true,
          ),
          
          const SizedBox(height: 25),
          _buildSectionHeader('Yesterday'.tr(context)),
          _buildNotificationItem(
            context,
            isDark,
            title: 'Payment Successful'.tr(context),
            message: 'Payment for Netflix Subscription (\$15.99) was successful.'.tr(context),
            time: "08:45 PM",
            icon: Icons.check_circle_rounded,
            iconColor: Colors.blue,
          ),
          _buildNotificationItem(
            context,
            isDark,
            title: 'Transfer Received'.tr(context),
            message: 'Mohamed Esam sent you \$150.00.'.tr(context),
            time: "02:20 PM",
            icon: Icons.arrow_downward_rounded,
            iconColor: Colors.purple,
          ),
          _buildNotificationItem(
            context,
            isDark,
            title: 'System Update'.tr(context),
            message: 'LenPay v2.4 is now available with new features!'.tr(context),
            time: "10:00 AM",
            icon: Icons.system_update_rounded,
            iconColor: Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 15, top: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    bool isDark, {
    required String title,
    required String message,
    required String time,
    required IconData icon,
    required Color iconColor,
    bool isUnread = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1F2E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: isUnread 
          ? Border.all(color: Colors.blueAccent.withValues(alpha: 0.3), width: 1.5)
          : Border.all(color: Colors.transparent),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white70 : Colors.black54,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (isUnread)
            Container(
              margin: const EdgeInsets.only(left: 8, top: 4),
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
