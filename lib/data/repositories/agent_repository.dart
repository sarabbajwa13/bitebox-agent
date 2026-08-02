import '../../models/order.dart';
import '../../models/product.dart';
import '../../models/store_settings.dart';

/// Firestore-backed data layer for the agent app.
abstract class AgentRepository {
  /// Store doc ensure karo (pehli baar defaults ke saath bana do).
  Future<void> ensureStoreExists();

  // ----- Orders -----
  Stream<List<AgentOrder>> watchOrders();
  Future<void> updateOrderStatus(String orderId, OrderStatus status);

  // ----- Products (admin) -----
  Stream<List<Product>> watchProducts();
  Future<void> addProduct(Product product);
  Future<void> updateProduct(Product product);
  Future<void> deleteProduct(String productId);

  // ----- Store settings -----
  Future<StoreSettings> getSettings();
  Future<void> saveSettings(StoreSettings settings);

  // ----- Notifications -----
  Future<void> saveFcmToken(String token);
}
