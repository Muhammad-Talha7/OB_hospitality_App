import 'menu_item.dart';

class CartItem {
  final String id;
  final MenuItem menuItem;
  final List<AddOn> selectedAddOns;
  int quantity;
  final String? instructions;

  CartItem({
    required this.id,
    required this.menuItem,
    this.selectedAddOns = const [],
    this.quantity = 1,
    this.instructions,
  });

  double get unitPrice {
    double total = menuItem.price;
    for (final addon in selectedAddOns) {
      total += addon.priceDelta;
    }
    return total;
  }

  double get totalPrice => unitPrice * quantity;

  CartItem copyWith({
    int? quantity,
    String? instructions,
  }) {
    return CartItem(
      id: id,
      menuItem: menuItem,
      selectedAddOns: selectedAddOns,
      quantity: quantity ?? this.quantity,
      instructions: instructions ?? this.instructions,
    );
  }
}
