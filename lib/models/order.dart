import 'cart_item.dart';

enum FulfilmentType {
  delivery,
  pickup,
  dineIn,
}

extension FulfilmentTypeExtension on FulfilmentType {
  String get displayName {
    switch (this) {
      case FulfilmentType.delivery:
        return 'Delivery';
      case FulfilmentType.pickup:
        return 'Pickup';
      case FulfilmentType.dineIn:
        return 'Dine-in';
    }
  }
}

enum OrderStatus {
  received,
  accepted,
  preparing,
  outForDelivery, // Or readyForPickup / readyDineIn depending on fulfilment
  delivered,
  cancelled,
  rejected,
}

extension OrderStatusExtension on OrderStatus {
  String displayName(FulfilmentType type) {
    switch (this) {
      case OrderStatus.received:
        return 'Received';
      case OrderStatus.accepted:
        return 'Accepted';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.outForDelivery:
        if (type == FulfilmentType.pickup) return 'Ready for Pickup';
        if (type == FulfilmentType.dineIn) return 'Ready — Dine-in';
        return 'Out for Delivery';
      case OrderStatus.delivered:
        if (type == FulfilmentType.pickup) return 'Picked Up';
        if (type == FulfilmentType.dineIn) return 'Served';
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.rejected:
        return 'Rejected';
    }
  }

  bool get isCancellable =>
      this == OrderStatus.received || this == OrderStatus.accepted;

  bool get isTerminal =>
      this == OrderStatus.delivered ||
      this == OrderStatus.cancelled ||
      this == OrderStatus.rejected;
}

class Complaint {
  final String id;
  final String orderId;
  final String reason;
  final String description;
  final DateTime createdAt;

  const Complaint({
    required this.id,
    required this.orderId,
    required this.reason,
    required this.description,
    required this.createdAt,
  });
}

class OrderModel {
  final String id;
  final String restaurantId;
  final String restaurantName;
  final String restaurantImage;
  final List<CartItem> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final FulfilmentType fulfilmentType;
  final String paymentMethod; // Cash on Delivery
  final OrderStatus status;
  final DateTime createdAt;
  final String? deliveryAddress;
  final String? tableNumber;
  final bool isReviewed;
  final Complaint? complaint;

  const OrderModel({
    required this.id,
    required this.restaurantId,
    required this.restaurantName,
    required this.restaurantImage,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.fulfilmentType,
    this.paymentMethod = 'Cash on Delivery',
    required this.status,
    required this.createdAt,
    this.deliveryAddress,
    this.tableNumber,
    this.isReviewed = false,
    this.complaint,
  });

  OrderModel copyWith({
    OrderStatus? status,
    bool? isReviewed,
    Complaint? complaint,
  }) {
    return OrderModel(
      id: id,
      restaurantId: restaurantId,
      restaurantName: restaurantName,
      restaurantImage: restaurantImage,
      items: items,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      total: total,
      fulfilmentType: fulfilmentType,
      paymentMethod: paymentMethod,
      status: status ?? this.status,
      createdAt: createdAt,
      deliveryAddress: deliveryAddress,
      tableNumber: tableNumber,
      isReviewed: isReviewed ?? this.isReviewed,
      complaint: complaint ?? this.complaint,
    );
  }
}
