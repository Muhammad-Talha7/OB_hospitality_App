import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../models/order.dart';
import '../../models/review.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/restaurant_provider.dart';
import '../../widgets/app_button.dart';

class LeaveReviewSheet extends StatefulWidget {
  final OrderModel order;

  const LeaveReviewSheet({
    super.key,
    required this.order,
  });

  static Future<void> show(BuildContext context, {required OrderModel order}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => LeaveReviewSheet(order: order),
    );
  }

  @override
  State<LeaveReviewSheet> createState() => _LeaveReviewSheetState();
}

class _LeaveReviewSheetState extends State<LeaveReviewSheet> {
  double _rating = 5.0;
  final _commentController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a brief comment.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final auth = context.read<AuthProvider>();
    final orderProvider = context.read<OrderProvider>();
    final restaurantProvider = context.read<RestaurantProvider>();

    final authorName = auth.currentUser?.name ?? 'Verified Diner';

    // 1. Mark order as reviewed
    await orderProvider.submitReview(
      orderId: widget.order.id,
      rating: _rating,
      comment: _commentController.text.trim(),
    );

    // 2. Add review to the restaurant profile
    final newReview = Review(
      id: 'rev_${DateTime.now().millisecondsSinceEpoch}',
      authorName: authorName,
      rating: _rating,
      comment: _commentController.text.trim(),
      date: DateTime.now(),
    );
    await restaurantProvider.addReviewToSelectedRestaurant(newReview);

    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Thank you! Your review for ${widget.order.restaurantName} is published.'),
          backgroundColor: AppColors.forest,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, bottomInset + 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Text(
            'Review Your Meal',
            style: AppTypography.displaySmall.copyWith(fontSize: 22),
          ),
          const SizedBox(height: 4),
          Text(
            widget.order.restaurantName,
            style: AppTypography.labelMedium.copyWith(color: AppColors.ochre),
          ),
          const SizedBox(height: 20),

          // Interactive Star Rating
          Center(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final starIndex = index + 1;
                    return IconButton(
                      onPressed: () => setState(() => _rating = starIndex.toDouble()),
                      icon: Icon(
                        starIndex <= _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                        size: 38,
                        color: const Color(0xFFEAB308),
                      ),
                    );
                  }),
                ),
                Text(
                  _rating == 5.0
                      ? 'Exceptional Gastronomy'
                      : _rating >= 4.0
                          ? 'Very Good Experience'
                          : _rating >= 3.0
                              ? 'Average'
                              : 'Disappointing',
                  style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Comment Field
          TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Describe the flavors, freshness, temperature, and presentation...',
              hintStyle: AppTypography.bodySmall,
              filled: true,
              fillColor: AppColors.surfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 24),

          // Submit button
          AppButton(
            label: 'PUBLISH REVIEW',
            isLoading: _isLoading,
            onPressed: _handleSubmit,
          ),
        ],
      ),
    );
  }
}
