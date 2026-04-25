import 'package:flutter/material.dart';
import 'package:lenpay/ui/submain_page/service_payment.dart';

class AllTools extends StatefulWidget {
  const AllTools({super.key});

  @override
  State<AllTools> createState() => _AllToolsState();
}

class _AllToolsState extends State<AllTools> {
  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "All Services",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Favorite Services",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // 1. Grid of Financial Tools
            _buildCategoryHeader("Financial Tools"),
            const SizedBox(height: 15),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              mainAxisSpacing: 20,
              crossAxisSpacing: 10,
              childAspectRatio: 0.8,
              children: [
                _buildGridItem(context, isDark, "Recharge", Icons.phone_android_rounded, Colors.orange),
                _buildGridItem(context, isDark, "Transfer", Icons.send_to_mobile_rounded, Colors.blue),
                _buildGridItem(context, isDark, "Withdraw", Icons.account_balance_rounded, Colors.green),
                _buildGridItem(context, isDark, "Request", Icons.call_received_rounded, Colors.purple),
              ],
            ),

            const SizedBox(height: 35),

            // 2. Grid of Utility Bills
            _buildCategoryHeader("Utility Bills"),
            const SizedBox(height: 15),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              mainAxisSpacing: 20,
              crossAxisSpacing: 10,
              childAspectRatio: 0.8,
              children: [
                _buildGridItem(context, isDark, "Electricity", Icons.electric_bolt_rounded, Colors.amber),
                _buildGridItem(context, isDark, "Water", Icons.water_drop_rounded, Colors.blueAccent),
                _buildGridItem(context, isDark, "Wifi", Icons.wifi_rounded, Colors.indigo),
                _buildGridItem(context, isDark, "Gas", Icons.local_fire_department_rounded, Colors.orangeAccent),
              ],
            ),

            const SizedBox(height: 35),

            // 3. Grid of Lifestyle
            _buildCategoryHeader("Lifestyle & Travel"),
            const SizedBox(height: 15),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              mainAxisSpacing: 20,
              crossAxisSpacing: 10,
              childAspectRatio: 0.8,
              children: [
                _buildGridItem(context, isDark, "Travel", Icons.flight_takeoff_rounded, Colors.green),
                _buildGridItem(context, isDark, "Hotel", Icons.hotel_rounded, Colors.blue),
                _buildGridItem(context, isDark, "Tickets", Icons.confirmation_number_rounded, Colors.pink),
                _buildGridItem(context, isDark, "Shopping", Icons.shopping_cart_rounded, Colors.teal),
              ],
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildGridItem(
      BuildContext context, bool isDark, String title, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServicePayment(
              serviceName: title,
              serviceIcon: icon,
              serviceColor: color,
            ),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1F2E) : color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.transparent,
              ),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
