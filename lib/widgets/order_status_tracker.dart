import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../models/order.dart';

class OrderStatusTracker extends StatelessWidget {
  final OrderStatus currentStatus;
  final FulfilmentType fulfilmentType;

  const OrderStatusTracker({
    super.key,
    required this.currentStatus,
    required this.fulfilmentType,
  });

  @override
  Widget build(BuildContext context) {
    if (currentStatus == OrderStatus.cancelled || currentStatus == OrderStatus.rejected) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.error.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.cancel_rounded, color: AppColors.error, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentStatus == OrderStatus.cancelled ? 'Order Cancelled' : 'Order Rejected',
                    style: AppTypography.titleSmall.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'This order has been terminated and will not be fulfilled.',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final steps = [
      OrderStatus.received,
      OrderStatus.accepted,
      OrderStatus.preparing,
      OrderStatus.outForDelivery,
      OrderStatus.delivered,
    ];

    final currentIndex = steps.indexOf(currentStatus);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [AppColors.softShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ORDER PROGRESS',
                  style: AppTypography.labelMedium.copyWith(
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.forest.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    currentStatus.displayName(fulfilmentType).toUpperCase(),
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.forest,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Horizontal Progress Line with Dots and Labels
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(steps.length, (index) {
              final step = steps[index];
              final isCompleted = currentIndex >= index;
              final isCurrent = currentIndex == index;

              return Expanded(
                child: Column(
                  children: [
                    // Node with connector lines
                    Row(
                      children: [
                        // Left line
                        Expanded(
                          child: Container(
                            height: 2.5,
                            color: index == 0
                                ? Colors.transparent
                                : (currentIndex >= index
                                    ? AppColors.primary
                                    : AppColors.border),
                          ),
                        ),

                        // Center Circle Icon
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: isCompleted ? AppColors.primary : AppColors.surfaceVariant,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isCompleted ? AppColors.primary : AppColors.border,
                              width: 2,
                            ),
                            boxShadow: isCurrent
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : [],
                          ),
                          child: Center(
                            child: isCompleted
                                ? (isCurrent
                                    ? Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                      )
                                    : const Icon(Icons.check, size: 14, color: Colors.white))
                                : Text(
                                    '${index + 1}',
                                    style: AppTypography.labelMedium.copyWith(
                                      color: AppColors.textTertiary,
                                      fontSize: 10,
                                    ),
                                  ),
                          ),
                        ),

                        // Right line
                        Expanded(
                          child: Container(
                            height: 2.5,
                            color: index == steps.length - 1
                                ? Colors.transparent
                                : (currentIndex > index
                                    ? AppColors.primary
                                    : AppColors.border),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Step label text
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Text(
                        step.displayName(fulfilmentType),
                        textAlign: TextAlign.center,
                        style: AppTypography.bodySmall.copyWith(
                          fontSize: 9.5,
                          fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                          color: isCurrent
                              ? AppColors.textPrimary
                              : (isCompleted
                                  ? AppColors.textSecondary
                                  : AppColors.textTertiary),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
