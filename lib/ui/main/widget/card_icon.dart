import 'package:flutter/material.dart';
import 'package:lenpay/l10n/app_localizations.dart';
import 'package:lenpay/ui/main/widget/all_tools.dart';
import 'package:lenpay/ui/submain_page/recharge_wallet.dart';

class CardIcon extends StatelessWidget {
  const CardIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildServiceItem(
                context,
                title: 'Recharge'.tr(context),
                assetPath: "assets/images/phone.png",
                bgColor: const Color(0xFFFFEDD5),
                iconColor: const Color(0xFFF59E0B),
                onTap: () {
                  debugPrint("فتح صفحة الشحن");
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => RechargePage()));
                },
              ),
              _buildServiceItem(
                context,
                title: 'Travel'.tr(context),
                assetPath: "assets/images/bag.png",
                bgColor: const Color(0xFFDCFCE7),
                iconColor: const Color(0xFF22C55E),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RechargeWallet(),
                    ),
                  );
                },
              ),
              _buildServiceItem(
                context,
                title: 'Hotel'.tr(context),
                assetPath: "assets/images/hotel.png",
                bgColor: const Color(0xFFDBEAFE),
                iconColor: const Color(0xFF3B82F6),
                onTap: () => debugPrint("فتح صفحة الفنادق"),
              ),
              _buildServiceItem(
                context,
                title: 'Wifi'.tr(context),
                assetPath: "assets/images/wifi.png",
                bgColor: const Color(0xFFF3E8FF),
                iconColor: const Color(0xFFA855F7),
                onTap: () => debugPrint("فتح صفحة الإنترنت"),
              ),
            ],
          ),
          const SizedBox(height: 25),
          // الصف الثاني
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildServiceItem(
                context,
                title: 'Electricity'.tr(context),
                assetPath: "assets/images/Electricity.png",
                bgColor: const Color(0xFFFEF3C7),
                iconColor: const Color(0xFFD97706),
                onTap: () => debugPrint("دفع فاتورة الكهرباء"),
              ),
              _buildServiceItem(
                context,
                title: 'Ticket'.tr(context),
                assetPath: "assets/images/ticket.png",
                bgColor: const Color(0xFFFFE4E6),
                iconColor: const Color(0xFFFB7185),
                onTap: () => debugPrint("حجز تذاكر"),
              ),
              _buildServiceItem(
                context,
                title: 'Store'.tr(context),
                assetPath: "assets/images/store.png",
                bgColor: const Color(0xFFD1FAE5),
                iconColor: const Color(0xFF10B981),
                onTap: () => debugPrint("فتح المتجر"),
              ),
              _buildServiceItem(
                context,
                title: 'See All'.tr(context),
                assetPath: "assets/images/more.png",
                bgColor: const Color(0xFFF1F5F9),
                iconColor: const Color(0xFF64748B),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AllTools()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // الدالة المعدلة لاستقبال الـ onTap
  Widget _buildServiceItem(
    BuildContext context, {
    required String title,
    required String assetPath,
    required Color bgColor,
    required Color iconColor,
    required VoidCallback onTap, // إضافة الـ Action هنا
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // الـ Material هنا عشان تأثير الـ Ripple يظهر بشكل صحيح
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap, // ربط الضغطة بالدالة الممرة
            borderRadius: BorderRadius.circular(20),
            splashColor: iconColor.withValues(alpha: 0.1), // لون الوميض عند الضغط
            child: Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? iconColor.withValues(alpha: 0.2) : bgColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Image.asset(
                  assetPath,
                  width: 30,
                  height: 30,
                  color: iconColor,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
