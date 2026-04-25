import 'package:flutter/material.dart';
import 'package:lenpay/l10n/app_localizations.dart';
import 'package:lenpay/data/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Operations extends StatefulWidget {
  const Operations({super.key});

  @override
  State<Operations> createState() => _OperationsState();
}

class _OperationsState extends State<Operations> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Align "Operations" text to left
        children: [
          Text(
            'Recent Operations'.tr(context),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          StreamBuilder<QuerySnapshot>(
            stream: _firebaseService.getTransactionsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.wifi_off, color: Colors.grey[400], size: 40),
                        const SizedBox(height: 8),
                        Text(
                          'Failed to load data. Please check your connection.'
                              .tr(context),
                          style: const TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () => setState(() {}),
                          icon: const Icon(Icons.refresh, size: 18),
                          label: Text('Retry'.tr(context)),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'No operations yet'.tr(context),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }

              final docs = snapshot.data!.docs
                  .take(5)
                  .toList(); // Show only last 5

              return Column(
                children: docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final double amount = (data['amount'] ?? 0.0).toDouble();
                  final bool isIncome = amount > 0;

                  return _buildOperationItem(
                    context,
                    name: data['title'] ?? "Unknown",
                    type: data['category'] ?? "General",
                    amount:
                        "${isIncome ? '+' : ''}\$ ${amount.abs().toStringAsFixed(2)}",
                    icon: _getIconForCategory(data['category'] ?? ""),
                    iconColor: isIncome ? Colors.green : Colors.redAccent,
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // Reusable Widget for each row
  Widget _buildOperationItem(
    BuildContext context, {
    required String name,
    required String type,
    required String amount,
    required IconData icon,
    required Color iconColor,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
        ), // Subtle border
      ),
      color: Theme.of(context).cardColor,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(type, style: const TextStyle(fontSize: 12)),
        trailing: Text(
          amount,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: amount.startsWith('+')
                ? Colors.green
                : Theme.of(context).colorScheme.onSurface,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'transfer':
        return Icons.swap_horiz_rounded;
      case 'payment':
        return Icons.shopping_bag_outlined;
      case 'income':
        return Icons.south_west_rounded;
      case 'withdrawal':
        return Icons.money_off_rounded;
      case 'top-up':
        return Icons.add_circle_outline_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }
}
