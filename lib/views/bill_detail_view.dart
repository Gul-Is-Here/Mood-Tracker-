import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../controllers/bill_controller.dart';
import '../model/bill_model.dart';

class BillDetailView extends StatelessWidget {
  final Bill bill;
  final BillController _controller = Get.find();

  BillDetailView({super.key, required this.bill});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill Details'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: _shareBillDetails,
            tooltip: 'Share bill',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header with total amount
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  NumberFormat.currency(symbol: '\$').format(bill.total),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${bill.split} ${bill.split == 1 ? 'person' : 'people'} • ${DateFormat('MMM dd, yyyy').format(bill.date)}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Details card
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Per person card
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color:
                        isDark
                            ? Colors.grey[900]
                            : theme.colorScheme.primary.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Each pays',
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            NumberFormat.currency(
                              symbol: '\$',
                            ).format(bill.total / bill.split),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Details list
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          if (bill.tipPercentage > 0)
                            _buildDetailItem(
                              context,
                              Icons.thumb_up_rounded,
                              'Tip',
                              '${bill.tipPercentage}%',
                              '\$${(bill.total * bill.tipPercentage / 100).toStringAsFixed(2)}',
                            ),
                          if (bill.discount > 0)
                            _buildDetailItem(
                              context,
                              Icons.discount_rounded,
                              'Discount',
                              '',
                              '-\$${bill.discount.toStringAsFixed(2)}',
                            ),
                          if (bill.tax > 0)
                            _buildDetailItem(
                              context,
                              Icons.receipt_long_rounded,
                              'Tax',
                              '${bill.tax}%',
                              '\$${(bill.total * bill.tax / 100).toStringAsFixed(2)}',
                            ),
                          if (bill.roundUp)
                            _buildDetailItem(
                              context,
                              Icons.rounded_corner_rounded,
                              'Rounding',
                              'Applied',
                              '',
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Delete button
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.9),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _confirmDelete,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete_outline_rounded),
                    SizedBox(width: 8),
                    Text('Delete Bill'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    String value,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: theme.colorScheme.primary),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      subtitle:
          subtitle.isNotEmpty
              ? Text(
                subtitle,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              )
              : null,
      trailing:
          value.isNotEmpty
              ? Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              )
              : null,
    );
  }

  void _confirmDelete() {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Bill'),
        content: const Text(
          'Are you sure you want to delete this bill? This action cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              _controller.deleteBill(bill.id);
              Get.back(); // Close dialog
              Get.back(); // Close details view
              Get.snackbar(
                'Deleted',
                'Bill has been deleted',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _shareBillDetails() {
    final shareText = '''
    🧾 Bill Details
    -------------------
    Total: \$${bill.total.toStringAsFixed(2)}
    Split: ${bill.split} ${bill.split == 1 ? 'person' : 'people'}
    Each pays: \$${(bill.total / bill.split).toStringAsFixed(2)}
    
    ${bill.tipPercentage > 0 ? '💡 Tip: ${bill.tipPercentage}% (\$${(bill.total * bill.tipPercentage / 100).toStringAsFixed(2)})' : ''}
    ${bill.discount > 0 ? '🎉 Discount: \$${bill.discount.toStringAsFixed(2)}' : ''}
    ${bill.tax > 0 ? '🏛️ Tax: ${bill.tax}% (\$${(bill.total * bill.tax / 100).toStringAsFixed(2)})' : ''}
    ${bill.roundUp ? '🔢 Rounding applied' : ''}
    
    Date: ${DateFormat('MMM dd, yyyy').format(bill.date)}
    Time: ${DateFormat('hh:mm a').format(bill.date)}
    ''';

    Share.share(shareText);
  }
}
