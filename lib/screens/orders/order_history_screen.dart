import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import 'leave_review_sheet.dart';
import 'order_tracking_screen.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Text(
                  'My Orders',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF111111),
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tab bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F3F6),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: TabBar(
                  indicator: BoxDecoration(
                    color: const Color(0xFFE5BA73),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelStyle: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                  unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: const Color(0xFF888888),
                  tabs: [
                    Tab(text: 'Active (${orderProvider.activeOrders.length})'),
                    Tab(text: 'Past (${orderProvider.pastOrders.length})'),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: TabBarView(
                  children: [
                    orderProvider.activeOrders.isEmpty
                        ? _buildEmptyState(
                            'No active orders',
                            'Place an order from any of our kitchens.',
                            Icons.hourglass_empty_rounded,
                          )
                        : _buildOrderList(context, orderProvider.activeOrders),
                    orderProvider.pastOrders.isEmpty
                        ? _buildEmptyState(
                            'No past orders yet',
                            'Completed orders will appear here.',
                            Icons.receipt_long_outlined,
                          )
                        : _buildOrderList(context, orderProvider.pastOrders),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Color(0xFFF3F3F6),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 36, color: const Color(0xFFCCCCCC)),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFF111111),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFF9E9E9E),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(BuildContext context, List<OrderModel> orders) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 80),
      itemCount: orders.length,
      itemBuilder: (ctx, index) => _OrderCard(order: orders[index]),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final isDelivered = order.status == OrderStatus.delivered;
    final canReview = isDelivered && !order.isReviewed;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => OrderTrackingScreen(orderId: order.id)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFEEEEEE)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    order.restaurantImage,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 44,
                      height: 44,
                      color: const Color(0xFFF3F3F6),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.restaurantName,
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF111111),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '#${order.id} · ${order.fulfilmentType.displayName}',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFFAAAAAA),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusPill(status: order.status, fulfilmentType: order.fulfilmentType),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: Color(0xFFF0F0F0), height: 1),
            ),

            Text(
              order.items.map((i) => '${i.quantity}× ${i.menuItem.name}').join(', '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF888888),
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rs. ${order.total.toStringAsFixed(0)}',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF111111),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      order.paymentMethod,
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFFAAAAAA),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                if (canReview)
                  GestureDetector(
                    onTap: () => LeaveReviewSheet.show(context, order: order),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5BA73),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, size: 13, color: Colors.white),
                          const SizedBox(width: 5),
                          Text(
                            'Leave Review',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (isDelivered && order.isReviewed)
                  Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF5FB760)),
                      const SizedBox(width: 5),
                      Text(
                        'Reviewed',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF5FB760),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    'Track →',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFFC4892A),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final OrderStatus status;
  final dynamic fulfilmentType;
  const _StatusPill({required this.status, required this.fulfilmentType});

  @override
  Widget build(BuildContext context) {
    final (label, color, bg) = switch (status) {
      OrderStatus.delivered => ('Delivered', const Color(0xFF5FB760), const Color(0xFFEDF7EE)),
      OrderStatus.cancelled || OrderStatus.rejected => ('Cancelled', const Color(0xFFD65839), const Color(0xFFFDF0ED)),
      _ => ('Active', const Color(0xFFC4892A), const Color(0xFFFAF6EE)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.plusJakartaSans(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
