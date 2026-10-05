import 'dart:async';
import '../models/order.dart';
import '../models/cart_item.dart';
import '../models/menu_item.dart';

abstract class OrderRepository {
  Future<List<OrderModel>> getOrders();
  Future<OrderModel?> getOrderById(String id);
  Future<OrderModel> placeOrder(OrderModel order);
  Future<bool> cancelOrder(String orderId);
  Future<bool> submitComplaint(String orderId, String reason, String description);
  Future<bool> submitReview(String orderId, double rating, String comment);
}

class MockOrderRepository implements OrderRepository {
  final List<OrderModel> _orders = [
    // 1. Received Order (Active, Cancellable)
    OrderModel(
      id: 'ORD-9821',
      restaurantId: 'rest_01',
      restaurantName: 'Ottawa Kabab & Grill',
      restaurantImage: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800&auto=format&fit=crop&q=80',
      items: [
        CartItem(
          id: 'ci_01',
          menuItem: const MenuItem(
            id: 'item_01',
            restaurantId: 'rest_01',
            name: 'Adana Kabab, Lamb and Beef',
            description: 'Hand-minced skewers with Aleppo peppers',
            price: 24.00,
            category: 'Kebab Plates',
            imageUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?w=600&auto=format&fit=crop&q=80',
          ),
          selectedAddOns: [
            const AddOn(id: 'add_01', name: 'Extra Garlic Toum Sauce', priceDelta: 1.50),
          ],
          quantity: 2,
        ),
      ],
      subtotal: 51.00,
      deliveryFee: 3.50,
      total: 54.50,
      fulfilmentType: FulfilmentType.delivery,
      paymentMethod: 'Cash on Delivery',
      status: OrderStatus.received, // Explicitly tests Received state (Cancellable)
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      deliveryAddress: '104 Bank St, Apt 4B, Ottawa, ON',
    ),

    // 2. Preparing Order (Active, NOT cancellable!)
    OrderModel(
      id: 'ORD-9784',
      restaurantId: 'rest_02',
      restaurantName: 'Sashimi & Poke Atelier',
      restaurantImage: 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=800&auto=format&fit=crop&q=80',
      items: [
        CartItem(
          id: 'ci_02',
          menuItem: const MenuItem(
            id: 'item_06',
            restaurantId: 'rest_02',
            name: 'Chef’s Pacific Poke Harvest Bowl',
            description: 'Sashimi salmon & tuna over sushi rice',
            price: 23.50,
            category: 'Signature Bowls',
            imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&auto=format&fit=crop&q=80',
          ),
          selectedAddOns: [
            const AddOn(id: 'add_13', name: 'Spicy Truffle Mayo', priceDelta: 1.50),
          ],
          quantity: 1,
        ),
      ],
      subtotal: 25.00,
      deliveryFee: 2.99,
      total: 27.99,
      fulfilmentType: FulfilmentType.delivery,
      paymentMethod: 'Cash on Delivery',
      status: OrderStatus.preparing, // Explicitly tests Preparing state (Cancel button MUST be hidden)
      createdAt: DateTime.now().subtract(const Duration(minutes: 22)),
      deliveryAddress: '104 Bank St, Apt 4B, Ottawa, ON',
    ),

    // 3. Delivered Order (Unreviewed — MUST show "Leave a review" button)
    OrderModel(
      id: 'ORD-9512',
      restaurantId: 'rest_03',
      restaurantName: 'La Trattoria Artisan Pasta',
      restaurantImage: 'https://images.unsplash.com/photo-1551183053-bf91a1d81141?w=800&auto=format&fit=crop&q=80',
      items: [
        CartItem(
          id: 'ci_03',
          menuItem: const MenuItem(
            id: 'item_09',
            restaurantId: 'rest_03',
            name: 'Wok-Tossed Chicken & Herb Linguine',
            description: 'Egg linguine with chicken & mushrooms',
            price: 22.00,
            category: 'Fresh Pasta',
            imageUrl: 'https://images.unsplash.com/photo-1621996346565-e3d5d628109a?w=600&auto=format&fit=crop&q=80',
          ),
          quantity: 1,
        ),
      ],
      subtotal: 22.00,
      deliveryFee: 3.25,
      total: 25.25,
      fulfilmentType: FulfilmentType.delivery,
      paymentMethod: 'Cash on Delivery',
      status: OrderStatus.delivered,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      deliveryAddress: '104 Bank St, Apt 4B, Ottawa, ON',
      isReviewed: false, // Explicitly unreviewed
    ),

    // 4. Delivered Order (Already Reviewed — MUST NOT show review button)
    OrderModel(
      id: 'ORD-9304',
      restaurantId: 'rest_01',
      restaurantName: 'Ottawa Kabab & Grill',
      restaurantImage: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800&auto=format&fit=crop&q=80',
      items: [
        CartItem(
          id: 'ci_04',
          menuItem: const MenuItem(
            id: 'item_02',
            restaurantId: 'rest_01',
            name: 'Mandi With Lamb Shank Delimia',
            description: 'Slow-braised lamb shank with spiced rice',
            price: 32.00,
            category: 'Lamb Specials',
            imageUrl: 'https://images.unsplash.com/photo-1514944298352-f472288dc18a?w=600&auto=format&fit=crop&q=80',
          ),
          quantity: 1,
        ),
      ],
      subtotal: 32.00,
      deliveryFee: 0.0,
      total: 32.00,
      fulfilmentType: FulfilmentType.pickup,
      paymentMethod: 'Cash on Delivery',
      status: OrderStatus.delivered,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      isReviewed: true, // Explicitly reviewed
    ),

    // 5. Cancelled Order (Terminal State — Never show review button)
    OrderModel(
      id: 'ORD-9110',
      restaurantId: 'rest_02',
      restaurantName: 'Sashimi & Poke Atelier',
      restaurantImage: 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=800&auto=format&fit=crop&q=80',
      items: [
        CartItem(
          id: 'ci_05',
          menuItem: const MenuItem(
            id: 'item_07',
            restaurantId: 'rest_02',
            name: 'Artisan Bluefin & Citrus Sashimi',
            description: 'Sliced sashimi with yuzu ponzu sauce',
            price: 29.00,
            category: 'Sashimi Platters',
            imageUrl: 'https://images.unsplash.com/photo-1617196034796-73dfa7b1fd56?w=600&auto=format&fit=crop&q=80',
          ),
          quantity: 1,
        ),
      ],
      subtotal: 29.00,
      deliveryFee: 2.99,
      total: 31.99,
      fulfilmentType: FulfilmentType.delivery,
      paymentMethod: 'Cash on Delivery',
      status: OrderStatus.cancelled, // Explicitly cancelled terminal state
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      deliveryAddress: '104 Bank St, Apt 4B, Ottawa, ON',
      isReviewed: false,
    ),
  ];

  @override
  Future<List<OrderModel>> getOrders() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return List<OrderModel>.from(_orders);
  }

  @override
  Future<OrderModel?> getOrderById(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<OrderModel> placeOrder(OrderModel order) async {
    await Future.delayed(const Duration(milliseconds: 350));
    _orders.insert(0, order);
    return order;
  }

  @override
  Future<bool> cancelOrder(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final existing = _orders[index];
      // Rule: cancel allowed only if Received or Accepted
      if (existing.status.isCancellable) {
        _orders[index] = existing.copyWith(status: OrderStatus.cancelled);
        return true;
      }
    }
    return false;
  }

  @override
  Future<bool> submitComplaint(String orderId, String reason, String description) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final complaint = Complaint(
        id: 'comp_${DateTime.now().millisecondsSinceEpoch}',
        orderId: orderId,
        reason: reason,
        description: description,
        createdAt: DateTime.now(),
      );
      _orders[index] = _orders[index].copyWith(complaint: complaint);
      return true;
    }
    return false;
  }

  @override
  Future<bool> submitReview(String orderId, double rating, String comment) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(isReviewed: true);
      return true;
    }
    return false;
  }
}
