import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/menu_item.dart';
import '../models/restaurant.dart';
import '../providers/cart_provider.dart';
import '../screens/cart/restaurant_conflict_dialog.dart';

class CartHelper {
  /// Directly adds a dish to cart without opening details.
  /// Handles kitchen conflicts smoothly.
  static void quickAddToCart(
    BuildContext context, {
    required MenuItem item,
    required Restaurant restaurant,
  }) {
    final cart = context.read<CartProvider>();

    if (cart.canAddDirectly(restaurant.id)) {
      cart.addItem(
        restaurant: restaurant,
        menuItem: item,
        quantity: 1,
      );
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFF141416),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Color(0xFFE5BA73),
                  size: 14,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Added "${item.name}" to cart',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: const Color(0xFF141416),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          duration: const Duration(milliseconds: 1800),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFE5BA73),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        ),
      );
    } else {
      // Restaurant conflict! Show dialog.
      RestaurantConflictDialog.show(
        context,
        currentRestaurantName: cart.restaurantName ?? 'Previous Kitchen',
        newRestaurantName: restaurant.name,
        onConfirmClearAndAdd: () {
          cart.clearAndAddNew(
            restaurant: restaurant,
            menuItem: item,
            quantity: 1,
          );
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF141416),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Color(0xFFE5BA73),
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Started new order from ${restaurant.name}',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: const Color(0xFF141416),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              duration: const Duration(milliseconds: 1800),
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFFE5BA73),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            ),
          );
        },
      );
    }
  }
}
