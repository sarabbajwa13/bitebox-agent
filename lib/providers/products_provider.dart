import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/repositories/agent_repository.dart';
import '../models/product.dart';

/// Manages the store's products (admin add/edit/delete), real-time.
class ProductsProvider extends ChangeNotifier {
  final AgentRepository repository;
  ProductsProvider({required this.repository});

  StreamSubscription<List<Product>>? _sub;
  bool _loading = true;
  List<Product> _products = [];

  bool get isLoading => _loading;
  List<Product> get products => _products;

  void start() {
    _sub ??= repository.watchProducts().listen((list) {
      _products = list;
      _loading = false;
      notifyListeners();
    });
  }

  Future<void> add(Product product) => repository.addProduct(product);
  Future<void> update(Product product) => repository.updateProduct(product);
  Future<void> delete(String id) => repository.deleteProduct(id);

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
