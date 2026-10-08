import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../models/restaurant.dart';

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback onTap;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final crescentColor = Color(restaurant.crescentColorValue);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 260,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.13),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Background food image ──────────────────────────────────
            Image.network(
              restaurant.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: AppColors.surfaceVariant,
                child: const Center(
                  child: Icon(Icons.restaurant, size: 48, color: AppColors.textTertiary),
                ),
              ),
            ),

            // ── Closed dim overlay ─────────────────────────────────────
            if (!restaurant.isOpen)
              Container(color: Colors.black.withValues(alpha: 0.50)),

            // ── Bottom gradient scrim ──────────────────────────────────
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.15),
                      Colors.black.withValues(alpha: 0.72),
                    ],
                    stops: const [0.35, 0.55, 1.0],
                  ),
                ),
              ),
            ),

            // ── Top badges ────────────────────────────────────────────
            Positioned(
              top: 14,
              left: 14,
              right: 14,
              child: Row(
                children: [
                  // Open / Closed pill
                  _StatusPill(isOpen: restaurant.isOpen),
                  const Spacer(),
                  // Rating pill
                  _RatingPill(
                    rating: restaurant.rating,
                    count: restaurant.reviewCount,
                  ),
                ],
              ),
            ),

            // ── Bottom info overlay ────────────────────────────────────
            Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Cuisine tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: crescentColor.withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      restaurant.cuisine,
                      style: AppTypography.labelMedium.copyWith(
                        color: Colors.white,
                        fontSize: 10.5,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Restaurant name
                  Text(
                    restaurant.name,
                    style: AppTypography.displaySmall.copyWith(
                      color: Colors.white,
                      fontSize: 22,
                      height: 1.15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Tagline
                  Text(
                    restaurant.tagline,
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.78),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Meta row: time · delivery
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded, size: 13, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(
                        restaurant.estimatedTime,
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '·',
                        style: AppTypography.bodySmall.copyWith(color: Colors.white54),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.delivery_dining_rounded, size: 14, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(
                        '\$${restaurant.deliveryFee.toStringAsFixed(2)} delivery',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Closed label centred ───────────────────────────────────
            if (!restaurant.isOpen)
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'CLOSED  •  ${restaurant.openingHours}',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _StatusPill extends StatelessWidget {
  final bool isOpen;
  const _StatusPill({required this.isOpen});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isOpen ? AppColors.forest : AppColors.darkBackground,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isOpen ? AppColors.forestLight : AppColors.error,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isOpen ? 'OPEN' : 'CLOSED',
            style: AppTypography.labelMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingPill extends StatelessWidget {
  final double rating;
  final int count;
  const _RatingPill({required this.rating, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 14, color: AppColors.ochre),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            '($count)',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textTertiary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
