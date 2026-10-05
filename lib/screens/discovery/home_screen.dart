import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../providers/restaurant_provider.dart';
import '../../models/restaurant.dart';
import '../../models/menu_item.dart';
import '../menu/item_detail_sheet.dart';
import 'restaurant_profile_screen.dart';
import 'restaurant_discovery_screen.dart';
import '../../widgets/app_loader.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _heroController = PageController();
  int _activeHeroIndex = 0;
  Timer? _heroTimer;


  final Set<String> _favoriteItemIds = {};


  // Featured slides for the top hero banner
  final List<Map<String, String>> _heroSlides = [
    {
      'tag': 'PREMIUM',
      'titlePrimary': 'Menu',
      'titleSecondary': 'Recipe',
      'description': 'Artisan culinary recipes & gourmet dining crafted by master chefs.',
      'imageUrl': 'https://images.unsplash.com/photo-1544025162-d76694265947?w=600&auto=format&fit=crop&q=80',
    },
    {
      'tag': 'CHEF\'S CHOICE',
      'titlePrimary': 'Truffle',
      'titleSecondary': 'Risotto',
      'description': 'Slow-stirred arborio with wild porcini, white wine & black truffle oil.',
      'imageUrl': 'https://images.unsplash.com/photo-1476124369491-e7addf5db371?w=600&auto=format&fit=crop&q=80',
    },
    {
      'tag': 'ARTISAN',
      'titlePrimary': 'Smoked',
      'titleSecondary': 'Salmon',
      'description': 'Cold-smoked Atlantic salmon on toasted muffin with velvet hollandaise.',
      'imageUrl': 'https://images.unsplash.com/photo-1608039829572-78524f79c4c7?w=600&auto=format&fit=crop&q=80',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startHeroAutoScroll();
  }

  void _startHeroAutoScroll() {
    _heroTimer?.cancel();
    _heroTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted || !_heroController.hasClients) return;
      final nextIndex = (_activeHeroIndex + 1) % _heroSlides.length;
      _heroController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _heroTimer?.cancel();
    _heroController.dispose();
    super.dispose();
  }

  void _showSearchSheet(BuildContext context, RestaurantProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SearchSheet(provider: provider),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RestaurantProvider>();
    final restaurants = provider.restaurants;

    // Status bar style
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    if (provider.isLoading && restaurants.isEmpty) return const AppLoader();

    // Collect all menu items across all kitchens
    final List<MenuItem> allMenuItems = [];
    for (final r in restaurants) {
      allMenuItems.addAll(r.menuItems);
    }

    // Featured items: top 10 across all kitchens
    final List<MenuItem> displayedItems = allMenuItems.take(10).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F12),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // ─── TOP SECTION: Dark Background with Header & Hero Banner ─────
            Container(
              color: const Color(0xFF0F0F12),
              child: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Top Bar: Menu Button + Pill Search ("User center") + Action
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          // Hamburger Menu Button
                          InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const RestaurantDiscoveryScreen(),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.menu_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Center Pill Search: "User center" / Search
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _showSearchSheet(context, provider),
                              child: Container(
                                height: 42,
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.15),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.search_rounded,
                                      color: Color(0xFF333333),
                                      size: 19,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'User center',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: const Color(0xFF666666),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Right Search/Filter Icon
                          GestureDetector(
                            onTap: () => _showSearchSheet(context, provider),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.search_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ─── Hero Carousel ("PREMIUM Menu Recipe") ───────────────
                    SizedBox(
                      height: 215,
                      child: PageView.builder(
                        controller: _heroController,
                        onPageChanged: (idx) => setState(() => _activeHeroIndex = idx),
                        itemCount: _heroSlides.length,
                        itemBuilder: (context, index) {
                          final slide = _heroSlides[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                // Left text block
                                Expanded(
                                  flex: 6,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        slide['tag']!,
                                        style: GoogleFonts.plusJakartaSans(
                                          color: const Color(0xFFE5BA73),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 2.5,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: '${slide['titlePrimary']!} \n',
                                              style: GoogleFonts.playfairDisplay(
                                                color: Colors.white,
                                                fontSize: 34,
                                                fontWeight: FontWeight.w700,
                                                height: 1.05,
                                              ),
                                            ),
                                            TextSpan(
                                              text: slide['titleSecondary']!,
                                              style: GoogleFonts.playfairDisplay(
                                                color: const Color(0xFFE5BA73),
                                                fontSize: 34,
                                                fontStyle: FontStyle.italic,
                                                fontWeight: FontWeight.w600,
                                                height: 1.05,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        slide['description']!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.plusJakartaSans(
                                          color: Colors.white.withValues(alpha: 0.65),
                                          fontSize: 11,
                                          height: 1.35,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 12),

                                // Right circular dish image with floating button
                                Expanded(
                                  flex: 5,
                                  child: Center(
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      alignment: Alignment.center,
                                      children: [
                                        // Ambient glow ring
                                        Container(
                                          width: 146,
                                          height: 146,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFFE5BA73).withValues(alpha: 0.18),
                                                blurRadius: 24,
                                                spreadRadius: 2,
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Circular dish image
                                        ClipOval(
                                          child: Image.network(
                                            slide['imageUrl']!,
                                            width: 142,
                                            height: 142,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, _, _) => Container(
                                              width: 142,
                                              height: 142,
                                              color: Colors.white10,
                                              child: const Icon(Icons.restaurant, color: Colors.white54),
                                            ),
                                          ),
                                        ),

                                        // Overlaid floating "..." circle button
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: GestureDetector(
                                            onTap: () {
                                              if (allMenuItems.isNotEmpty) {
                                                final item = allMenuItems[index % allMenuItems.length];
                                                final rest = restaurants.firstWhere(
                                                  (r) => r.id == item.restaurantId,
                                                  orElse: () => restaurants.first,
                                                );
                                                ItemDetailSheet.show(context, item: item, restaurant: rest);
                                              }
                                            },
                                            child: Container(
                                              width: 38,
                                              height: 38,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withValues(alpha: 0.25),
                                                    blurRadius: 10,
                                                    offset: const Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: const Icon(
                                                Icons.more_horiz_rounded,
                                                color: Colors.black87,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // Carousel Dots (5 dots)
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(5, (dotIndex) {
                          final isActive = dotIndex == _activeHeroIndex;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
                            width: isActive ? 16 : 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFFE5BA73)
                                  : Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // ─── LOWER SECTION: Curved White Floating Sheet ─────────────────
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(34),
                  topRight: Radius.circular(34),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // "Featured Items" heading — clean, no filters
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Featured Items',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF111111),
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ─── Horizontal Gourmet Dish Cards ───────────────────────
                    SizedBox(
                      height: 235,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: displayedItems.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 14),
                        itemBuilder: (context, itemIdx) {
                          final item = displayedItems[itemIdx];
                          final isFav = _favoriteItemIds.contains(item.id);
                          final restaurant = restaurants.firstWhere(
                            (r) => r.id == item.restaurantId,
                            orElse: () => restaurants.first,
                          );

                          return _DishCard(
                            item: item,
                            restaurant: restaurant,
                            isFavorite: isFav,
                            onToggleFavorite: () {
                              setState(() {
                                if (isFav) {
                                  _favoriteItemIds.remove(item.id);
                                } else {
                                  _favoriteItemIds.add(item.id);
                                }
                              });
                            },
                            onTap: () => ItemDetailSheet.show(
                              context,
                              item: item,
                              restaurant: restaurant,
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ─── Chef's Recommendation / Degustation Card ────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF141416),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Chef avatar with active dot
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: Image.network(
                                    'https://images.unsplash.com/photo-1577219491135-ce391730fb2c?w=300&auto=format&fit=crop&q=80',
                                    width: 54,
                                    height: 54,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Container(
                                      width: 54,
                                      height: 54,
                                      color: Colors.white12,
                                      child: const Icon(Icons.person, color: Colors.white54),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: -2,
                                  right: -2,
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE5BA73),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xFF141416), width: 2),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(width: 14),

                            // Middle Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Special Selection',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: const Color(0xFFE5BA73),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.star_rounded,
                                        color: Color(0xFFE5BA73),
                                        size: 13,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Chef\'s Tasting Box',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '5-course curated artisan menu',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white.withValues(alpha: 0.55),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Right Action
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Tonight →',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white.withValues(alpha: 0.45),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                GestureDetector(
                                  onTap: () {
                                    if (restaurants.isNotEmpty) {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => RestaurantProfileScreen(
                                            restaurantId: restaurants.first.id,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE5BA73),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'Explore',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: const Color(0xFF141416),
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ─── Our Kitchens Section ───────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Our Kitchens',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF111111),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const RestaurantDiscoveryScreen(),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                Text(
                                  'Swipe View',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFD9822B),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Color(0xFFD9822B),
                                  size: 15,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Kitchens horizontal list
                    SizedBox(
                      height: 130,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: restaurants.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 14),
                        itemBuilder: (context, idx) {
                          final restaurant = restaurants[idx];
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => RestaurantProfileScreen(
                                    restaurantId: restaurant.id,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: 220,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7F7F9),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: const Color(0xFFEAEAEA)),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(18),
                                      bottomLeft: Radius.circular(18),
                                    ),
                                    child: Image.network(
                                      restaurant.imageUrl,
                                      width: 85,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => Container(
                                        width: 85,
                                        color: Colors.grey[200],
                                        child: const Icon(Icons.store),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            restaurant.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                              color: const Color(0xFF141416),
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            restaurant.cuisine,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11,
                                              color: const Color(0xFF888888),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.star_rounded,
                                                color: Color(0xFFD9822B),
                                                size: 15,
                                              ),
                                              const SizedBox(width: 2),
                                              Text(
                                                restaurant.rating.toString(),
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 11,
                                                  color: const Color(0xFF222222),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                restaurant.estimatedTime,
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 10,
                                                  color: const Color(0xFF888888),
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
                          );
                        },
                      ),
                    ),
                  ],
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
// Gourmet Dish Card (Dark card matching the reference image)
// ─────────────────────────────────────────────────────────────────────────────

class _DishCard extends StatelessWidget {
  final MenuItem item;
  final Restaurant restaurant;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onTap;

  const _DishCard({
    required this.item,
    required this.restaurant,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 175,
        decoration: BoxDecoration(
          color: const Color(0xFF141416),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image with action button overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(22),
                    topRight: Radius.circular(22),
                  ),
                  child: Image.network(
                    item.imageUrl,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      height: 150,
                      color: Colors.white10,
                      child: const Icon(Icons.fastfood, color: Colors.white30),
                    ),
                  ),
                ),

                // Floating "..." button on top-right of image (as in reference)
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: onTap,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.more_horiz_rounded,
                        color: Colors.black,
                        size: 17,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Bottom text info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          restaurant.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white.withValues(alpha: 0.55),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Rs. ${item.price.toInt()}',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
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
// Interactive Search Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _SearchSheet extends StatefulWidget {
  final RestaurantProvider provider;
  const _SearchSheet({required this.provider});

  @override
  State<_SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<_SearchSheet> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 20,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _ctrl,
            autofocus: true,
            onChanged: (v) => widget.provider.setSearchQuery(v),
            decoration: InputDecoration(
              hintText: 'Search kitchens, dishes, ingredients...',
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textTertiary),
              filled: true,
              fillColor: AppColors.surfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
