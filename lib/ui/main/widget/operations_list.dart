import 'package:flutter/material.dart';
import 'package:lenpay/l10n/app_localizations.dart';
import 'package:lenpay/data/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Operationslist extends StatefulWidget {
  const Operationslist({super.key});

  @override
  State<Operationslist> createState() => _OperationslistState();
}

class _OperationslistState extends State<Operationslist> {
  final FirebaseService _firebaseService = FirebaseService();
  String _selectedFilter = "All";

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Transaction History'.tr(context),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          // 1. Filter Chips
          SizedBox(
            height: 45,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildFilterChip("All"),
                _buildFilterChip("Income"),
                _buildFilterChip("Expenses"),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firebaseService.getTransactionsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.wifi_off,
                            color: Colors.grey[400],
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Failed to load transactions. Please check your connection.'
                                .tr(context),
                            style: const TextStyle(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
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
                    child: Text(
                      'No transactions found'.tr(context),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  );
                }

                var docs = snapshot.data!.docs;

                // Filtering
                if (_selectedFilter == "Income") {
                  docs = docs
                      .where((doc) => (doc.data() as Map)['amount'] > 0)
                      .toList();
                } else if (_selectedFilter == "Expenses") {
                  docs = docs
                      .where((doc) => (doc.data() as Map)['amount'] < 0)
                      .toList();
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final double amount = (data['amount'] ?? 0.0).toDouble();
                    final bool isIncome = amount > 0;
                    final DateTime? date = (data['timestamp'] as Timestamp?)
                        ?.toDate();
                    final String formattedDate = date != null
                        ? DateFormat('MMM dd, yyyy').format(date)
                        : "Recent";

                    return _buildTransactionItem(
                      context,
                      isDark,
                      name: data['title'] ?? "Unknown",
                      type: data['category'] ?? "General",
                      amount:
                          "${isIncome ? '+' : ''}\$ ${amount.abs().toStringAsFixed(2)}",
                      date: formattedDate,
                      isIncome: isIncome,
                      icon: _getIconForCategory(data['category'] ?? ""),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final bool isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.blueAccent
                : Colors.grey.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label.tr(context),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    bool isDark, {
    required String name,
    required String type,
    required String amount,
    required String date,
    required bool isIncome,
    required IconData icon,
  }) {
    final Color color = isIncome ? Colors.green : Colors.redAccent;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1F2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Row(
          children: [
            Text(
              type,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(width: 8),
            Text("•", style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(width: 8),
            Text(
              date,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        trailing: Text(
          amount,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isIncome ? Colors.green : null,
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
