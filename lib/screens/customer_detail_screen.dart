import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/customer.dart';
import '../models/sale.dart';
import '../providers/sale_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_localization.dart';
import '../utils/currency_utils.dart';

class CustomerDetailScreen extends ConsumerWidget {
  final Customer customer;

  const CustomerDetailScreen({super.key, required this.customer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allSales = ref.watch(saleProvider);
    final customerSales = allSales
        .where((s) => s.customerId == customer.id && s.deletedAt == null)
        .toList()
      ..sort((a, b) => b.saleDate.compareTo(a.saleDate));

    final totalSpent = customerSales.fold<double>(0, (sum, sale) => sum + sale.totalAmount);
    final discountInfo = _getSuggestedDiscount(totalSpent, ref);

    return Scaffold(
      appBar: AppBar(
        title: Text(customer.name),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(context, ref, totalSpent, customerSales.length),
            const SizedBox(height: 24),
            if (discountInfo != null) ...[
              _buildDiscountSuggestion(context, ref, discountInfo),
              const SizedBox(height: 24),
            ],
            Text(
              tr(ref, 'purchase_history'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (customerSales.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Icon(Icons.shopping_bag_outlined, size: 48, color: AppTheme.slate300),
                      const SizedBox(height: 8),
                      Text(tr(ref, 'no_purchases_yet'), style: TextStyle(color: AppTheme.slate500)),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: customerSales.length,
                itemBuilder: (context, index) {
                  final sale = customerSales[index];
                  return _buildSaleCard(context, ref, sale);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, WidgetRef ref, double totalSpent, int purchaseCount) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.slate200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  child: Text(
                    customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      if (customer.phoneNumber != null)
                        Text(customer.phoneNumber!, style: TextStyle(color: AppTheme.slate500)),
                      if (customer.email != null)
                        Text(customer.email!, style: TextStyle(color: AppTheme.slate500)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(tr(ref, 'total_spent'), CurrencyUtils.format(totalSpent), Colors.green),
                _buildStatItem(tr(ref, 'purchases'), purchaseCount.toString(), AppTheme.primaryBlue),
              ],
            ),
            if (customer.address != null && customer.address!.isNotEmpty) ...[
              const Divider(height: 32),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on_outlined, size: 16, color: AppTheme.slate400),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      customer.address!,
                      style: TextStyle(color: AppTheme.slate600, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: AppTheme.slate500, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildDiscountSuggestion(BuildContext context, WidgetRef ref, _DiscountInfo info) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.stars_rounded, color: Colors.amber),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr(ref, 'suggested_discount'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.orangeAccent),
                ),
                Text(
                  '${info.percentage}% ${tr(ref, 'off_next_purchase')}',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
          Tooltip(
            message: info.reason,
            child: const Icon(Icons.info_outline, size: 18, color: Colors.amber),
          ),
        ],
      ),
    );
  }

  Widget _buildSaleCard(BuildContext context, WidgetRef ref, Sale sale) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.slate100),
      ),
      child: ListTile(
        title: Text(
          sale.operationId,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${sale.saleDate.day}/${sale.saleDate.month}/${sale.saleDate.year}',
          style: TextStyle(color: AppTheme.slate500, fontSize: 12),
        ),
        trailing: Text(
          CurrencyUtils.format(sale.totalAmount),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
        ),
      ),
    );
  }

  _DiscountInfo? _getSuggestedDiscount(double totalSpent, WidgetRef ref) {
    if (totalSpent >= 500000) {
      return _DiscountInfo(15, tr(ref, 'loyal_customer_gold'));
    } else if (totalSpent >= 250000) {
      return _DiscountInfo(10, tr(ref, 'loyal_customer_silver'));
    } else if (totalSpent >= 100000) {
      return _DiscountInfo(5, tr(ref, 'loyal_customer_bronze'));
    }
    return null;
  }
}

class _DiscountInfo {
  final int percentage;
  final String reason;

  _DiscountInfo(this.percentage, this.reason);
}
