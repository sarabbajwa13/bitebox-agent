import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/repositories/agent_repository.dart';
import '../models/order.dart';
import '../services/notification_service.dart';

/// Manages the agent's incoming orders (real-time) and status transitions.
class OrdersProvider extends ChangeNotifier {
  final AgentRepository repository;
  OrdersProvider({required this.repository});

  StreamSubscription<List<AgentOrder>>? _sub;

  bool _loading = true;
  String? _error;
  List<AgentOrder> _orders = [];

  bool get isLoading => _loading;
  String? get error => _error;
  List<AgentOrder> get orders => _orders;

  List<AgentOrder> get newOrders =>
      _orders.where((o) => o.status.isNew).toList();
  List<AgentOrder> get activeOrders =>
      _orders.where((o) => o.status.isActive).toList();
  List<AgentOrder> get doneOrders =>
      _orders.where((o) => o.status.isDone).toList();

  int get newCount => newOrders.length;

  AgentOrder? byId(String id) {
    for (final o in _orders) {
      if (o.id == id) return o;
    }
    return null;
  }

  /// Real-time subscription start karo. FCM token bhi backend pe save karo.
  void start() {
    _sub ??= repository.watchOrders().listen(
      _onOrders,
      onError: (e) {
        _error = e.toString();
        _loading = false;
        notifyListeners();
      },
    );

    final token = NotificationService.instance.fcmToken;
    if (token != null) {
      repository.saveFcmToken(token);
    }
  }

  void _onOrders(List<AgentOrder> orders) {
    // Note: naye order ki notification ab FCM push (Cloud Function) se aati hai
    // — foreground/background/killed sab me. Isliye listener yahan sirf order
    // list update karta hai; notification yahan se nahi dikhate (warna
    // foreground me double aati).
    _orders = orders;
    _loading = false;
    notifyListeners();
  }

  Future<void> _update(String id, OrderStatus status) async {
    await repository.updateOrderStatus(id, status);
    // Firestore listener khud latest state push karega; UI turant feel ke liye
    // local bhi update kar dete hain.
    final order = byId(id);
    if (order != null) {
      order.status = status;
      order.statusUpdatedAt = DateTime.now();
      notifyListeners();
    }
  }

  Future<void> accept(String id) => _update(id, OrderStatus.accepted);
  Future<void> reject(String id) => _update(id, OrderStatus.rejected);
  Future<void> startPreparing(String id) => _update(id, OrderStatus.preparing);
  Future<void> outForDelivery(String id) =>
      _update(id, OrderStatus.outForDelivery);
  Future<void> markDelivered(String id) => _update(id, OrderStatus.delivered);

  Future<void> advance(String id) async {
    final order = byId(id);
    if (order == null) return;
    switch (order.status) {
      case OrderStatus.accepted:
        return startPreparing(id);
      case OrderStatus.preparing:
        return outForDelivery(id);
      case OrderStatus.outForDelivery:
        return markDelivered(id);
      default:
        return;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
