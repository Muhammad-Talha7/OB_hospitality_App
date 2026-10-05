class AddOn {
  final String id;
  final String name;
  final double priceDelta;

  const AddOn({
    required this.id,
    required this.name,
    required this.priceDelta,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'priceDelta': priceDelta,
  };

  factory AddOn.fromJson(Map<String, dynamic> json) => AddOn(
    id: json['id'] as String,
    name: json['name'] as String,
    priceDelta: (json['priceDelta'] as num).toDouble(),
  );
}

class MenuItem {
  final String id;
  final String restaurantId;
  final String name;
  final String description;
  final double price;
  final String category;
  final String imageUrl;
  final List<AddOn> addOns;
  final bool isAvailable;

  const MenuItem({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    this.addOns = const [],
    this.isAvailable = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'restaurantId': restaurantId,
    'name': name,
    'description': description,
    'price': price,
    'category': category,
    'imageUrl': imageUrl,
    'addOns': addOns.map((a) => a.toJson()).toList(),
    'isAvailable': isAvailable,
  };

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
    id: json['id'] as String,
    restaurantId: json['restaurantId'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    price: (json['price'] as num).toDouble(),
    category: json['category'] as String,
    imageUrl: json['imageUrl'] as String,
    addOns: (json['addOns'] as List<dynamic>?)
            ?.map((a) => AddOn.fromJson(a as Map<String, dynamic>))
            .toList() ??
        const [],
    isAvailable: json['isAvailable'] as bool? ?? true,
  );
}
