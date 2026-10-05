import 'dart:async';
import '../models/restaurant.dart';
import '../models/menu_item.dart';
import '../models/review.dart';

abstract class RestaurantRepository {
  Future<List<Restaurant>> getRestaurants({String? query, String? cuisine});
  Future<Restaurant?> getRestaurantById(String id);
  Future<void> submitReview(String restaurantId, Review review);
}

class MockRestaurantRepository implements RestaurantRepository {
  final List<Restaurant> _restaurants = [

    // ─── 1. CAFÉ AYLANTO ──────────────────────────────────────────────────────
    Restaurant(
      id: 'rest_01',
      name: 'Café Aylanto',
      tagline: 'Continental favourites, wood-fired pizzas & Karachi\'s finest brunch',
      cuisine: 'Continental & Café',
      rating: 4.8,
      reviewCount: 124,
      estimatedTime: '30–45 min',
      deliveryFee: 149,
      minOrder: 800,
      isOpen: true,
      openingHours: '9:00 AM – 11:30 PM',
      imageUrl: 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800&auto=format&fit=crop&q=80',
      crescentColorValue: 0xFF1B3A4B,
      address: 'Phase V, DHA, Karachi',
      categories: ['Brunch', 'Pasta & Risotto', 'Wood-Fired Pizza', 'Mains', 'Desserts', 'Beverages'],
      menuItems: [
        const MenuItem(
          id: 'ayl_01',
          restaurantId: 'rest_01',
          name: 'Eggs Benedict with Smoked Salmon',
          description: 'Toasted English muffin topped with cold-smoked Atlantic salmon, perfectly poached eggs and rich hollandaise sauce, served with mixed greens.',
          price: 1190,
          category: 'Brunch',
          imageUrl: 'https://images.unsplash.com/photo-1608039829572-78524f79c4c7?w=600&auto=format&fit=crop&q=80',
          addOns: [
            AddOn(id: 'ayl_add_01', name: 'Extra Hollandaise Pot', priceDelta: 120),
            AddOn(id: 'ayl_add_02', name: 'Add Avocado Slices', priceDelta: 180),
          ],
        ),
        const MenuItem(
          id: 'ayl_02',
          restaurantId: 'rest_01',
          name: 'Truffle Mushroom Risotto',
          description: 'Arborio rice slow-stirred with wild porcini mushrooms, white wine, aged Parmigiano Reggiano and finished with black truffle oil.',
          price: 1650,
          category: 'Pasta & Risotto',
          imageUrl: 'https://images.unsplash.com/photo-1476124369491-e7addf5db371?w=600&auto=format&fit=crop&q=80',
          addOns: [
            AddOn(id: 'ayl_add_03', name: 'Extra Truffle Shavings', priceDelta: 350),
            AddOn(id: 'ayl_add_04', name: 'Add Grilled Chicken', priceDelta: 290),
          ],
        ),
        const MenuItem(
          id: 'ayl_03',
          restaurantId: 'rest_01',
          name: 'Margherita & Basil Wood-Fired Pizza',
          description: 'San Marzano tomato base, hand-stretched dough blistered in a 400°C stone oven, fresh fior di latte mozzarella and Genovese basil.',
          price: 1450,
          category: 'Wood-Fired Pizza',
          imageUrl: 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=600&auto=format&fit=crop&q=80',
          addOns: [
            AddOn(id: 'ayl_add_05', name: 'Add Prosciutto', priceDelta: 320),
            AddOn(id: 'ayl_add_06', name: 'Extra Cheese', priceDelta: 150),
            AddOn(id: 'ayl_add_07', name: 'Truffle Base Upgrade', priceDelta: 200),
          ],
        ),
        const MenuItem(
          id: 'ayl_04',
          restaurantId: 'rest_01',
          name: 'Pan-Seared Chicken Supreme',
          description: 'Free-range chicken breast seared golden in herb butter, served over roasted garlic mash with seasonal vegetables and jus.',
          price: 1890,
          category: 'Mains',
          imageUrl: 'https://images.unsplash.com/photo-1432139509613-5c4255815697?w=600&auto=format&fit=crop&q=80',
          addOns: [
            AddOn(id: 'ayl_add_08', name: 'Peppercorn Sauce', priceDelta: 130),
            AddOn(id: 'ayl_add_09', name: 'Upgrade to Truffle Mash', priceDelta: 200),
          ],
        ),
        const MenuItem(
          id: 'ayl_05',
          restaurantId: 'rest_01',
          name: 'Warm Chocolate Fondant',
          description: 'Dark Valrhona chocolate cake with a molten liquid centre, served with Madagascar vanilla bean ice cream and raspberry coulis.',
          price: 820,
          category: 'Desserts',
          imageUrl: 'https://images.unsplash.com/photo-1624353365286-3f8d62daad51?w=600&auto=format&fit=crop&q=80',
          addOns: [
            AddOn(id: 'ayl_add_10', name: 'Extra Scoop Ice Cream', priceDelta: 180),
          ],
        ),
        const MenuItem(
          id: 'ayl_06',
          restaurantId: 'rest_01',
          name: 'Café Aylanto Cold Brew',
          description: 'Single-origin Colombian beans cold-steeped for 18 hours, served over ice with cream and your choice of flavour.',
          price: 490,
          category: 'Beverages',
          imageUrl: 'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=600&auto=format&fit=crop&q=80',
          addOns: [
            AddOn(id: 'ayl_add_11', name: 'Vanilla Syrup', priceDelta: 60),
            AddOn(id: 'ayl_add_12', name: 'Oat Milk Upgrade', priceDelta: 80),
          ],
        ),
      ],
      reviews: [
        Review(
          id: 'rev_ayl_01',
          authorName: 'Sana Mirza',
          rating: 5.0,
          comment: 'The Eggs Benedict is absolutely perfect. Hollandaise is silky and the salmon is top quality. Best brunch in Karachi!',
          date: DateTime.now().subtract(const Duration(days: 1)),
        ),
        Review(
          id: 'rev_ayl_02',
          authorName: 'Hamza Qureshi',
          rating: 4.8,
          comment: 'Truffle risotto was restaurant-quality delivered to my door. Genuinely impressed.',
          date: DateTime.now().subtract(const Duration(days: 5)),
        ),
      ],
    ),

    // ─── 2. FUCHSIA KARACHI ───────────────────────────────────────────────────
    Restaurant(
      id: 'rest_02',
      name: 'Fuchsia Karachi',
      tagline: 'Elevated pan-Asian flavours, fresh dim sum & artisan noodles',
      cuisine: 'Pan-Asian & Dim Sum',
      rating: 4.9,
      reviewCount: 87,
      estimatedTime: '25–40 min',
      deliveryFee: 129,
      minOrder: 900,
      isOpen: true,
      openingHours: '12:00 PM – 11:00 PM',
      imageUrl: 'https://images.unsplash.com/photo-1617196034183-421b4040ed20?w=800&auto=format&fit=crop&q=80',
      crescentColorValue: 0xFFB5004E,
      address: 'Khayaban-e-Ittehad, DHA Phase VI, Karachi',
      categories: ['Dim Sum', 'Noodles & Rice', 'Wok Mains', 'Sushi & Rolls', 'Soups', 'Bubble Tea'],
      menuItems: [
        const MenuItem(
          id: 'fuc_01',
          restaurantId: 'rest_02',
          name: 'Steamed Har Gow Prawn Dumplings',
          description: 'Delicate translucent rice-starch wrappers filled with whole tiger prawns, bamboo shoots and sesame, steamed to silky perfection. Basket of 4.',
          price: 950,
          category: 'Dim Sum',
          imageUrl: 'https://images.unsplash.com/photo-1496116218417-1a781b1c416c?w=600&auto=format&fit=crop&q=80',
          addOns: [
            AddOn(id: 'fuc_add_01', name: 'Chilli Garlic Dipping Sauce', priceDelta: 80),
            AddOn(id: 'fuc_add_02', name: 'Extra Basket (4 pcs)', priceDelta: 950),
          ],
        ),
        const MenuItem(
          id: 'fuc_02',
          restaurantId: 'rest_02',
          name: 'Crispy Peking Duck Spring Rolls',
          description: 'Slow-roasted Peking duck shredded with hoisin, spring onions and cucumber, tightly rolled and fried to a shattering golden crisp.',
          price: 1100,
          category: 'Dim Sum',
          imageUrl: 'https://images.unsplash.com/photo-1612929633738-8fe44f7ec841?w=600&auto=format&fit=crop&q=80',
          addOns: [
            AddOn(id: 'fuc_add_03', name: 'Extra Hoisin Dip', priceDelta: 90),
          ],
        ),
        const MenuItem(
          id: 'fuc_03',
          restaurantId: 'rest_02',
          name: 'Fuchsia Signature Beef Ramen',
          description: 'Rich 12-hour tonkotsu-miso broth, hand-pulled noodles, wagyu beef slices, marinated soft egg, nori and togarashi butter.',
          price: 1850,
          category: 'Noodles & Rice',
          imageUrl: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=600&auto=format&fit=crop&q=80',
          addOns: [
            AddOn(id: 'fuc_add_04', name: 'Extra Wagyu Slices', priceDelta: 490),
            AddOn(id: 'fuc_add_05', name: 'Add Marinated Egg', priceDelta: 120),
            AddOn(id: 'fuc_add_06', name: 'Spicy Miso Upgrade', priceDelta: 100),
          ],
        ),
        const MenuItem(
          id: 'fuc_04',
          restaurantId: 'rest_02',
          name: 'Wok-Charred Mongolian Chicken',
          description: 'Tender chicken thigh strips tossed in a wok over high flame with Mongolian black bean sauce, spring onions and chillies.',
          price: 1390,
          category: 'Wok Mains',
          imageUrl: 'https://images.unsplash.com/photo-1604909052743-94e838986d24?w=600&auto=format&fit=crop&q=80',
          addOns: [
            AddOn(id: 'fuc_add_07', name: 'Add Steamed Rice', priceDelta: 180),
            AddOn(id: 'fuc_add_08', name: 'Extra Sauce Pot', priceDelta: 110),
          ],
        ),
        const MenuItem(
          id: 'fuc_05',
          restaurantId: 'rest_02',
          name: 'Taro & Coconut Bubble Tea',
          description: 'Freshly brewed oolong tea blended with creamy taro and coconut milk, topped with hand-made tapioca pearls.',
          price: 620,
          category: 'Bubble Tea',
          imageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600&auto=format&fit=crop&q=80',
          addOns: [
            AddOn(id: 'fuc_add_09', name: 'Extra Tapioca Pearls', priceDelta: 80),
            AddOn(id: 'fuc_add_10', name: 'Less Sugar', priceDelta: 0),
          ],
        ),
      ],
      reviews: [
        Review(
          id: 'rev_fuc_01',
          authorName: 'Ayesha Tariq',
          rating: 5.0,
          comment: 'The beef ramen is life-changing. Broth is deep and complex — you can tell it simmered for hours. Fuchsia never misses.',
          date: DateTime.now().subtract(const Duration(days: 2)),
        ),
        Review(
          id: 'rev_fuc_02',
          authorName: 'Bilal Rehman',
          rating: 4.9,
          comment: 'Har Gow was absolutely authentic. The wrappers are thin and the prawn filling is generous. Obsessed.',
          date: DateTime.now().subtract(const Duration(days: 7)),
        ),
      ],
    ),

    // ─── 3. FINE FOODS CO. ────────────────────────────────────────────────────
    Restaurant(
      id: 'rest_03',
      name: 'Fine Foods Co.',
      tagline: 'Gourmet deli, artisan sandwiches & premium platters',
      cuisine: 'Deli & Gourmet',
      rating: 4.7,
      reviewCount: 63,
      estimatedTime: '20–35 min',
      deliveryFee: 99,
      minOrder: 600,
      isOpen: true,
      openingHours: '8:00 AM – 10:00 PM',
      imageUrl: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800&auto=format&fit=crop&q=80',
      crescentColorValue: 0xFF4A7C59,
      address: 'Zamzama Boulevard, DHA Phase V, Karachi',
      categories: ['Artisan Sandwiches', 'Salads & Bowls', 'Charcuterie', 'Pastries', 'Speciality Coffee'],
      menuItems: [
        const MenuItem(
          id: 'ff_01',
          restaurantId: 'rest_03',
          name: 'Prosciutto & Burrata Sourdough',
          description: 'Hand-sliced 18-month prosciutto di Parma, fresh burrata, sun-blushed tomatoes and pesto aioli on charcoal-grilled country sourdough.',
          price: 1250,
          category: 'Artisan Sandwiches',
          imageUrl: 'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?w=600&auto=format&fit=crop&q=80',
          addOns: [
            AddOn(id: 'ff_add_01', name: 'Extra Burrata', priceDelta: 250),
            AddOn(id: 'ff_add_02', name: 'Add Arugula', priceDelta: 80),
          ],
        ),
        const MenuItem(
          id: 'ff_02',
          restaurantId: 'rest_03',
          name: 'Smoked Turkey & Avocado Club',
          description: 'Thickly sliced hickory-smoked turkey, ripe Hass avocado, crispy streaky bacon, vine tomato and wholegrain mustard mayo on toasted brioche.',
          price: 1100,
          category: 'Artisan Sandwiches',
          imageUrl: 'https://images.unsplash.com/photo-1553909489-cd47e0907980?w=600&auto=format&fit=crop&q=80',
          addOns: [
            AddOn(id: 'ff_add_03', name: 'Add Fried Egg', priceDelta: 120),
            AddOn(id: 'ff_add_04', name: 'Extra Bacon Rashers', priceDelta: 160),
          ],
        ),
        const MenuItem(
          id: 'ff_03',
          restaurantId: 'rest_03',
          name: 'Mediterranean Mezze Grain Bowl',
          description: 'Warm farro, roasted red peppers, Castelvetrano olives, feta, cucumber, cherry tomatoes, topped with lemon-tahini dressing and za\'atar.',
          price: 980,
          category: 'Salads & Bowls',
          imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=600&auto=format&fit=crop&q=80',
          addOns: [
            AddOn(id: 'ff_add_05', name: 'Add Grilled Halloumi', priceDelta: 220),
            AddOn(id: 'ff_add_06', name: 'Extra Tahini Dressing', priceDelta: 80),
          ],
        ),
        const MenuItem(
          id: 'ff_04',
          restaurantId: 'rest_03',
          name: 'Fine Foods Charcuterie Board',
          description: 'Curated imported cured meats, aged cheeses, honey, fig jam, cornichons, candied walnuts and artisan crackers. Serves 2.',
          price: 2800,
          category: 'Charcuterie',
          imageUrl: 'https://images.unsplash.com/photo-1542345812-d98b5cd6cf98?w=600&auto=format&fit=crop&q=80',
          addOns: [
            AddOn(id: 'ff_add_07', name: 'Add Imported Manchego', priceDelta: 450),
            AddOn(id: 'ff_add_08', name: 'Add Sourdough Crostini', priceDelta: 180),
          ],
        ),
        const MenuItem(
          id: 'ff_05',
          restaurantId: 'rest_03',
          name: 'Almond Croissant',
          description: 'Classic butter croissant twice-baked with almond frangipane cream, topped with toasted flaked almonds and dusted with icing sugar.',
          price: 420,
          category: 'Pastries',
          imageUrl: 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=600&auto=format&fit=crop&q=80',
          addOns: [
            AddOn(id: 'ff_add_09', name: 'Pair with Latte', priceDelta: 380),
          ],
        ),
        const MenuItem(
          id: 'ff_06',
          restaurantId: 'rest_03',
          name: 'Single-Origin Flat White',
          description: 'Ethiopia Yirgacheffe beans pulled as a tight ristretto, topped with velvety microfoam steamed to 65°C.',
          price: 480,
          category: 'Speciality Coffee',
          imageUrl: 'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=600&auto=format&fit=crop&q=80',
          addOns: [
            AddOn(id: 'ff_add_10', name: 'Oat Milk', priceDelta: 80),
            AddOn(id: 'ff_add_11', name: 'Extra Shot', priceDelta: 90),
          ],
        ),
      ],
      reviews: [
        Review(
          id: 'rev_ff_01',
          authorName: 'Zara Ahmed',
          rating: 4.8,
          comment: 'The prosciutto sandwich is genuinely one of the best things I\'ve eaten in Karachi. The burrata is incredibly fresh.',
          date: DateTime.now().subtract(const Duration(days: 3)),
        ),
        Review(
          id: 'rev_ff_02',
          authorName: 'Omar Shaikh',
          rating: 4.6,
          comment: 'Charcuterie board is perfect for gatherings. Great quality cured meats and the fig jam is a brilliant touch.',
          date: DateTime.now().subtract(const Duration(days: 9)),
        ),
      ],
    ),

    // ─── 4. THE MAD ITALIAN ───────────────────────────────────────────────────
    Restaurant(
      id: 'rest_04',
      name: 'The Mad Italian',
      tagline: 'Authentic Neapolitan pizzas, handmade pasta & Italian soul food',
      cuisine: 'Italian',
      rating: 4.8,
      reviewCount: 95,
      estimatedTime: '35–50 min',
      deliveryFee: 149,
      minOrder: 700,
      isOpen: true,
      openingHours: '1:00 PM – 11:30 PM',
      imageUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800&auto=format&fit=crop&q=80',
      crescentColorValue: 0xFFB03A2E,
      address: 'Sehar Commercial, DHA Phase VII, Karachi',
      categories: ['Neapolitan Pizzas', 'Handmade Pasta', 'Antipasti', 'Mains', 'Dolci', 'Italian Drinks'],
      menuItems: [
        const MenuItem(
          id: 'mi_01',
          restaurantId: 'rest_04',
          name: 'Diavola — Spicy Nduja & Honey',
          description: 'San Marzano base, spicy Calabrian nduja sausage, fior di latte, fresh chilli, drizzled with wildflower honey and finished with basil oil.',
          price: 1650,
          category: 'Neapolitan Pizzas',
          imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=600&auto=format&fit=crop&q=80',
          addOns: [
            AddOn(id: 'mi_add_01', name: 'Extra Nduja', priceDelta: 250),
            AddOn(id: 'mi_add_02', name: 'Add Burrata', priceDelta: 320),
            AddOn(id: 'mi_add_03', name: 'Truffle Oil Drizzle', priceDelta: 200),
          ],
        ),
        const MenuItem(
          id: 'mi_02',
          restaurantId: 'rest_04',
          name: 'Cacio e Pepe',
          description: 'Rome\'s most iconic pasta — hand-rolled tonnarelli, aged Pecorino Romano, Parmigiano Reggiano and generous cracked black pepper. Nothing else.',
          price: 1380,
          category: 'Handmade Pasta',
          imageUrl: 'https://images.unsplash.com/photo-1612929633738-8fe44f7ec841?w=600&auto=format&fit=crop&q=80',
          addOns: [
            AddOn(id: 'mi_add_04', name: 'Extra Pecorino Romano', priceDelta: 180),
            AddOn(id: 'mi_add_05', name: 'Add Crispy Guanciale', priceDelta: 290),
          ],
        ),
        const MenuItem(
          id: 'mi_03',
          restaurantId: 'rest_04',
          name: 'Oxtail Ragu Pappardelle',
          description: 'Wide ribbon egg pasta draped in a slow-braised Roman oxtail ragu, cooked for 6 hours with red wine, celery, carrot and a hint of dark chocolate.',
          price: 1850,
          category: 'Handmade Pasta',
          imageUrl: 'https://images.unsplash.com/photo-1621996346565-e3d5d628109a?w=600&auto=format&fit=crop&q=80',
          addOns: [
            AddOn(id: 'mi_add_06', name: 'Extra Pappardelle Portion', priceDelta: 280),
            AddOn(id: 'mi_add_07', name: 'Shaved Black Truffle', priceDelta: 550),
          ],
        ),
        const MenuItem(
          id: 'mi_04',
          restaurantId: 'rest_04',
          name: 'Burrata con Pomodoro',
          description: 'Imported Italian burrata on a bed of slow-roasted heirloom tomatoes, Sicilian capers, fresh basil and cold-pressed Taggiasca olive oil.',
          price: 1290,
          category: 'Antipasti',
          imageUrl: 'https://images.unsplash.com/photo-1608897013039-887f21d8c804?w=600&auto=format&fit=crop&q=80',
          addOns: [
            AddOn(id: 'mi_add_08', name: 'Grilled Focaccia', priceDelta: 180),
            AddOn(id: 'mi_add_09', name: 'Extra Burrata Ball', priceDelta: 390),
          ],
        ),
        const MenuItem(
          id: 'mi_05',
          restaurantId: 'rest_04',
          name: 'Classic Tiramisu',
          description: 'Savoiardi ladyfingers soaked in strong espresso, layered with whipped mascarpone cream and dusted generously with Valrhona cocoa powder.',
          price: 790,
          category: 'Dolci',
          imageUrl: 'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?w=600&auto=format&fit=crop&q=80',
          addOns: [
            AddOn(id: 'mi_add_10', name: 'Extra Espresso Soak', priceDelta: 80),
          ],
        ),
        const MenuItem(
          id: 'mi_06',
          restaurantId: 'rest_04',
          name: 'San Pellegrino Limonata',
          description: 'Sparkling Sicilian lemon soda from Italy — brilliantly tart, lightly sweet and perfectly carbonated. Served over ice.',
          price: 380,
          category: 'Italian Drinks',
          imageUrl: 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=600&auto=format&fit=crop&q=80',
          addOns: [
            AddOn(id: 'mi_add_11', name: 'Add Fresh Mint', priceDelta: 40),
          ],
        ),
      ],
      reviews: [
        Review(
          id: 'rev_mi_01',
          authorName: 'Nida Farooq',
          rating: 5.0,
          comment: 'Cacio e Pepe was PERFECT. No cream, no shortcuts — just real technique. Best Italian in the city by a mile.',
          date: DateTime.now().subtract(const Duration(days: 2)),
        ),
        Review(
          id: 'rev_mi_02',
          authorName: 'Ali Hassan',
          rating: 4.8,
          comment: 'The Diavola pizza with honey is a revelation. Spicy, sweet, smoky — arrived hot with a perfectly leopard-spotted crust.',
          date: DateTime.now().subtract(const Duration(days: 6)),
        ),
      ],
    ),
  ];

  @override
  Future<List<Restaurant>> getRestaurants({String? query, String? cuisine}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    var results = List<Restaurant>.from(_restaurants);

    if (cuisine != null && cuisine != 'All') {
      results = results.where((r) => r.cuisine.toLowerCase().contains(cuisine.toLowerCase())).toList();
    }

    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      results = results.where((r) =>
        r.name.toLowerCase().contains(q) ||
        r.cuisine.toLowerCase().contains(q) ||
        r.tagline.toLowerCase().contains(q) ||
        r.menuItems.any((m) => m.name.toLowerCase().contains(q))
      ).toList();
    }

    return results;
  }

  @override
  Future<Restaurant?> getRestaurantById(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    try {
      return _restaurants.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> submitReview(String restaurantId, Review review) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _restaurants.indexWhere((r) => r.id == restaurantId);
    if (index != -1) {
      final existing = _restaurants[index];
      final updatedReviews = [review, ...existing.reviews];
      _restaurants[index] = existing.copyWith(reviews: updatedReviews);
    }
  }
}
