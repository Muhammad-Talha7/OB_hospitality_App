import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../models/menu_item.dart';

class MenuItemCard extends StatelessWidget {
  final MenuItem item;
  final bool restaurantIsOpen;
  final VoidCallback onTap;

  const MenuItemCard({
    super.key,
    required this.item,
    required this.restaurantIsOpen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final canOrder = restaurantIsOpen && item.isAvailable;

    return InkWell(
      onTap: canOrder ? onTap : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [AppColors.softShadow],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text Column: Name, Description, Price
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: AppTypography.titleSmall.copyWith(
                      color: canOrder ? AppColors.textPrimary : AppColors.textTertiary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.description,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        '\$${item.price.toStringAsFixed(2)}',
                        style: AppTypography.price.copyWith(
                          color: canOrder ? AppColors.textPrimary : AppColors.textTertiary,
                        ),
                      ),
                      if (item.addOns.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(
                          '• Customisable',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.ochre,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),

            // Image & Add Button Stack
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 96,
                    height: 96,
                    child: Image.network(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.surfaceVariant,
                        child: const Icon(Icons.fastfood, color: AppColors.textTertiary),
                      ),
                    ),
                  ),
                ),

                // Add button pill overlapping bottom of image
                Positioned(
                  bottom: -10,
                  right: 8,
                  left: 8,
                  child: Container(
                    height: 28,
                    decoration: BoxDecoration(
                      color: canOrder ? AppColors.primary : AppColors.border,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: canOrder
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.18),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : [],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      canOrder ? '+ ADD' : 'UNAVAILABLE',
                      style: AppTypography.labelMedium.copyWith(
                        color: canOrder ? Colors.white : AppColors.textTertiary,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
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
