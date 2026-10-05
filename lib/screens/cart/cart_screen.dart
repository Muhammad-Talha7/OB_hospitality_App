import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/quantity_stepper.dart';
import '../checkout/checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: cart.isEmpty ? _buildEmptyState(context) : _buildCart(context, cart),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      size: 40,
                      color: Color(0xFFBBBBBB),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Your cart is empty',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF111111),
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Explore our kitchens to add\nyour favourite dishes.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF9E9E9E),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCart(BuildContext context, CartProvider cart) {
    return Stack(
      children: [
        SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(context),

              // Kitchen badge
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF6EE),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE5BA73).withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.storefront_rounded, color: Color(0xFFE5BA73), size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          cart.restaurantName ?? 'Restaurant',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF111111),
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5BA73).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${cart.itemCount} items',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFFC4892A),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 160),
                  children: [
                    ...cart.items.map((cartItem) => _CartItemCard(cartItem: cartItem, cart: cart)),
                    const SizedBox(height: 16),
                    _buildOrderSummary(cart),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Sticky checkout button
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: EdgeInsets.fromLTRB(20, 14, 20, MediaQuery.of(context).padding.bottom + 20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.07),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CheckoutScreen()),
              ),
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5BA73),
                  borderRadius: BorderRadius.circular(27),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Proceed to Checkout',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Rs. ${cart.total.toStringAsFixed(0)}',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'My Cart',
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFF111111),
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          Consumer<CartProvider>(
            builder: (ctx, cart, _) => cart.isEmpty
                ? const SizedBox.shrink()
                : GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (dialogCtx) => AlertDialog(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          title: Text(
                            'Clear Cart?',
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF111111),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          content: Text(
                            'Remove all items from ${cart.restaurantName}?',
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF777777),
                              fontSize: 13,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogCtx),
                              child: Text('Cancel',
                                  style: GoogleFonts.plusJakartaSans(color: const Color(0xFF9E9E9E))),
                            ),
                            TextButton(
                              onPressed: () {
                                cart.clearCart();
                                Navigator.pop(dialogCtx);
                              },
                              child: Text('Clear',
                                  style: GoogleFonts.plusJakartaSans(
                                      color: const Color(0xFFD65839), fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Text(
                      'Clear',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFFD65839),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9FB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        children: [
          _summaryRow('Subtotal', 'Rs. ${cart.subtotal.toStringAsFixed(0)}'),
          const SizedBox(height: 10),
          _summaryRow('Delivery Fee', 'Rs. ${cart.deliveryFee.toStringAsFixed(0)}'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Color(0xFFEEEEEE), height: 1),
          ),
          _summaryRow('Total', 'Rs. ${cart.total.toStringAsFixed(0)}', isTotal: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: isTotal ? const Color(0xFF111111) : const Color(0xFF888888),
            fontSize: isTotal ? 15 : 13,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            color: isTotal ? const Color(0xFFC4892A) : const Color(0xFF333333),
            fontSize: isTotal ? 17 : 13,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
            letterSpacing: isTotal ? -0.3 : 0,
          ),
        ),
      ],
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final dynamic cartItem;
  final CartProvider cart;

  const _CartItemCard({required this.cartItem, required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  cartItem.menuItem.imageUrl,
                  width: 68,
                  height: 68,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 68,
                    height: 68,
                    color: const Color(0xFFF5F5F5),
                    child: const Icon(Icons.fastfood, color: Color(0xFFCCCCCC)),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cartItem.menuItem.name,
                      maxLines: 2,
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF111111),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Rs. ${cartItem.unitPrice.toStringAsFixed(0)} each',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFFAAAAAA),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => cart.removeItem(cartItem.id),
                child: const Icon(Icons.close_rounded, size: 18, color: Color(0xFFCCCCCC)),
              ),
            ],
          ),

          if (cartItem.selectedAddOns.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: (cartItem.selectedAddOns as List).map((addon) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF6EE),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE5BA73).withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    '+ ${addon.name}  Rs. ${addon.priceDelta.toStringAsFixed(0)}',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFFC4892A),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          if (cartItem.instructions != null && (cartItem.instructions as String).isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '"${cartItem.instructions}"',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFFAAAAAA),
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],

          const SizedBox(height: 12),
          const Divider(color: Color(0xFFF0F0F0), height: 1),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              QuantityStepper(
                value: cartItem.quantity,
                onChanged: (qty) => cart.updateQuantity(cartItem.id, qty),
              ),
              Text(
                'Rs. ${cartItem.totalPrice.toStringAsFixed(0)}',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF111111),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
