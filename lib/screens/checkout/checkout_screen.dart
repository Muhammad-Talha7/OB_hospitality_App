import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../models/order.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/app_button.dart';
import 'auth_sheet.dart';
import 'order_confirmed_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  FulfilmentType _selectedFulfilment = FulfilmentType.delivery;
  final _addressController = TextEditingController(text: '104 Bank St, Apt 4B, Ottawa, ON');
  final _tableController = TextEditingController(text: 'Table 14');
  final _instructionsController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _addressController.dispose();
    _tableController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _handlePlaceOrder() async {
    final auth = context.read<AuthProvider>();
    final cart = context.read<CartProvider>();
    final orders = context.read<OrderProvider>();

    if (cart.isEmpty || cart.restaurantId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty.')),
      );
      return;
    }

    // Gate on authentication at checkout
    if (!auth.isLoggedIn) {
      await AuthSheet.show(context, onAuthenticated: () {
        _handlePlaceOrder();
      });
      return;
    }

    setState(() => _isSubmitting = true);

    final newOrder = OrderModel(
      id: 'ORD-${1000 + DateTime.now().millisecond}',
      restaurantId: cart.restaurantId!,
      restaurantName: cart.restaurantName ?? 'Restaurant',
      restaurantImage: cart.restaurantImage ?? '',
      items: List.from(cart.items),
      subtotal: cart.subtotal,
      deliveryFee: _selectedFulfilment == FulfilmentType.delivery ? cart.deliveryFee : 0.0,
      total: cart.subtotal + (_selectedFulfilment == FulfilmentType.delivery ? cart.deliveryFee : 0.0),
      fulfilmentType: _selectedFulfilment,
      paymentMethod: 'Cash on Delivery',
      status: OrderStatus.received,
      createdAt: DateTime.now(),
      deliveryAddress: _selectedFulfilment == FulfilmentType.delivery ? _addressController.text : null,
      tableNumber: _selectedFulfilment == FulfilmentType.dineIn ? _tableController.text : null,
    );

    final createdOrder = await orders.createOrder(newOrder);
    cart.clearCart();

    setState(() => _isSubmitting = false);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => OrderConfirmedScreen(order: createdOrder),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final auth = context.watch<AuthProvider>();

    final finalDeliveryFee = _selectedFulfilment == FulfilmentType.delivery ? cart.deliveryFee : 0.0;
    final grandTotal = cart.subtotal + finalDeliveryFee;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: cart.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_bag_outlined, size: 64, color: AppColors.textTertiary),
                  const SizedBox(height: 16),
                  Text('Cart is empty', style: AppTypography.displaySmall),
                  const SizedBox(height: 8),
                  Text('Add items from a restaurant menu first.', style: AppTypography.bodySmall),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
              children: [
                // Restaurant summary
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
                            cart.restaurantImage ?? '',
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
                            Text('ORDER FROM', style: AppTypography.labelMedium.copyWith(fontSize: 10)),
                            const SizedBox(height: 2),
                            Text(
                              cart.restaurantName ?? 'Restaurant',
                              style: AppTypography.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 1. Fulfilment Selector (Pickup, Delivery, Dine-in)
                Text(
                  '1. FULFILMENT TYPE',
                  style: AppTypography.labelMedium.copyWith(
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: FulfilmentType.values.map((type) {
                    final isSelected = _selectedFulfilment == type;
                    IconData icon;
                    switch (type) {
                      case FulfilmentType.delivery:
                        icon = Icons.delivery_dining;
                        break;
                      case FulfilmentType.pickup:
                        icon = Icons.shopping_bag_outlined;
                        break;
                      case FulfilmentType.dineIn:
                        icon = Icons.table_restaurant_outlined;
                        break;
                    }

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: InkWell(
                          onTap: () => setState(() => _selectedFulfilment = type),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.border,
                                width: 1.5,
                              ),
                              boxShadow: isSelected ? [AppColors.softShadow] : [],
                            ),
                            child: Column(
                              children: [
                                Icon(icon, color: isSelected ? Colors.white : AppColors.textPrimary, size: 22),
                                const SizedBox(height: 6),
                                Text(
                                  type.displayName,
                                  style: AppTypography.labelMedium.copyWith(
                                    color: isSelected ? Colors.white : AppColors.textPrimary,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Fulfilment specifics input
                if (_selectedFulfilment == FulfilmentType.delivery) ...[
                  TextField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Delivery Street Address',
                      prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                ] else if (_selectedFulfilment == FulfilmentType.dineIn) ...[
                  TextField(
                    controller: _tableController,
                    decoration: InputDecoration(
                      labelText: 'Table Number (assigned by host)',
                      prefixIcon: const Icon(Icons.pin_outlined, size: 20),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.store, color: AppColors.forest, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Pickup directly from counter when status reaches "Ready for Pickup".',
                            style: AppTypography.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                // 2. Payment Method: Cash on Delivery Only
                Text(
                  '2. PAYMENT METHOD',
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
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.forest.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.payments_outlined, color: AppColors.forest, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Cash on Delivery', style: AppTypography.titleSmall),
                            const SizedBox(height: 2),
                            Text(
                              'Pay upon delivery or counter pickup. No online card required.',
                              style: AppTypography.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.check_circle, color: AppColors.forest, size: 20),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 3. Customer Info / Auth Status
                Text(
                  '3. CUSTOMER CONTACT',
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
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.surfaceVariant,
                        child: Icon(
                          auth.isLoggedIn ? Icons.person : Icons.lock_outline,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              auth.isLoggedIn ? auth.currentUser!.name : 'Guest Customer',
                              style: AppTypography.titleSmall,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              auth.isLoggedIn
                                  ? '${auth.currentUser!.email} • ${auth.currentUser!.phone}'
                                  : 'Sign in will be requested when placing order',
                              style: AppTypography.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          if (auth.isLoggedIn) {
                            auth.logout();
                          } else {
                            AuthSheet.show(context, onAuthenticated: () {});
                          }
                        },
                        child: Text(
                          auth.isLoggedIn ? 'Switch' : 'Sign In',
                          style: AppTypography.labelMedium.copyWith(color: AppColors.ochre),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Order breakdown summary
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Subtotal (${cart.itemCount} items)', style: AppTypography.bodyMedium),
                          Text('\$${cart.subtotal.toStringAsFixed(2)}', style: AppTypography.titleSmall),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Delivery / Service Fee', style: AppTypography.bodyMedium),
                          Text(
                            _selectedFulfilment == FulfilmentType.delivery
                                ? '\$${cart.deliveryFee.toStringAsFixed(2)}'
                                : 'FREE',
                            style: AppTypography.titleSmall.copyWith(
                              color: _selectedFulfilment != FulfilmentType.delivery ? AppColors.forest : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total (Taxes Included)', style: AppTypography.titleMedium),
                          Text('\$${grandTotal.toStringAsFixed(2)}', style: AppTypography.price.copyWith(fontSize: 20)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
      bottomSheet: cart.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: const Border(top: BorderSide(color: AppColors.border)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: AppButton(
                label: 'PLACE ORDER • CASH ON DELIVERY',
                isLoading: _isSubmitting,
                onPressed: _handlePlaceOrder,
              ),
            ),
    );
  }
}
