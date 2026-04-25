import 'package:flutter/material.dart';
import 'package:lenpay/l10n/app_localizations.dart';
import 'package:lenpay/widget/custom_snackbar.dart';

class RechargeWallet extends StatefulWidget {
  const RechargeWallet({super.key});

  @override
  State<RechargeWallet> createState() => _RechargeWalletState();
}

class _RechargeWalletState extends State<RechargeWallet> {
  final TextEditingController _amountController = TextEditingController(text: "100.00");
  String _selectedMethod = "visa";

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Recharge Wallet'.tr(context),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Amount Input Section
            Text(
              'Enter Amount'.tr(context),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C1F2E) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Text(
                    "\$",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "0.00",
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 2. Quick Amount Selection
            SizedBox(
              height: 45,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildQuickAmount("10"),
                  _buildQuickAmount("50"),
                  _buildQuickAmount("100"),
                  _buildQuickAmount("500"),
                  _buildQuickAmount("1000"),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // 3. Payment Methods
            Text(
              'Select Payment Method'.tr(context),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            _buildPaymentMethod(
              id: "visa",
              name: 'Visa / Mastercard'.tr(context),
              icon: Icons.credit_card_rounded,
              color: Colors.orange,
              isDark: isDark,
            ),
            _buildPaymentMethod(
              id: "apple_pay",
              name: 'Apple Pay'.tr(context),
              icon: Icons.apple_rounded,
              color: isDark ? Colors.white : Colors.black,
              isDark: isDark,
            ),
            _buildPaymentMethod(
              id: "paypal",
              name: 'PayPal Wallet'.tr(context),
              icon: Icons.account_balance_wallet_rounded,
              color: Colors.blue,
              isDark: isDark,
            ),

            const SizedBox(height: 100), // Space for button
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomAction(context, isDark),
    );
  }

  Widget _buildQuickAmount(String amount) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _amountController.text = "$amount.00";
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.blueAccent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: _amountController.text.startsWith(amount)
                ? Colors.blueAccent
                : Colors.transparent,
          ),
        ),
        child: Text(
          "\$$amount",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethod({
    required String id,
    required String name,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    final bool isSelected = _selectedMethod == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1F2E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blueAccent : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: Colors.blueAccent),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F111A) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: () {
            CustomSnackbar.show(
              context,
              message: "Recharge process started!",
              type: SnackbarType.success,
            );
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            elevation: 0,
          ),
          child: Text(
            'Finalize Recharge'.tr(context),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
