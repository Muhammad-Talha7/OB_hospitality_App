import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../models/order.dart';
import '../../widgets/app_button.dart';
import '../orders/order_tracking_screen.dart';

class OrderConfirmedScreen extends StatelessWidget {
  final OrderModel order;

  const OrderConfirmedScreen({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

              // Confirmation check badge with luxury circular rings
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.forest.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: AppColors.forest,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded, color: Colors.white, size: 40),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              Text(
                'ORDER CONFIRMED',
                style: AppTypography.labelMedium.copyWith(
                  letterSpacing: 2.0,
                  color: AppColors.forest,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),

              Text(
                'Thank you for your order',
                style: AppTypography.displayMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              Text(
                'Your order #${order.id} from ${order.restaurantName} has been received by the kitchen and is being accepted.',
                style: AppTypography.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Thank you for dining with OB Hospitality Group',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Order Summary Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [AppColors.softShadow],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Fulfilment', style: AppTypography.bodySmall),
                        Text(
                          order.fulfilmentType.displayName,
                          style: AppTypography.titleSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Payment Method', style: AppTypography.bodySmall),
                        Row(
                          children: [
                            const Icon(Icons.payments_outlined, size: 16, color: AppColors.ochre),
                            const SizedBox(width: 6),
                            Text(
                              order.paymentMethod,
                              style: AppTypography.titleSmall.copyWith(color: AppColors.ochre),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Payable', style: AppTypography.bodySmall),
                        Text(
                          '\$${order.total.toStringAsFixed(2)}',
                          style: AppTypography.price.copyWith(fontSize: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Primary: Track Order
              AppButton(
                label: 'TRACK ORDER PROGRESS',
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => OrderTrackingScreen(orderId: order.id),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              // Secondary: Return Home
              AppButton(
                label: 'RETURN TO RESTAURANTS',
                isSecondary: true,
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
