import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../services/order_repository.dart';

class OrderProvider with ChangeNotifier {
  final OrderRepository _orderRepository;

  List<OrderModel> _orders = [];
  bool _isLoading = false;

  OrderProvider(this._orderRepository) {
    loadOrders();
  }

  List<OrderModel> get orders => List.unmodifiable(_orders);
  bool get isLoading => _isLoading;

  List<OrderModel> get activeOrders =>
      _orders.where((o) => !o.status.isTerminal).toList();

  List<OrderModel> get pastOrders =>
      _orders.where((o) => o.status.isTerminal).toList();

  Future<void> loadOrders() async {
    _isLoading = true;
    notifyListeners();
    _orders = await _orderRepository.getOrders();
    _isLoading = false;
    notifyListeners();
  }

  Future<OrderModel> createOrder(OrderModel newOrder) async {
    _isLoading = true;
    notifyListeners();
    final created = await _orderRepository.placeOrder(newOrder);
    _orders.insert(0, created);
    _isLoading = false;
    notifyListeners();
    return created;
  }

  Future<bool> cancelOrder(String orderId) async {
    final success = await _orderRepository.cancelOrder(orderId);
    if (success) {
      await loadOrders();
    }
    return success;
  }

  Future<bool> submitComplaint({
    required String orderId,
    required String reason,
    required String description,
  }) async {
    final success = await _orderRepository.submitComplaint(orderId, reason, description);
    if (success) {
      await loadOrders();
    }
    return success;
  }

  Future<bool> submitReview({
    required String orderId,
    required double rating,
    required String comment,
  }) async {
    final success = await _orderRepository.submitReview(orderId, rating, comment);
    if (success) {
      await loadOrders();
    }
    return success;
  }

  OrderModel? getOrder(String orderId) {
    try {
      return _orders.firstWhere((o) => o.id == orderId);
    } catch (_) {
      return null;
    }
  }
}
