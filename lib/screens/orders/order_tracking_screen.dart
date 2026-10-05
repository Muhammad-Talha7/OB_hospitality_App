import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../widgets/order_status_tracker.dart';
import 'complaint_dialog.dart';
import 'leave_review_sheet.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderId;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
  });

  void _handleCancelOrder(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Cancel Order?', style: AppTypography.displaySmall),
        content: Text(
          'Are you sure you want to cancel order #${order.id}? This cannot be undone.',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Order'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await context.read<OrderProvider>().cancelOrder(order.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Order #${order.id} has been cancelled.' : 'Could not cancel order.'),
                    backgroundColor: success ? AppColors.error : null,
                  ),
                );
              }
            },
            child: Text('Cancel Order', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final order = orderProvider.getOrder(orderId);

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order Tracking')),
        body: const Center(child: Text('Order not found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${order.id}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, size: 22),
            tooltip: 'Report an issue',
            onPressed: () => ComplaintDialog.show(context, orderId: order.id),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
        children: [
          // Restaurant info header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Image.network(
                      order.restaurantImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.surfaceVariant,
                        child: const Icon(Icons.restaurant, size: 24),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.restaurantName, style: AppTypography.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        '${order.fulfilmentType.displayName} • ${order.paymentMethod}',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Visual Progress Tracker
          OrderStatusTracker(
            currentStatus: order.status,
            fulfilmentType: order.fulfilmentType,
          ),
          const SizedBox(height: 24),

          // HARD CONSTRAINT: CANCEL BUTTON APPARS ONLY WHILE STATUS IS RECEIVED OR ACCEPTED
          // Once status is Preparing or later, REMOVE BUTTON ENTIRELY
          if (order.status.isCancellable) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, size: 18, color: AppColors.ochre),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'The kitchen hasn\'t started preparing yet. You can still cancel this order.',
                      style: AppTypography.bodySmall,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => _handleCancelOrder(context, order),
                    child: Text(
                      'Cancel Order',
                      style: AppTypography.labelMedium.copyWith(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // If Delivered & Not Reviewed -> Leave a Review Prompt
          if (order.status == OrderStatus.delivered && !order.isReviewed) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.ochre.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.ochre.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded, color: AppColors.ochre, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Rate Your Experience', style: AppTypography.titleSmall),
                        Text('Tell other diners how the meal tasted.', style: AppTypography.bodySmall),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => LeaveReviewSheet.show(context, order: order),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    child: const Text('Review', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Order Items Breakdown
          Text(
            'ORDER DETAILS',
            style: AppTypography.labelMedium.copyWith(
              letterSpacing: 1.1,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                ...order.items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('${item.quantity}x', style: AppTypography.titleSmall.copyWith(fontSize: 12)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.menuItem.name, style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary)),
                              if (item.selectedAddOns.isNotEmpty)
                                Text(
                                  item.selectedAddOns.map((a) => a.name).join(', '),
                                  style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary, fontSize: 11),
                                ),
                            ],
                          ),
                        ),
                        Text('\$${item.totalPrice.toStringAsFixed(2)}', style: AppTypography.titleSmall),
                      ],
                    ),
                  );
                }),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Subtotal', style: AppTypography.bodySmall),
                    Text('\$${order.subtotal.toStringAsFixed(2)}', style: AppTypography.bodySmall),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Delivery Fee', style: AppTypography.bodySmall),
                    Text('\$${order.deliveryFee.toStringAsFixed(2)}', style: AppTypography.bodySmall),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total (Cash on Delivery)', style: AppTypography.titleSmall),
                    Text('\$${order.total.toStringAsFixed(2)}', style: AppTypography.price.copyWith(fontSize: 16)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Report Issue Action
          OutlinedButton.icon(
            onPressed: () => ComplaintDialog.show(context, orderId: order.id),
            icon: const Icon(Icons.report_problem_outlined, size: 18),
            label: const Text('Report an issue with this order'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}
