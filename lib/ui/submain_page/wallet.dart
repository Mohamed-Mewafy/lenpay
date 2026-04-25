import 'package:flutter/material.dart';
import 'package:lenpay/l10n/app_localizations.dart';

import 'package:lenpay/ui/main/widget/operations.dart';
import 'package:lenpay/widget/card.dart';

class Wallet extends StatefulWidget {
  const Wallet({super.key});

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Wallet'.tr(context),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: const [
          IconButton(onPressed: null, icon: Icon(Icons.tune_rounded)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // أضف كود التحديث (Refresh) هنا
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. The Card Section
              const CardBank(),

              // 2. Overview Section (Income / Expense)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    _buildOverviewCard(
                      context,
                      title: 'Income'.tr(context),
                      amount: "\$12,450.00",
                      icon: Icons.south_west_rounded,
                      color: Colors.green,
                      isDark: isDark,
                      index: 0,
                    ),
                    const SizedBox(width: 16),
                    _buildOverviewCard(
                      context,
                      title: 'Expense'.tr(context),
                      amount: "\$3,210.00",
                      icon: Icons.north_east_rounded,
                      color: Colors.redAccent,
                      isDark: isDark,
                      index: 1,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 3. Quick Actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Quick Actions'.tr(context),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    _buildQuickAction(
                      context,
                      'Send'.tr(context),
                      Icons.send_rounded,
                      Colors.blue,
                      0,
                    ),
                    _buildQuickAction(
                      context,
                      'Receive'.tr(context),
                      Icons.call_received_rounded,
                      Colors.orange,
                      1,
                    ),
                    _buildQuickAction(
                      context,
                      'Bills'.tr(context),
                      Icons.receipt_long_rounded,
                      Colors.purple,
                      2,
                    ),
                    _buildQuickAction(
                      context,
                      'Savings'.tr(context),
                      Icons.savings_rounded,
                      Colors.teal,
                      3,
                    ),
                    _buildQuickAction(
                      context,
                      'Vouchers'.tr(context),
                      Icons.confirmation_number_rounded,
                      Colors.pink,
                      4,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // 4. Recent Operations (Transaction History)
              const Operations(),

              const SizedBox(height: 100), // Extra space for scrolling
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCard(
    BuildContext context, {
    required String title,
    required String amount,
    required IconData icon,
    required Color color,
    required bool isDark,
    required int index, // Added index for staggered animation
  }) {
    return Expanded(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: Duration(milliseconds: 400 + (index * 200)),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: Opacity(
              opacity: value.clamp(0.0, 1.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C1F2E) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 18),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      amount,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    int index,
  ) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 500 + (index * 100)),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: Container(
              width: 85,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  _InteractiveScale(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1C1F2E)
                            : color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(icon, color: color, size: 28),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Helper Widget for interactive scale feedback
class _InteractiveScale extends StatefulWidget {
  final Widget child;
  const _InteractiveScale({required this.child});

  @override
  State<_InteractiveScale> createState() => _InteractiveScaleState();
}

class _InteractiveScaleState extends State<_InteractiveScale> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.9),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: widget.child,
      ),
    );
  }
}
