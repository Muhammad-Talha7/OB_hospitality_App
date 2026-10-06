import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/restaurant.dart';
import '../../models/menu_item.dart';
import '../../providers/cart_provider.dart';
import '../../providers/restaurant_provider.dart';
import '../cart/cart_screen.dart';
import '../../widgets/app_loader.dart';
import '../menu/item_detail_sheet.dart';
import '../../widgets/quick_add_helper.dart';

class RestaurantProfileScreen extends StatefulWidget {
  final String restaurantId;

  const RestaurantProfileScreen({
    super.key,
    required this.restaurantId,
  });

  @override
  State<RestaurantProfileScreen> createState() => _RestaurantProfileScreenState();
}

class _RestaurantProfileScreenState extends State<RestaurantProfileScreen> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _sectionKeys = {};
  String _activeCategory = 'All';

  static const Set<int> _popularIndices = {0, 1, 3};
  static const Set<int> _chefPickIndices = {2, 5};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RestaurantProvider>().selectRestaurant(widget.restaurantId);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSection(String category) {
    setState(() => _activeCategory = category);
    final key = _sectionKeys[category];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    final restaurant = context.watch<RestaurantProvider>().selectedRestaurant;
    final cart = context.watch<CartProvider>();

    if (restaurant == null) {
      return const AppLoader();
    }

    for (final cat in restaurant.categories) {
      _sectionKeys.putIfAbsent(cat, () => GlobalKey());
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildHeroAppBar(restaurant),
              SliverToBoxAdapter(child: _buildInfoStrip(restaurant)),
              if (!restaurant.isOpen)
                SliverToBoxAdapter(child: _buildClosedBanner(restaurant)),
              SliverPersistentHeader(
                pinned: true,
                delegate: _CategoryBarDelegate(
                  categories: restaurant.categories,
                  activeCategory: _activeCategory,
                  onSelect: _scrollToSection,
                ),
              ),
              ..._buildMenuSections(context, restaurant),
              SliverToBoxAdapter(child: _buildSectionHeader('Guest Reviews', null, Icons.format_quote_rounded)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 140),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, idx) => _ReviewCard(review: restaurant.reviews[idx]),
                    childCount: restaurant.reviews.length,
                  ),
                ),
              ),
            ],
          ),

          // Floating back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),

          // Cart bar
          if (cart.restaurantId == restaurant.id && !cart.isEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildCartBar(context, cart),
            ),
        ],
      ),
    );
  }

  Widget _buildHeroAppBar(Restaurant restaurant) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              restaurant.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) => Container(color: const Color(0xFFEEEEEE)),
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.5, 1.0],
                  colors: [
                    Color(0x55000000),
                    Color(0x22000000),
                    Color(0xDD000000),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: restaurant.isOpen
                          ? const Color(0xFF5FB760)
                          : const Color(0xFFD65839),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      restaurant.isOpen ? '● OPEN  ${restaurant.openingHours}' : '● CLOSED',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    restaurant.name,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    restaurant.tagline,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoStrip(Restaurant restaurant) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _InfoChip(Icons.star_rounded, '${restaurant.rating}  (${restaurant.reviewCount})', const Color(0xFFC4892A)),
          _InfoChip(Icons.schedule_rounded, restaurant.estimatedTime, const Color(0xFF888888)),
          _InfoChip(Icons.delivery_dining_rounded, 'Rs. ${restaurant.deliveryFee.toStringAsFixed(0)}', const Color(0xFF888888)),
        ],
      ),
    );
  }

  Widget _buildClosedBanner(Restaurant restaurant) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF0ED),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD65839).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.store_mall_directory_outlined, color: Color(0xFFD65839), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${restaurant.openingHours}. You can browse, but ordering is paused.',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFFD65839),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMenuSections(BuildContext context, Restaurant restaurant) {
    final sections = <Widget>[];
    int globalIndex = 0;

    // Popular Picks section
    final popularItems = restaurant.menuItems.take(4).toList();
    sections.add(SliverToBoxAdapter(
      child: _buildSectionHeader('Popular Picks', 'Our most-ordered dishes', Icons.local_fire_department_rounded),
    ));
    sections.add(SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (ctx, idx) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _MenuItemCard(
              item: popularItems[idx],
              restaurantIsOpen: restaurant.isOpen,
              badge: idx == 0 ? _Badge.chefPick : _Badge.popular,
              onTap: () => ItemDetailSheet.show(context, item: popularItems[idx], restaurant: restaurant),
              onQuickAdd: () => CartHelper.quickAddToCart(context, item: popularItems[idx], restaurant: restaurant),
            ),
          ),
          childCount: popularItems.length,
        ),
      ),
    ));

    // Category sections
    for (final category in restaurant.categories) {
      final items = restaurant.menuItems.where((m) => m.category == category).toList();
      if (items.isEmpty) continue;

      final sectionKey = _sectionKeys[category]!;
      sections.add(SliverToBoxAdapter(
        key: sectionKey,
        child: _buildSectionHeader(category, null, null),
      ));

      sections.add(SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (ctx, idx) {
              final item = items[idx];
              final badge = _chefPickIndices.contains(globalIndex)
                  ? _Badge.chefPick
                  : _popularIndices.contains(globalIndex)
                      ? _Badge.popular
                      : _Badge.none;
              globalIndex++;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _MenuItemCard(
                  item: item,
                  restaurantIsOpen: restaurant.isOpen,
                  badge: badge,
                  onTap: () => ItemDetailSheet.show(context, item: item, restaurant: restaurant),
                  onQuickAdd: () => CartHelper.quickAddToCart(context, item: item, restaurant: restaurant),
                ),
              );
            },
            childCount: items.length,
          ),
        ),
      ));
    }

    return sections;
  }

  Widget _buildSectionHeader(String title, String? subtitle, IconData? icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
      child: Row(
        children: [
          if (icon != null)
            Icon(icon, color: const Color(0xFFE5BA73), size: 18)
          else
            Container(
              width: 3,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFFE5BA73),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF111111),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFFAAAAAA),
                    fontSize: 11,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCartBar(BuildContext context, CartProvider cart) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 14, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CartScreen()),
        ),
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            color: const Color(0xFFE5BA73),
            borderRadius: BorderRadius.circular(27),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${cart.itemCount}',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'View Cart',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Text(
                  'Rs. ${cart.total.toStringAsFixed(0)}',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category Bar
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryBarDelegate extends SliverPersistentHeaderDelegate {
  final List<String> categories;
  final String activeCategory;
  final ValueChanged<String> onSelect;

  const _CategoryBarDelegate({
    required this.categories,
    required this.activeCategory,
    required this.onSelect,
  });

  @override
  double get minExtent => 56;
  @override
  double get maxExtent => 56;

  @override
  bool shouldRebuild(_CategoryBarDelegate old) =>
      old.activeCategory != activeCategory;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (ctx, idx) {
          final cat = idx == 0 ? 'All' : categories[idx - 1];
          final isActive = cat == activeCategory;
          return GestureDetector(
            onTap: () => onSelect(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFFE5BA73) : const Color(0xFFF3F3F6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                cat,
                style: GoogleFonts.plusJakartaSans(
                  color: isActive ? Colors.white : const Color(0xFF666666),
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Badge
// ─────────────────────────────────────────────────────────────────────────────

enum _Badge { none, popular, chefPick }

// ─────────────────────────────────────────────────────────────────────────────
// Menu Item Card — white, clean
// ─────────────────────────────────────────────────────────────────────────────

class _MenuItemCard extends StatelessWidget {
  final MenuItem item;
  final bool restaurantIsOpen;
  final _Badge badge;
  final VoidCallback onTap;
  final VoidCallback? onQuickAdd;

  const _MenuItemCard({
    required this.item,
    required this.restaurantIsOpen,
    required this.badge,
    required this.onTap,
    this.onQuickAdd,
  });

  @override
  Widget build(BuildContext context) {
    final canOrder = restaurantIsOpen && item.isAvailable;

    return GestureDetector(
      onTap: canOrder ? onTap : null,
      child: Opacity(
        opacity: canOrder ? 1.0 : 0.5,
        child: Container(
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      bottomLeft: Radius.circular(18),
                    ),
                    child: Image.network(
                      item.imageUrl,
                      width: 110,
                      height: 110,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => Container(
                        width: 110,
                        height: 110,
                        color: const Color(0xFFF3F3F6),
                        child: const Icon(Icons.fastfood, color: Color(0xFFCCCCCC), size: 30),
                      ),
                    ),
                  ),
                  if (badge != _Badge.none)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: _BadgePill(badge: badge),
                    ),
                ],
              ),

              // Text
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF111111),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF9E9E9E),
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rs. ${item.price.toStringAsFixed(0)}',
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFF111111),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              if (item.addOns.isNotEmpty)
                                Text(
                                  'Customisable',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: const Color(0xFFC4892A),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
                          ),
                          GestureDetector(
                            onTap: canOrder ? onQuickAdd : null,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: canOrder ? const Color(0xFFE5BA73) : const Color(0xFFF3F3F6),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                canOrder ? Icons.add_rounded : Icons.block_rounded,
                                color: canOrder ? const Color(0xFF141416) : const Color(0xFFCCCCCC),
                                size: 17,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BadgePill extends StatelessWidget {
  final _Badge badge;
  const _BadgePill({required this.badge});

  @override
  Widget build(BuildContext context) {
    final (label, bg, icon) = badge == _Badge.chefPick
        ? ("Chef's Pick", const Color(0xFFE5BA73), Icons.workspace_premium_rounded)
        : ("Popular", const Color(0xFFD65839), Icons.local_fire_department_rounded);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: Colors.white),
          const SizedBox(width: 3),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Info Chip
// ─────────────────────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip(this.icon, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFF444444),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Review Card
// ─────────────────────────────────────────────────────────────────────────────

class _ReviewCard extends StatelessWidget {
  final dynamic review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                review.authorName as String,
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF111111),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star_rounded, size: 14, color: Color(0xFFE5BA73)),
                  const SizedBox(width: 4),
                  Text(
                    (review.rating as num).toStringAsFixed(1),
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFFC4892A),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review.comment as String,
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFF888888),
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
