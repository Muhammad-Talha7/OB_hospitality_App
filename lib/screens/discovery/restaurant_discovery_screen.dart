import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../providers/restaurant_provider.dart';
import '../../models/restaurant.dart';
import 'restaurant_profile_screen.dart';
import '../../widgets/app_loader.dart';

class RestaurantDiscoveryScreen extends StatefulWidget {
  const RestaurantDiscoveryScreen({super.key});

  @override
  State<RestaurantDiscoveryScreen> createState() => _RestaurantDiscoveryScreenState();
}

class _RestaurantDiscoveryScreenState extends State<RestaurantDiscoveryScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController(viewportFraction: 1.0);
  int _currentPage = 0;
  late AnimationController _textAnimController;
  late Animation<Offset> _textSlide;
  late Animation<double> _textFade;

  // Placeholder hero images per restaurant (will be replaced by assets later)
  static const List<String> _heroImages = [
    'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=1200&auto=format&fit=crop&q=90',
    'https://images.unsplash.com/photo-1552611052-33e04de081de?w=1200&auto=format&fit=crop&q=90',
    'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=1200&auto=format&fit=crop&q=90',
    'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=1200&auto=format&fit=crop&q=90',
  ];

  @override
  void initState() {
    super.initState();
    _textAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textAnimController,
      curve: Curves.easeOutCubic,
    ));
    _textFade = CurvedAnimation(
      parent: _textAnimController,
      curve: Curves.easeOut,
    );
    _textAnimController.forward();
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    _textAnimController.reset();
    _textAnimController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _textAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RestaurantProvider>();
    final restaurants = provider.restaurants;

    // Make status bar icons white (light) since background is dark
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    if (provider.isLoading && restaurants.isEmpty) return const AppLoader();

    if (restaurants.isEmpty) {
      return const Scaffold(
        backgroundColor: AppColors.primary,
        body: Center(
          child: Text('No restaurants available.', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // ── Full-screen PageView (hero images) ───────────────────────
          PageView.builder(
            controller: _pageController,
            itemCount: restaurants.length,
            onPageChanged: _onPageChanged,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final restaurant = restaurants[index];
              final heroUrl = index < _heroImages.length
                  ? _heroImages[index]
                  : restaurant.imageUrl;

              return _HeroPage(
                restaurant: restaurant,
                heroImageUrl: heroUrl,
                isActive: index == _currentPage,
              );
            },
          ),

          // ── Top Bar: Logo + Search ───────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Logo
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/Logo_transparent.png',
                          height: 32,
                          width: 32,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Image.asset(
                            'assets/images/Logo_black.jpg',
                            height: 32,
                            width: 32,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'OB Hospitality',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),

                    // Search icon
                    GestureDetector(
                      onTap: () => _showSearchSheet(context),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
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
            ),
          ),

          // ── Bottom overlay: text + dots + CTA ───────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomOverlay(
              restaurants: restaurants,
              currentPage: _currentPage,
              textSlide: _textSlide,
              textFade: _textFade,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => RestaurantProfileScreen(
                      restaurantId: restaurants[_currentPage].id,
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Swipe hint arrows ────────────────────────────────────────
          if (restaurants.length > 1) ...[
            if (_currentPage > 0)
              Positioned(
                left: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _SwipeArrow(
                    icon: Icons.chevron_left_rounded,
                    onTap: () => _pageController.previousPage(
                      duration: const Duration(milliseconds: 450),
                      curve: Curves.easeInOutCubic,
                    ),
                  ),
                ),
              ),
            if (_currentPage < restaurants.length - 1)
              Positioned(
                right: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _SwipeArrow(
                    icon: Icons.chevron_right_rounded,
                    onTap: () => _pageController.nextPage(
                      duration: const Duration(milliseconds: 450),
                      curve: Curves.easeInOutCubic,
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  void _showSearchSheet(BuildContext context) {
    final provider = context.read<RestaurantProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SearchSheet(provider: provider),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero Page (one restaurant full-screen slide)
// ─────────────────────────────────────────────────────────────────────────────

class _HeroPage extends StatelessWidget {
  final Restaurant restaurant;
  final String heroImageUrl;
  final bool isActive;

  const _HeroPage({
    required this.restaurant,
    required this.heroImageUrl,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Food hero image
        Image.network(
          heroImageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(color: AppColors.primary),
        ),

        // Full-height scrim: dark at top + darker at bottom
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.45),
                Colors.transparent,
                Colors.transparent,
                Colors.black.withValues(alpha: 0.88),
              ],
              stops: const [0.0, 0.3, 0.45, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom Overlay
// ─────────────────────────────────────────────────────────────────────────────

class _BottomOverlay extends StatelessWidget {
  final List<Restaurant> restaurants;
  final int currentPage;
  final Animation<Offset> textSlide;
  final Animation<double> textFade;
  final VoidCallback onTap;

  const _BottomOverlay({
    required this.restaurants,
    required this.currentPage,
    required this.textSlide,
    required this.textFade,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final r = restaurants[currentPage];

    return Container(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 0),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cuisine badge
              SlideTransition(
                position: textSlide,
                child: FadeTransition(
                  opacity: textFade,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: Color(r.crescentColorValue).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      r.cuisine.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Restaurant name — large editorial
              SlideTransition(
                position: textSlide,
                child: FadeTransition(
                  opacity: textFade,
                  child: Text(
                    r.name,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 38,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.1,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Tagline
              SlideTransition(
                position: textSlide,
                child: FadeTransition(
                  opacity: textFade,
                  child: Text(
                    r.tagline,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.72),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // Meta: time · fee · rating
              FadeTransition(
                opacity: textFade,
                child: Row(
                  children: [
                    _MetaChip(icon: Icons.schedule_rounded, label: r.estimatedTime),
                    const SizedBox(width: 12),
                    _MetaChip(
                      icon: Icons.delivery_dining_rounded,
                      label: 'PKR ${r.deliveryFee.toStringAsFixed(0)}',
                    ),
                    const SizedBox(width: 12),
                    _MetaChip(
                      icon: Icons.star_rounded,
                      label: r.rating.toStringAsFixed(1),
                      color: const Color(0xFFEAB308),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Row: page dots + CTA button
              Row(
                children: [
                  // Page dots
                  Row(
                    children: List.generate(restaurants.length, (i) {
                      final isActive = i == currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.only(right: 6),
                        width: isActive ? 22 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      );
                    }),
                  ),

                  const Spacer(),

                  // Order Now CTA
                  GestureDetector(
                    onTap: onTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.ochre,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.ochre.withValues(alpha: 0.45),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'Order Now',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded,
                              color: Colors.white, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small helpers
// ─────────────────────────────────────────────────────────────────────────────

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _MetaChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color ?? Colors.white70),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color ?? Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _SwipeArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SwipeArrow({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: Icon(icon, color: Colors.white.withValues(alpha: 0.7), size: 22),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Search bottom sheet
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
              hintText: 'Search kitchens, dishes...',
              prefixIcon:
                  const Icon(Icons.search_rounded, color: AppColors.textTertiary),
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
