import 'package:cloud_firestore/cloud_firestore.dart';

import '../../config/app_config.dart';
import '../../models/order.dart';
import '../../models/product.dart';
import '../../models/store_settings.dart';
import 'agent_repository.dart';

/// Firestore-backed repository. Client app aur agent app dono isi data pe
/// kaam karte hain.
///
/// Schema:
///  stores/{id}    → { name, description, imageUrl, rating, deliveryTimeMins,
///                     isOpen, isVeg, lat, lng, radiusKm, fcmTokens[] }
///  products/{id}  → { storeId, name, description, imageUrl, category, isVeg,
///                     isAvailable, variants[] }
///  orders/{id}    → { storeId, customerId, customerName, customerPhone,
///                     items[], total, status, createdAt, statusUpdatedAt }
class FirebaseAgentRepository implements AgentRepository {
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _orders =>
      _db.collection(AppConfig.ordersCollection);
  CollectionReference<Map<String, dynamic>> get _products =>
      _db.collection(AppConfig.productsCollection);
  DocumentReference<Map<String, dynamic>> get _storeDoc =>
      _db.collection(AppConfig.storesCollection).doc(AppConfig.storeId);

  @override
  Future<void> ensureStoreExists() async {
    final doc = await _storeDoc.get();
    final data = doc.data() ?? {};
    // Sirf missing fields fill karo (agent ke edits preserve rahenge).
    final defaults = <String, dynamic>{
      'name': AppConfig.defaultStoreName,
      'description': AppConfig.defaultStoreDescription,
      'imageUrl': AppConfig.defaultStoreImageUrl,
      'rating': 4.6,
      'deliveryTimeMins': 25,
      'isOpen': true,
      'isVeg': true,
      'lat': AppConfig.storeLat,
      'lng': AppConfig.storeLng,
      'radiusKm': AppConfig.defaultRadiusKm,
    };
    final missing = <String, dynamic>{};
    defaults.forEach((k, v) {
      if (!data.containsKey(k)) missing[k] = v;
    });
    if (missing.isNotEmpty) {
      await _storeDoc.set(missing, SetOptions(merge: true));
    }
  }

  // ---------------------------------------------------------------- Orders
  @override
  Stream<List<AgentOrder>> watchOrders() {
    return _orders
        .where('storeId', isEqualTo: AppConfig.storeId)
        .snapshots()
        .map((snap) {
      final list =
          snap.docs.map((d) => AgentOrder.fromMap(d.id, d.data())).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _orders.doc(orderId).update({
      'status': status.name,
      'statusUpdatedAt': DateTime.now().toIso8601String(),
    });
  }

  // -------------------------------------------------------------- Products
  @override
  Stream<List<Product>> watchProducts() {
    return _products
        .where('storeId', isEqualTo: AppConfig.storeId)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Product.fromMap(d.id, d.data())).toList());
  }

  @override
  Future<void> addProduct(Product product) async {
    await _products.add(product.toMap());
  }

  @override
  Future<void> updateProduct(Product product) async {
    await _products.doc(product.id).update(product.toMap());
  }

  @override
  Future<void> deleteProduct(String productId) async {
    await _products.doc(productId).delete();
  }

  // -------------------------------------------------------------- Settings
  @override
  Future<StoreSettings> getSettings() async {
    final doc = await _storeDoc.get();
    final data = doc.data();
    if (data == null) return StoreSettings.initial();
    return StoreSettings(
      storeName: (data['name'] ?? AppConfig.defaultStoreName) as String,
      radiusKm:
          (data['radiusKm'] as num?)?.toDouble() ?? AppConfig.defaultRadiusKm,
      isOpen: (data['isOpen'] ?? true) as bool,
    );
  }

  @override
  Future<void> saveSettings(StoreSettings settings) async {
    await _storeDoc.set({
      'name': settings.storeName,
      'radiusKm': settings.radiusKm,
      'isOpen': settings.isOpen,
    }, SetOptions(merge: true));
  }

  // ---------------------------------------------------------- Notifications
  @override
  Future<void> saveFcmToken(String token) async {
    await _storeDoc.set({
      'fcmTokens': FieldValue.arrayUnion([token]),
    }, SetOptions(merge: true));
  }
}
