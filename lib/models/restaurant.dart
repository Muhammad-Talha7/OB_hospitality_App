import 'menu_item.dart';
import 'review.dart';

class Restaurant {
  final String id;
  final String name;
  final String tagline;
  final String cuisine;
  final double rating;
  final int reviewCount;
  final String estimatedTime;
  final double deliveryFee;
  final double minOrder;
  final bool isOpen;
  final String openingHours;
  final String imageUrl;
  final int crescentColorValue;
  final String address;
  final List<String> categories;
  final List<MenuItem> menuItems;
  final List<Review> reviews;

  const Restaurant({
    required this.id,
    required this.name,
    required this.tagline,
    required this.cuisine,
    required this.rating,
    required this.reviewCount,
    required this.estimatedTime,
    required this.deliveryFee,
    required this.minOrder,
    required this.isOpen,
    required this.openingHours,
    required this.imageUrl,
    required this.crescentColorValue,
    required this.address,
    required this.categories,
    required this.menuItems,
    required this.reviews,
  });

  Restaurant copyWith({
    List<Review>? reviews,
  }) {
    return Restaurant(
      id: id,
      name: name,
      tagline: tagline,
      cuisine: cuisine,
      rating: rating,
      reviewCount: reviews != null ? reviews.length : reviewCount,
      estimatedTime: estimatedTime,
      deliveryFee: deliveryFee,
      minOrder: minOrder,
      isOpen: isOpen,
      openingHours: openingHours,
      imageUrl: imageUrl,
      crescentColorValue: crescentColorValue,
      address: address,
      categories: categories,
      menuItems: menuItems,
      reviews: reviews ?? this.reviews,
    );
  }
}
