import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/menu_item.dart';
import '../models/restaurant.dart';

class CartProvider with ChangeNotifier {
  String? _restaurantId;
  String? _restaurantName;
  String? _restaurantImage;
  double _deliveryFee = 0.0;

  final List<CartItem> _items = [];

  String? get restaurantId => _restaurantId;
  String? get restaurantName => _restaurantName;
  String? get restaurantImage => _restaurantImage;
  double get deliveryFee => _deliveryFee;
  List<CartItem> get items => List.unmodifiable(_items);

  bool get isEmpty => _items.isEmpty;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  double get total => subtotal + (isEmpty ? 0.0 : _deliveryFee);

  /// Check whether an item from the given restaurant can be added directly
  /// or if there is a restaurant conflict.
  bool canAddDirectly(String newRestaurantId) {
    if (_items.isEmpty || _restaurantId == null) {
      return true;
    }
    return _restaurantId == newRestaurantId;
  }

  /// Adds an item assuming no restaurant conflict exists
  void addItem({
    required Restaurant restaurant,
    required MenuItem menuItem,
    List<AddOn> selectedAddOns = const [],
    int quantity = 1,
    String? instructions,
  }) {
    if (_items.isEmpty) {
      _restaurantId = restaurant.id;
      _restaurantName = restaurant.name;
      _restaurantImage = restaurant.imageUrl;
      _deliveryFee = restaurant.deliveryFee;
    }

    // Check if identical item + addons already exists in cart
    final existingIndex = _items.indexWhere((item) {
      if (item.menuItem.id != menuItem.id) return false;
      if (item.selectedAddOns.length != selectedAddOns.length) return false;
      final currentAddOnIds = item.selectedAddOns.map((a) => a.id).toSet();
      final newAddOnIds = selectedAddOns.map((a) => a.id).toSet();
      return currentAddOnIds.containsAll(newAddOnIds);
    });

    if (existingIndex != -1) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(CartItem(
        id: 'cart_${DateTime.now().millisecondsSinceEpoch}',
        menuItem: menuItem,
        selectedAddOns: selectedAddOns,
        quantity: quantity,
        instructions: instructions,
      ));
    }
    notifyListeners();
  }

  /// Clears current cart and starts a new order with the item from the new restaurant
  void clearAndAddNew({
    required Restaurant restaurant,
    required MenuItem menuItem,
    List<AddOn> selectedAddOns = const [],
    int quantity = 1,
    String? instructions,
  }) {
    _items.clear();
    _restaurantId = restaurant.id;
    _restaurantName = restaurant.name;
    _restaurantImage = restaurant.imageUrl;
    _deliveryFee = restaurant.deliveryFee;

    _items.add(CartItem(
      id: 'cart_${DateTime.now().millisecondsSinceEpoch}',
      menuItem: menuItem,
      selectedAddOns: selectedAddOns,
      quantity: quantity,
      instructions: instructions,
    ));
    notifyListeners();
  }

  void updateQuantity(String cartItemId, int newQuantity) {
    final index = _items.indexWhere((i) => i.id == cartItemId);
    if (index != -1) {
      if (newQuantity <= 0) {
        _items.removeAt(index);
        if (_items.isEmpty) {
          _restaurantId = null;
          _restaurantName = null;
          _restaurantImage = null;
          _deliveryFee = 0.0;
        }
      } else {
        _items[index].quantity = newQuantity;
      }
      notifyListeners();
    }
  }

  void removeItem(String cartItemId) {
    _items.removeWhere((i) => i.id == cartItemId);
    if (_items.isEmpty) {
      _restaurantId = null;
      _restaurantName = null;
      _restaurantImage = null;
      _deliveryFee = 0.0;
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _restaurantId = null;
    _restaurantName = null;
    _restaurantImage = null;
    _deliveryFee = 0.0;
    notifyListeners();
  }
}
