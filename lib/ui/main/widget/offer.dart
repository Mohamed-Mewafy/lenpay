import 'package:flutter/material.dart';
import 'package:lenpay/l10n/app_localizations.dart';

class Offer extends StatelessWidget {
  const Offer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Offers'.tr(context),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text('Many offers waiting for you, get it now'.tr(context)),
            ],
          ),
        ),
        const SizedBox(height: 15),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(), // Smoother scrolling
          child: Row(
            children: [
              const SizedBox(width: 20),
              _buildOfferCard(
                context,
                title: 'Mobile Charge'.tr(context),
                subtitle: 'Get 10% off on mobile charge'.tr(context),
                buttonText: 'Buy Now'.tr(context),
                buttonColor: const Color.fromARGB(255, 233, 227, 122),
                imagePath: "assets/images/mobilehand.png",
                textColor: Colors.black, // Dark text for yellow button
                onTap: () => debugPrint("Mobile Charge Tapped"),
              ),
              const SizedBox(width: 15),
              _buildOfferCard(
                context,
                title: 'Restaurant'.tr(context),
                subtitle: 'Get 20% off on dinner'.tr(context),
                buttonText: 'Order Now'.tr(context),
                buttonColor: const Color.fromARGB(255, 107, 105, 217),
                textColor: Colors.white,
                imagePath: "assets/images/restaurant.png",
                onTap: () => debugPrint("Restaurant Tapped"),
              ),
              const SizedBox(width: 20),
              _buildOfferCard(
                context,
                title: 'Wifi'.tr(context),
                subtitle: 'Get 20% off on wifi'.tr(context),
                buttonText: 'Buy Now'.tr(context),
                buttonColor: const Color.fromARGB(255, 107, 105, 217),
                textColor: Colors.white,
                imagePath: "assets/images/wifi.png",
                onTap: () => debugPrint("wifi Tapped"),
              ),
              const SizedBox(width: 20),
            ],
          ),
        ),
      ],
    );
  }

  // Helper method to keep your build method clean
  Widget _buildOfferCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String buttonText,
    required Color buttonColor,
    required String imagePath,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    textColor ??= Theme.of(context).colorScheme.onSurface;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 300,
        height: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF2A2D3E)
              : const Color.fromARGB(255, 240, 235, 255),
          borderRadius: BorderRadius.circular(
            20,
          ), // Slightly rounder for modern look
        ),
        child: Row(
          children: [
            Expanded(
              // Use Expanded to prevent text overflow
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: buttonColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      buttonText,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Image.asset(imagePath, width: 80, height: 80, fit: BoxFit.contain),
          ],
        ),
      ),
    );
  }
}
