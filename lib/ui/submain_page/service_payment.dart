import 'package:flutter/material.dart';
import 'package:lenpay/l10n/app_localizations.dart';

class ServicePayment extends StatefulWidget {
  final String serviceName;
  final IconData serviceIcon;
  final Color serviceColor;

  const ServicePayment({
    super.key,
    required this.serviceName,
    required this.serviceIcon,
    required this.serviceColor,
  });

  @override
  State<ServicePayment> createState() => _ServicePaymentState();
}

class _ServicePaymentState extends State<ServicePayment> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.serviceName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            // 1. Service Icon Header
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: widget.serviceColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(widget.serviceIcon, size: 50, color: widget.serviceColor),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.translateFormat(context, 'Pay Your {service} Bill', {'service': widget.serviceName}),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            
            const SizedBox(height: 40),

            // 2. Input Fields
            _buildInputField(
              label: 'Consumer ID / Account No.'.tr(context),
              controller: _idController,
              hint: 'Enter your 12-digit number'.tr(context),
              icon: Icons.tag_rounded,
              isDark: isDark,
            ),
            const SizedBox(height: 20),
            _buildInputField(
              label: 'Amount to Pay'.tr(context),
              controller: _amountController,
              hint: '0.00',
              icon: Icons.attach_money_rounded,
              isDark: isDark,
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 60),

            // 3. Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _showSuccessDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.serviceColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Pay Now'.tr(context),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 20),
            Text(
              'Payment Successful'.tr(context),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              AppLocalizations.translateFormat(context, 'Your {service} bill has been paid successfully.', {'service': widget.serviceName}),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 25),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back home
              },
              child: Text('Done'.tr(context), style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1F2E) : Colors.grey.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              icon: Icon(icon, color: widget.serviceColor, size: 20),
              border: InputBorder.none,
              hintText: hint,
            ),
          ),
        ),
      ],
    );
  }
}
