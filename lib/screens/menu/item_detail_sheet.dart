import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../models/menu_item.dart';
import '../../models/restaurant.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/quantity_stepper.dart';
import '../cart/restaurant_conflict_dialog.dart';

class ItemDetailSheet extends StatefulWidget {
  final MenuItem item;
  final Restaurant restaurant;

  const ItemDetailSheet({
    super.key,
    required this.item,
    required this.restaurant,
  });

  static void show(BuildContext context, {
    required MenuItem item,
    required Restaurant restaurant,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      sheetAnimationStyle: const AnimationStyle(
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInOutCubic,
        duration: Duration(milliseconds: 380),
        reverseDuration: Duration(milliseconds: 320),
      ),
      backgroundColor: Colors.transparent,
      builder: (ctx) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(ctx).pop(),
        child: GestureDetector(
          onTap: () {}, // Prevent taps inside sheet from popping
          child: ItemDetailSheet(
            item: item,
            restaurant: restaurant,
          ),
        ),
      ),
    );
  }

  @override
  State<ItemDetailSheet> createState() => _ItemDetailSheetState();
}

class _ItemDetailSheetState extends State<ItemDetailSheet> {
  final Set<String> _selectedAddOnIds = {};
  int _quantity = 1;
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  double get _currentPrice {
    double total = widget.item.price;
    for (final addon in widget.item.addOns) {
      if (_selectedAddOnIds.contains(addon.id)) {
        total += addon.priceDelta;
      }
    }
    return total * _quantity;
  }

  List<AddOn> get _selectedAddOnsList {
    return widget.item.addOns
        .where((addon) => _selectedAddOnIds.contains(addon.id))
        .toList();
  }

  void _handleAddToCart() {
    final cart = context.read<CartProvider>();

    if (cart.canAddDirectly(widget.restaurant.id)) {
      cart.addItem(
        restaurant: widget.restaurant,
        menuItem: widget.item,
        selectedAddOns: _selectedAddOnsList,
        quantity: _quantity,
        instructions: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Added "${widget.item.name}" to cart',
                  style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ],
          ),
          duration: const Duration(milliseconds: 1800),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        ),
      );
    } else {
      // Restaurant conflict! Show dialog.
      RestaurantConflictDialog.show(
        context,
        currentRestaurantName: cart.restaurantName ?? 'Previous Restaurant',
        newRestaurantName: widget.restaurant.name,
        onConfirmClearAndAdd: () {
          cart.clearAndAddNew(
            restaurant: widget.restaurant,
            menuItem: widget.item,
            selectedAddOns: _selectedAddOnsList,
            quantity: _quantity,
            instructions: _notesController.text.trim().isNotEmpty
                ? _notesController.text.trim()
                : null,
          );
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Started new order from ${widget.restaurant.name}',
                      style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ],
              ),
              duration: const Duration(milliseconds: 1800),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.40,
      maxChildSize: 0.92,
      shouldCloseOnMinExtent: true,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // Top Drag Handle & Close Button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 16, 6),
                child: Row(
                  children: [
                    const SizedBox(width: 32),
                    Expanded(
                      child: Center(
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 44,
                            height: 4.5,
                            decoration: BoxDecoration(
                              color: AppColors.border,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceVariant,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: AppColors.textPrimary,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                  children: [
                    // Item Photo
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: SizedBox(
                        height: 220,
                        width: double.infinity,
                        child: Image.network(
                          widget.item.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: AppColors.surfaceVariant,
                            child: const Center(
                              child: Icon(Icons.fastfood, size: 50, color: AppColors.textTertiary),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title & Price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.item.name,
                                style: AppTypography.displaySmall.copyWith(fontSize: 22),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.restaurant.name,
                                style: AppTypography.labelMedium.copyWith(
                                  color: Color(widget.restaurant.crescentColorValue),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Rs. ${widget.item.price.toInt()}',
                          style: AppTypography.price.copyWith(fontSize: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Description
                    Text(
                      widget.item.description,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Add-ons Section (if available)
                    if (widget.item.addOns.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'CUSTOMISE YOUR ORDER',
                            style: AppTypography.labelMedium.copyWith(
                              letterSpacing: 1.1,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Optional',
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...widget.item.addOns.map((addon) {
                        final isSelected = _selectedAddOnIds.contains(addon.id);
                        return InkWell(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedAddOnIds.remove(addon.id);
                              } else {
                                _selectedAddOnIds.add(addon.id);
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.surfaceVariant : AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.border,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: isSelected,
                                  onChanged: (val) {
                                    setState(() {
                                      if (val == true) {
                                        _selectedAddOnIds.add(addon.id);
                                      } else {
                                        _selectedAddOnIds.remove(addon.id);
                                      }
                                    });
                                  },
                                  activeColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    addon.name,
                                    style: AppTypography.titleSmall.copyWith(
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                    ),
                                  ),
                                ),
                                Text(
                                  '+ Rs. ${addon.priceDelta.toInt()}',
                                  style: AppTypography.price.copyWith(
                                    fontSize: 13,
                                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                    ],

                    // Kitchen Special Instructions
                    Text(
                      'SPECIAL INSTRUCTIONS',
                      style: AppTypography.labelMedium.copyWith(
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        hintText: 'e.g. Dressing on the side, no onions, extra cutlery...',
                        hintStyle: AppTypography.bodySmall,
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(14),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),

              // Bottom Action Bar: Quantity Stepper + Add to Cart Button
              Container(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: const Border(top: BorderSide(color: AppColors.border)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    QuantityStepper(
                      value: _quantity,
                      onChanged: (val) => setState(() => _quantity = val),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppButton(
                        label: 'Add to Cart • Rs. ${_currentPrice.toInt()}',
                        onPressed: _handleAddToCart,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
