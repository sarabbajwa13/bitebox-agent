/// Order lifecycle status — client app ke saath match karta hai.
enum OrderStatus {
  pending,
  accepted,
  preparing,
  outForDelivery,
  delivered,
  rejected,
}

extension OrderStatusInfo on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'New';
      case OrderStatus.accepted:
        return 'Accepted';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.outForDelivery:
        return 'Out for delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.rejected:
        return 'Rejected';
    }
  }

  bool get isTerminal =>
      this == OrderStatus.delivered || this == OrderStatus.rejected;

  /// Buckets used by the Orders screen filter.
  bool get isNew => this == OrderStatus.pending;
  bool get isActive =>
      this == OrderStatus.accepted ||
      this == OrderStatus.preparing ||
      this == OrderStatus.outForDelivery;
  bool get isDone => this == OrderStatus.delivered || this == OrderStatus.rejected;
}

/// A single line in an order.
class OrderItem {
  final String name;
  final double price;
  final int quantity;

  const OrderItem({
    required this.name,
    required this.price,
    required this.quantity,
  });

  double get lineTotal => price * quantity;

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    name: (json['variantName'] ?? json['name']) as String,
    price: (json['price'] as num).toDouble(),
    quantity: (json['quantity'] as num).toInt(),
  );

  Map<String, dynamic> toMap() => {
    'name': name,
    'price': price,
    'quantity': quantity,
  };
}

/// An order received from the client app.
class AgentOrder {
  final String id;
  final String storeId;
  final String customerName;
  final String customerPhone;
  final List<OrderItem> items;
  final double total;
  final DateTime createdAt;

  /// Mutable — agent isko accept/reject/advance karta hai.
  OrderStatus status;
  DateTime statusUpdatedAt;

  AgentOrder({
    required this.id,
    this.storeId = '',
    required this.customerName,
    required this.customerPhone,
    required this.items,
    required this.total,
    required this.createdAt,
    this.status = OrderStatus.pending,
    DateTime? statusUpdatedAt,
  }) : statusUpdatedAt = statusUpdatedAt ?? createdAt;

  int get totalQuantity => items.fold(0, (sum, e) => sum + e.quantity);

  /// Firestore document → AgentOrder. `createdAt`/`statusUpdatedAt` Timestamp
  /// ya ISO string dono handle karta hai (client kis format me likhe).
  factory AgentOrder.fromMap(String id, Map<String, dynamic> map) {
    return AgentOrder(
      id: id,
      storeId: (map['storeId'] ?? '') as String,
      customerName: (map['customerName'] ?? '') as String,
      customerPhone: (map['customerPhone'] ?? '') as String,
      items: ((map['items'] as List<dynamic>?) ?? [])
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (map['total'] as num?)?.toDouble() ?? 0,
      createdAt: _parseTime(map['createdAt']) ?? DateTime.now(),
      status: _parseStatus(map['status']),
      statusUpdatedAt: _parseTime(map['statusUpdatedAt']),
    );
  }

  Map<String, dynamic> toMap() => {
    'storeId': storeId,
    'customerName': customerName,
    'customerPhone': customerPhone,
    'items': items.map((e) => e.toMap()).toList(),
    'total': total,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
    'statusUpdatedAt': statusUpdatedAt.toIso8601String(),
  };

  static OrderStatus _parseStatus(dynamic value) {
    final name = (value ?? 'pending').toString();
    return OrderStatus.values.firstWhere(
      (s) => s.name == name,
      orElse: () => OrderStatus.pending,
    );
  }

  /// Firestore Timestamp has a `toDate()` method; we duck-type it to avoid a
  /// hard import here (kept model Firebase-agnostic).
  static DateTime? _parseTime(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.tryParse(value);
    try {
      // Firestore Timestamp
      return (value as dynamic).toDate() as DateTime;
    } catch (_) {
      return null;
    }
  }
}
