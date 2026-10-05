import 'package:flutter_test/flutter_test.dart';
import 'package:customer_app/models/cart_item.dart';
import 'package:customer_app/models/menu_item.dart';
import 'package:customer_app/models/order.dart';
import 'package:customer_app/models/restaurant.dart';
import 'package:customer_app/providers/cart_provider.dart';
import 'package:customer_app/services/order_repository.dart';
import 'package:customer_app/services/restaurant_repository.dart';

void main() {
  group('Master Prompt Hard Constraints Verification', () {
    late CartProvider cart;
    late MockRestaurantRepository restaurantRepo;
    late MockOrderRepository orderRepo;

    setUp(() {
      cart = CartProvider();
      restaurantRepo = MockRestaurantRepository();
      orderRepo = MockOrderRepository();
    });

    test('Rule 1: Single-restaurant cart rule enforcement', () async {
      final restaurants = await restaurantRepo.getRestaurants();
      final restA = restaurants[0]; // Ottawa Kabab
      final restB = restaurants[1]; // Sashimi Atelier

      // Add item from Restaurant A
      cart.addItem(
        restaurant: restA,
        menuItem: restA.menuItems[0],
      );

      expect(cart.restaurantId, equals(restA.id));
      expect(cart.itemCount, equals(1));

      // Attempting to add from Restaurant B should trigger conflict
      expect(cart.canAddDirectly(restB.id), isFalse);

      // Attempting to add from Restaurant A should succeed directly
      expect(cart.canAddDirectly(restA.id), isTrue);

      // Explicit clear & switch
      cart.clearAndAddNew(
        restaurant: restB,
        menuItem: restB.menuItems[0],
      );

      expect(cart.restaurantId, equals(restB.id));
      expect(cart.itemCount, equals(1));
      expect(cart.items.first.menuItem.id, equals(restB.menuItems[0].id));
    });

    test('Rule 2: Order cancellation is permitted ONLY in Received or Accepted status', () {
      expect(OrderStatus.received.isCancellable, isTrue);
      expect(OrderStatus.accepted.isCancellable, isTrue);
      expect(OrderStatus.preparing.isCancellable, isFalse);
      expect(OrderStatus.outForDelivery.isCancellable, isFalse);
      expect(OrderStatus.delivered.isCancellable, isFalse);
      expect(OrderStatus.cancelled.isCancellable, isFalse);
    });

    test('Rule 3: Order cancellation execution fails on Preparing orders', () async {
      final orders = await orderRepo.getOrders();
      final preparingOrder = orders.firstWhere((o) => o.status == OrderStatus.preparing);
      final receivedOrder = orders.firstWhere((o) => o.status == OrderStatus.received);

      // Attempt cancel on preparing order -> MUST FAIL
      final cancelPreparingResult = await orderRepo.cancelOrder(preparingOrder.id);
      expect(cancelPreparingResult, isFalse);

      // Attempt cancel on received order -> MUST SUCCEED
      final cancelReceivedResult = await orderRepo.cancelOrder(receivedOrder.id);
      expect(cancelReceivedResult, isTrue);
    });

    test('Rule 4: Closed restaurant state is mocked and ordering disabled', () async {
      final restaurants = await restaurantRepo.getRestaurants();
      final closedRest = restaurants.firstWhere((r) => !r.isOpen);

      expect(closedRest.isOpen, isFalse);
      expect(closedRest.name, equals('Harissa Sweets & Pastries'));
      expect(closedRest.menuItems.every((item) => !item.isAvailable), isTrue);
    });

    test('Rule 5: Cash on Delivery is the designated payment method', () async {
      final orders = await orderRepo.getOrders();
      for (final order in orders) {
        expect(order.paymentMethod, equals('Cash on Delivery'));
      }
    });

    test('Rule 6: Reviews are tied only to Delivered orders', () async {
      final orders = await orderRepo.getOrders();
      final unreviewedDelivered = orders.firstWhere(
        (o) => o.status == OrderStatus.delivered && !o.isReviewed,
      );

      expect(unreviewedDelivered.status, equals(OrderStatus.delivered));
      expect(unreviewedDelivered.isReviewed, isFalse);

      // Submit review
      final reviewSuccess = await orderRepo.submitReview(
        unreviewedDelivered.id,
        5.0,
        'Amazing taste and quality!',
      );
      expect(reviewSuccess, isTrue);

      final updatedOrder = await orderRepo.getOrderById(unreviewedDelivered.id);
      expect(updatedOrder!.isReviewed, isTrue);
    });
  });
}
