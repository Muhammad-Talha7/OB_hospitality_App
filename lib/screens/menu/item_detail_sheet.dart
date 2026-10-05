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
      backgroundColor: Colors.transparent,
      builder: (ctx) => ItemDetailSheet(
        item: item,
        restaurant: restaurant,
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${widget.item.name} to cart'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primary,
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Started new order from ${widget.restaurant.name}'),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.primary,
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // Sheet Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
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
                          errorBuilder: (_, __, ___) => Container(
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
                          '\$${widget.item.price.toStringAsFixed(2)}',
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
                                  '+ \$${addon.priceDelta.toStringAsFixed(2)}',
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
                      color: Colors.black.withOpacity(0.05),
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
                        label: 'Add to Cart • \$${_currentPrice.toStringAsFixed(2)}',
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
