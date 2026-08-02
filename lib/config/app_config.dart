/// Central business + feature configuration for BiteBox Agent.
///
/// Ye app store/agent ke liye hai — client se aaye orders yahan receive hote
/// hain. Firebase connect karte waqt `useMockData = false` set karna.
class AppConfig {
  AppConfig._();

  static const String businessName = 'BiteBox Agent';
  static const String tagline = 'Manage your orders & store';

  /// Currency symbol (client app se match karna chahiye).
  static const String currencySymbol = '₹';

  /// Ye agent jis store ko manage karta hai. Client app isi storeId ke saath
  /// order likhega. (Baad me login se derive kar sakte hain.)
  static const String storeId = 'store_1';

  /// Firestore collection/doc names (client app se match karna chahiye).
  static const String ordersCollection = 'orders';
  static const String storesCollection = 'stores';
  static const String productsCollection = 'products';

  /// Store ki location (client isi ke around configured-location se dikhata hai).
  /// Client ke configured user location se match — taaki store radius me dikhe.
  static const double storeLat = 28.6139;
  static const double storeLng = 77.2090;

  /// Store bootstrap defaults (pehli baar store doc banate waqt).
  static const String defaultStoreDescription =
      'Crispy fried snacks & chaat, freshly made to order';
  static const String defaultStoreImageUrl =
      'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=800&q=80';

  /// ----- Store defaults (agent inhe settings screen se badal sakta hai) -----
  static const String defaultStoreName = 'Snack Junction';
  static const double defaultRadiusKm = 6;
  static const double minRadiusKm = 1;
  static const double maxRadiusKm = 20;

  /// Phone length for validation (India: 10 digits).
  static const int phoneLength = 10;

  /// Country code for phone auth (E.164 prefix).
  static const String countryCode = '+91';

  /// OTP length (Firebase SMS code).
  static const int otpLength = 6;
}
