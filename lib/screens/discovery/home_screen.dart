import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../providers/restaurant_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/restaurant.dart';
import '../../models/menu_item.dart';
import '../menu/item_detail_sheet.dart';
import '../checkout/auth_sheet.dart';
import '../main_scaffold.dart';
import 'restaurant_profile_screen.dart';
import '../../widgets/app_loader.dart';
import '../../widgets/quick_add_helper.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onOpenKitchens;
  final ValueChanged<int>? onOpenTab;

  const HomeScreen({super.key, this.onOpenKitchens, this.onOpenTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PageController _heroController = PageController();
  int _activeHeroIndex = 0;
  Timer? _heroTimer;
  Timer? _popularDishTimer;
  int _activePopularDishIndex = 0;
  bool _pushNotifications = true;
  bool _hapticFeedback = true;

  final Set<String> _favoriteItemIds = {};

  void _openKitchensTab() {
    if (widget.onOpenKitchens != null) {
      widget.onOpenKitchens!();
    } else {
      MainScaffold.switchToTab(context, 1);
    }
  }

  void _openTab(int index) {
    if (widget.onOpenTab != null) {
      widget.onOpenTab!(index);
    } else {
      MainScaffold.switchToTab(context, index);
    }
  }

  // Kitchen showcase images mapping
  static const Map<String, String> _kitchenImages = {
    'rest_01':
        'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&auto=format&fit=crop&q=80',
    'rest_02':
        'https://images.unsplash.com/photo-1552611052-33e04de081de?w=800&auto=format&fit=crop&q=80',
    'rest_03':
        'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800&auto=format&fit=crop&q=80',
    'rest_04':
        'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800&auto=format&fit=crop&q=80',
  };

  // Featured slides for the top hero banner (5 distinct gourmet sections)
  final List<Map<String, String>> _heroSlides = [
    {
      'tag': 'PREMIUM',
      'titlePrimary': 'Menu',
      'titleSecondary': 'Recipe',
      'description':
          'Artisan culinary recipes & gourmet dining crafted by master chefs.',
      'imageUrl':
          'https://images.unsplash.com/photo-1544025162-d76694265947?w=600&auto=format&fit=crop&q=80',
    },
    {
      'tag': 'CHEF\'S CHOICE',
      'titlePrimary': 'Truffle',
      'titleSecondary': 'Risotto',
      'description':
          'Slow-stirred arborio with wild porcini, white wine & black truffle oil.',
      'imageUrl':
          'https://images.unsplash.com/photo-1476124369491-e7addf5db371?w=600&auto=format&fit=crop&q=80',
    },
    {
      'tag': 'ARTISAN',
      'titlePrimary': 'Smoked',
      'titleSecondary': 'Salmon',
      'description':
          'Cold-smoked Atlantic salmon on toasted muffin with velvet hollandaise.',
      'imageUrl':
          'https://images.unsplash.com/photo-1608039829572-78524f79c4c7?w=600&auto=format&fit=crop&q=80',
    },
    {
      'tag': 'SIGNATURE CUT',
      'titlePrimary': 'Prime Wagyu',
      'titleSecondary': 'Ribeye',
      'description':
          'Flame-grilled prime ribeye with roasted bone marrow butter & thyme jus.',
      'imageUrl':
          'https://images.unsplash.com/photo-1558030006-450675393462?w=600&auto=format&fit=crop&q=80',
    },
    {
      'tag': 'HAUTE DOLCE',
      'titlePrimary': 'Belgian',
      'titleSecondary': 'Fondant',
      'description':
          'Molten Valrhona dark chocolate fondant with Madagascar vanilla gelato.',
      'imageUrl':
          'https://images.unsplash.com/photo-1624353365286-3f8d62daad51?w=600&auto=format&fit=crop&q=80',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startHeroAutoScroll();
    _startPopularAutoLoop();
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

  void _startPopularAutoLoop() {
    _popularDishTimer?.cancel();
    _popularDishTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      setState(() {
        _activePopularDishIndex = (_activePopularDishIndex + 1) % 4;
      });
    });
  }

  @override
  void dispose() {
    _heroTimer?.cancel();
    _popularDishTimer?.cancel();
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
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    if (provider.isLoading && restaurants.isEmpty) return const AppLoader();

    // Collect all menu items across all kitchens
    final List<MenuItem> allMenuItems = [];
    for (final r in restaurants) {
      allMenuItems.addAll(r.menuItems);
    }

    // Featured items: top 10 across all kitchens
    final List<MenuItem> displayedItems = allMenuItems.take(10).toList();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.darkBackground,
      drawer: _buildAppDrawer(context),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // ─── TOP SECTION: Dark Background with Header & Hero Banner ─────
            Container(
              color: AppColors.darkBackground,
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
                              _scaffoldKey.currentState?.openDrawer();
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.15,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.search_rounded,
                                      color: AppColors.textPrimary,
                                      size: 19,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'OB Hospitality Group',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: AppColors.textSecondary,
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
                        onPageChanged: (idx) =>
                            setState(() => _activeHeroIndex = idx),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        slide['tag']!,
                                        style: GoogleFonts.plusJakartaSans(
                                          color: AppColors.ochre,
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
                                              text:
                                                  '${slide['titlePrimary']!} \n',
                                              style:
                                                  GoogleFonts.playfairDisplay(
                                                    color: Colors.white,
                                                    fontSize: 34,
                                                    fontWeight: FontWeight.w700,
                                                    height: 1.05,
                                                  ),
                                            ),
                                            TextSpan(
                                              text: slide['titleSecondary']!,
                                              style:
                                                  GoogleFonts.playfairDisplay(
                                                    color: AppColors.ochre,
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
                                          color: Colors.white.withValues(
                                            alpha: 0.65,
                                          ),
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
                                                color: const Color(
                                                  0xFFE5BA73,
                                                ).withValues(alpha: 0.18),
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
                                            errorBuilder: (_, _, _) =>
                                                Container(
                                                  width: 142,
                                                  height: 142,
                                                  color: Colors.white10,
                                                  child: const Icon(
                                                    Icons.restaurant,
                                                    color: Colors.white54,
                                                  ),
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
                                                final item =
                                                    allMenuItems[index %
                                                        allMenuItems.length];
                                                final rest = restaurants
                                                    .firstWhere(
                                                      (r) =>
                                                          r.id ==
                                                          item.restaurantId,
                                                      orElse: () =>
                                                          restaurants.first,
                                                    );
                                                ItemDetailSheet.show(
                                                  context,
                                                  item: item,
                                                  restaurant: rest,
                                                );
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
                                                    color: Colors.black
                                                        .withValues(
                                                          alpha: 0.25,
                                                        ),
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

                    // Carousel Dots (dynamically matches _heroSlides count)
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(_heroSlides.length, (dotIndex) {
                          final isActive = dotIndex == _activeHeroIndex;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(
                              horizontal: 3,
                              vertical: 8,
                            ),
                            width: isActive ? 16 : 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.ochre
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
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 24),
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
                          color: AppColors.textPrimary,
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
                            onQuickAdd: () => CartHelper.quickAddToCart(
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
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
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
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    'https://images.unsplash.com/photo-1577219491135-ce391730fb2c?w=300&auto=format&fit=crop&q=80',
                                    width: 54,
                                    height: 54,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Container(
                                      width: 54,
                                      height: 54,
                                      color: Colors.white12,
                                      child: const Icon(
                                        Icons.person,
                                        color: Colors.white54,
                                      ),
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
                                      color: AppColors.ochre,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.darkBackground,
                                        width: 2,
                                      ),
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
                                          color: AppColors.ochre,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.star_rounded,
                                        color: AppColors.ochre,
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
                                      color: Colors.white.withValues(
                                        alpha: 0.55,
                                      ),
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
                                          builder: (_) =>
                                              RestaurantProfileScreen(
                                                restaurantId:
                                                    restaurants.first.id,
                                              ),
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.ochre,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Explore',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: AppColors.darkBackground,
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
                              color: AppColors.textPrimary,
                            ),
                          ),
                          GestureDetector(
                            onTap: _openKitchensTab,
                            child: Row(
                              children: [
                                Text(
                                  'Swipe View',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.ochre,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: AppColors.ochre,
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
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.border,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      bottomLeft: Radius.circular(12),
                                    ),
                                    child: Image.network(
                                      _kitchenImages[restaurant.id] ??
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                                color: AppColors.ochre,
                                                size: 15,
                                              ),
                                              const SizedBox(width: 2),
                                              Text(
                                                restaurant.rating.toString(),
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 11,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Flexible(
                                                child: Text(
                                                  restaurant.estimatedTime,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: GoogleFonts.plusJakartaSans(
                                                    fontSize: 10,
                                                    color: AppColors.textSecondary,
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
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 36),

                    // ─── Today's Specials: 2x2 Curated Tile Grid ──────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Today\'s Specials',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.terracottaSubtle,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.local_fire_department_rounded,
                                  color: AppColors.terracotta,
                                  size: 13,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Ends tonight',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.terracotta,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 2x2 Tile Grid for Today's Specials
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 114,
                                  child: _BillboardChip(
                                    label: 'Grilled',
                                    sublabel: 'Mains',
                                    discount: '20% OFF',
                                    imageUrl:
                                        'https://images.unsplash.com/photo-1544025162-d76694265947?w=300&auto=format&fit=crop&q=80',
                                    gradientColor: const Color(0xFFB33000),
                                    onTap: () {
                                      provider.setSearchQuery('Steak');
                                      _showSearchSheet(context, provider);
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: SizedBox(
                                  height: 114,
                                  child: _BillboardChip(
                                    label: 'Vegan',
                                    sublabel: 'Bowls',
                                    discount: 'New',
                                    imageUrl:
                                        'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=300&auto=format&fit=crop&q=80',
                                    gradientColor: const Color(0xFF1B5E20),
                                    onTap: () {
                                      provider.setSearchQuery('Salad');
                                      _showSearchSheet(context, provider);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 114,
                                  child: _BillboardChip(
                                    label: 'Truffle',
                                    sublabel: 'Pasta',
                                    discount: 'Chef\'s Pick',
                                    imageUrl:
                                        'https://images.unsplash.com/photo-1476124369491-e7addf5db371?w=300&auto=format&fit=crop&q=80',
                                    gradientColor: const Color(0xFF4A2800),
                                    onTap: () {
                                      provider.setSearchQuery('Truffle');
                                      _showSearchSheet(context, provider);
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: SizedBox(
                                  height: 114,
                                  child: _BillboardChip(
                                    label: 'Desserts',
                                    sublabel: '& Cakes',
                                    discount: '15% OFF',
                                    imageUrl:
                                        'https://images.unsplash.com/photo-1563729784474-d77dbb933a9e?w=300&auto=format&fit=crop&q=80',
                                    gradientColor: const Color(0xFF880E4F),
                                    onTap: () {
                                      provider.setSearchQuery('Dessert');
                                      _showSearchSheet(context, provider);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 38),

                    // ─── Popular Dishes: Trending Culinary Leaderboard ────────
                    if (displayedItems.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Popular Dishes',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Top-ranked favorites trending near you',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primarySubtle,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    color: AppColors.primary,
                                    size: 13,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Top 4',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Looping accordion list: 4 dishes, 1 open at a time, cycling smoothly in a loop
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: List.generate(
                            displayedItems.take(4).length,
                            (idx) {
                              final item = displayedItems[idx];
                              final restaurant = restaurants.firstWhere(
                                (r) => r.id == item.restaurantId,
                                orElse: () => restaurants.first,
                              );
                              final isOpen = idx == _activePopularDishIndex;
                              final rank = idx + 1;
                              final isFav = _favoriteItemIds.contains(item.id);

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: AnimatedCrossFade(
                                  duration: const Duration(milliseconds: 400),
                                  firstCurve: Curves.easeOutCubic,
                                  secondCurve: Curves.easeInCubic,
                                  sizeCurve: Curves.easeInOutCubic,
                                  crossFadeState: isOpen
                                      ? CrossFadeState.showFirst
                                      : CrossFadeState.showSecond,
                                  firstChild: _buildPopularOpenHero(
                                    item: item,
                                    restaurant: restaurant,
                                    rank: rank,
                                    isFav: isFav,
                                  ),
                                  secondChild: _buildPopularClosedRow(
                                    item: item,
                                    restaurant: restaurant,
                                    rank: rank,
                                    onTap: () {
                                      setState(
                                        () => _activePopularDishIndex = idx,
                                      );
                                      _startPopularAutoLoop();
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 36),

                    // ─── Experience the Difference promo banner (Edge-to-Edge) ──
                    Container(
                      width: double.infinity,
                      height: 200,
                      clipBehavior: Clip.hardEdge,
                      decoration: const BoxDecoration(color: AppColors.darkBackground),
                      child: Stack(
                        children: [
                          Positioned(
                            right: 0,
                            top: 0,
                            bottom: 0,
                            width: 220,
                            child: Image.network(
                              'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=600&auto=format&fit=crop&q=80',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const SizedBox(),
                            ),
                          ),
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.darkBackground,
                                    AppColors.darkBackground.withValues(alpha: 0.94),
                                    AppColors.darkBackground.withValues(alpha: 0.0),
                                  ],
                                  stops: const [0.0, 0.48, 1.0],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'FINE DINING',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: AppColors.ochre,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 2.8,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Experience the\nDifference',
                                  style: GoogleFonts.playfairDisplay(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    height: 1.15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Curated tasting tables & private dining',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white.withValues(alpha: 0.65),
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                GestureDetector(
                                  onTap: () {
                                    if (restaurants.isNotEmpty) {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              RestaurantProfileScreen(
                                                restaurantId:
                                                    restaurants.first.id,
                                              ),
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withValues(alpha: 0.3),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Reserve a Table',
                                          style: GoogleFonts.plusJakartaSans(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Icon(
                                          Icons.arrow_forward_rounded,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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

  // ─────────────────────────────────────────────────────────────────────────
  // Popular Dishes: Expanded Spotlight Card (Open State)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildPopularOpenHero({
    required MenuItem item,
    required Restaurant restaurant,
    required int rank,
    required bool isFav,
  }) {
    String rankBadgeText;
    switch (rank) {
      case 1:
        rankBadgeText = '#1 MOST ORDERED';
        break;
      case 2:
        rankBadgeText = '#2 TRENDING';
        break;
      case 3:
        rankBadgeText = '#3 CHEF\'S PICK';
        break;
      default:
        rankBadgeText = '#$rank TOP RATED';
        break;
    }

    return GestureDetector(
      onTap: () =>
          ItemDetailSheet.show(context, item: item, restaurant: restaurant),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Image.network(
                    item.imageUrl,
                    height: 155,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 155,
                      color: AppColors.surfaceVariant,
                      child: const Icon(
                        Icons.fastfood,
                        color: Colors.grey,
                        size: 40,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.6),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // Badge top-left
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_fire_department_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          rankBadgeText,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Heart toggle top-right
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () => setState(() {
                      if (isFav) {
                        _favoriteItemIds.remove(item.id);
                      } else {
                        _favoriteItemIds.add(item.id);
                      }
                    }),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Icon(
                        isFav
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: isFav
                            ? const Color(0xFFE53935)
                            : const Color(0xFF999999),
                        size: 18,
                      ),
                    ),
                  ),
                ),
                // Price bottom-left
                Positioned(
                  bottom: 10,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Text(
                      'Rs. ${item.price.toInt()}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Info row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              restaurant.name,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.star_rounded,
                              color: AppColors.ochre,
                              size: 14,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              restaurant.rating.toString(),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '· ${restaurant.estimatedTime}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => CartHelper.quickAddToCart(
                      context,
                      item: item,
                      restaurant: restaurant,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Add',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
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

  // ─────────────────────────────────────────────────────────────────────────
  // Popular Dishes: Collapsed Row (Closed State)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildPopularClosedRow({
    required MenuItem item,
    required Restaurant restaurant,
    required int rank,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Rank badge
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.primarySubtle,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                '0$rank',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Square dish image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                item.imageUrl,
                width: 58,
                height: 58,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 58,
                  height: 58,
                  color: Colors.grey[200],
                  child: const Icon(
                    Icons.fastfood,
                    color: Colors.grey,
                    size: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Dish Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    restaurant.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: AppColors.ochre,
                        size: 13,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        restaurant.rating.toString(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primarySubtle,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.category,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Price & mini expand/view button
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Rs. ${item.price.toInt()}',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => CartHelper.quickAddToCart(
                    context,
                    item: item,
                    restaurant: restaurant,
                  ),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 18,
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

  // ─────────────────────────────────────────────────────────────────────────
  // Luxury Side Navigation Drawer
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildAppDrawer(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final cart = context.watch<CartProvider>();

    return Drawer(
      backgroundColor: AppColors.darkBackground,
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header with Branding & Profile Snippet
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.primary, AppColors.primaryLight],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.restaurant_menu_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'OB HOSPITALITY GROUP',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              Text(
                                'Gourmet Dining Club',
                                style: GoogleFonts.plusJakartaSans(
                                  color: AppColors.ochre,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white70,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // User Profile snippet
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [AppColors.primary, AppColors.primaryLight],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              auth.isLoggedIn && user != null
                                  ? user.name[0].toUpperCase()
                                  : 'G',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                auth.isLoggedIn && user != null
                                    ? user.name
                                    : 'Guest Diner',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                auth.isLoggedIn && user != null
                                    ? user.email
                                    : 'Tap to sign in or explore',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white54,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: Colors.white10, height: 1),

            // Scrollable Navigation & Settings Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                children: [
                  _drawerSectionTitle('NAVIGATION & PAGES'),
                  _drawerTile(
                    icon: Icons.home_rounded,
                    title: 'Home',
                    subtitle: 'Daily gourmet selections',
                    onTap: () {
                      Navigator.of(context).pop();
                      _openTab(0);
                    },
                  ),
                  _drawerTile(
                    icon: Icons.storefront_rounded,
                    title: 'Our Kitchens',
                    subtitle: 'Full-screen swipe discovery',
                    badge: 'Swipe',
                    onTap: () {
                      Navigator.of(context).pop();
                      _openTab(1);
                    },
                  ),
                  _drawerTile(
                    icon: Icons.shopping_bag_rounded,
                    title: 'My Cart',
                    subtitle: 'Your selected items',
                    countBadge: cart.itemCount > 0 ? cart.itemCount : null,
                    onTap: () {
                      Navigator.of(context).pop();
                      _openTab(2);
                    },
                  ),
                  _drawerTile(
                    icon: Icons.receipt_long_rounded,
                    title: 'Order History',
                    subtitle: 'Live tracking & previous orders',
                    onTap: () {
                      Navigator.of(context).pop();
                      _openTab(3);
                    },
                  ),
                  _drawerTile(
                    icon: Icons.person_rounded,
                    title: 'Profile & Account',
                    subtitle: 'Personal details & security',
                    onTap: () {
                      Navigator.of(context).pop();
                      _openTab(4);
                    },
                  ),

                  const SizedBox(height: 12),
                  const Divider(color: Colors.white10, height: 1),
                  const SizedBox(height: 8),

                  _drawerSectionTitle('SETTINGS & PREFERENCES'),
                  _drawerTile(
                    icon: Icons.settings_rounded,
                    title: 'App Settings',
                    subtitle: 'Notifications, currency & diet',
                    onTap: () {
                      Navigator.of(context).pop();
                      _showSettingsSheet(context);
                    },
                  ),
                  _drawerTile(
                    icon: Icons.location_on_rounded,
                    title: 'Saved Addresses',
                    subtitle: 'Delivery locations',
                    onTap: () {
                      Navigator.of(context).pop();
                      _openTab(4);
                    },
                  ),
                  _drawerTile(
                    icon: Icons.tune_rounded,
                    title: 'Mock Mode (Dev)',
                    subtitle: auth.isLoggedIn
                        ? 'Currently Logged In'
                        : 'Currently Guest',
                    badge: auth.isLoggedIn ? 'VIP' : 'GUEST',
                    onTap: () {
                      auth.toggleMockAuth();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            auth.isLoggedIn
                                ? 'Switched to Logged In Mode'
                                : 'Switched to Guest Mode',
                          ),
                          duration: const Duration(seconds: 1),
                          backgroundColor: AppColors.darkSurface,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const Divider(color: Colors.white10, height: 1),

            // Bottom Auth Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: auth.isLoggedIn
                  ? InkWell(
                      onTap: () {
                        auth.logout();
                        Navigator.of(context).pop();
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.5),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Log Out',
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.error,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    )
                  : InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        AuthSheet.show(context, onAuthenticated: () {});
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Sign In / Create Account',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 12),
            Text(
              'OB HOSPITALITY GROUP',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white24,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.8,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Settings Bottom Sheet
  // ─────────────────────────────────────────────────────────────────────────
  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'App Settings',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white70,
                          size: 20,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Notifications switch
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _pushNotifications,
                    activeThumbColor: AppColors.ochre,
                    title: Text(
                      'Order & Promo Notifications',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Receive live tracking updates and exclusive culinary drops',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                    onChanged: (val) {
                      setSheetState(() => _pushNotifications = val);
                      setState(() => _pushNotifications = val);
                    },
                  ),
                  const Divider(color: Colors.white10),

                  // Sound & Haptic Feedback switch
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _hapticFeedback,
                    activeThumbColor: AppColors.ochre,
                    title: Text(
                      'Haptic Feedback & Sounds',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Subtle vibrations on taps and dish selection',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                    onChanged: (val) {
                      setSheetState(() => _hapticFeedback = val);
                      setState(() => _hapticFeedback = val);
                    },
                  ),
                  const Divider(color: Colors.white10),

                  // Currency & Region Info
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Currency & Region',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Pakistani Rupee (PKR · Rs.)',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.ochre,
                      size: 18,
                    ),
                  ),
                  const Divider(color: Colors.white10),

                  // App info
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'OB Hospitality App',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white38,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          'v1.0.4 · Build 42',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white38,
                            fontSize: 11,
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
      },
    );
  }

  Widget _drawerSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 6),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          color: AppColors.ochre,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _drawerTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    String? badge,
    int? countBadge,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.ochre, size: 19),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white54,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primarySubtle,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge,
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            if (countBadge != null)
              Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  countBadge.toString(),
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white24,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Today's Specials — Photo-backed Billboard Chip
// ─────────────────────────────────────────────────────────────────────────────

class _BillboardChip extends StatelessWidget {
  final String label;
  final String sublabel;
  final String discount;
  final String imageUrl;
  final Color gradientColor;
  final VoidCallback? onTap;

  const _BillboardChip({
    required this.label,
    required this.sublabel,
    required this.discount,
    required this.imageUrl,
    required this.gradientColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background food photo
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: gradientColor),
              ),
              // Dark gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      gradientColor.withValues(alpha: 0.25),
                      gradientColor.withValues(alpha: 0.90),
                    ],
                  ),
                ),
              ),
              // Text content
              Padding(
                padding: const EdgeInsets.all(11),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Discount badge top
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.ochre,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        discount,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkBackground,
                        ),
                      ),
                    ),
                    // Bottom labels
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.1,
                          ),
                        ),
                        Text(
                          sublabel,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                        ),
                      ],
                    ),
                  ],
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
// Gourmet Dish Card (Dark card matching the reference image)
// ─────────────────────────────────────────────────────────────────────────────

class _DishCard extends StatelessWidget {
  final MenuItem item;
  final Restaurant restaurant;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onTap;
  final VoidCallback? onQuickAdd;

  const _DishCard({
    required this.item,
    required this.restaurant,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onTap,
    this.onQuickAdd,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 175,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
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
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Image.network(
                    item.imageUrl,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      height: 150,
                      color: AppColors.surfaceVariant,
                      child: const Icon(Icons.fastfood, color: AppColors.textTertiary),
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
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.more_horiz_rounded,
                        color: AppColors.textPrimary,
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
                            color: AppColors.textPrimary,
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
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Rs. ${item.price.toInt()}',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        GestureDetector(
                          onTap: onQuickAdd,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                              size: 18,
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
        borderRadius: BorderRadius.circular(12),
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
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.textTertiary,
              ),
              filled: true,
              fillColor: AppColors.surfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),

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