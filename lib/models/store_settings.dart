import '../config/app_config.dart';

/// Store configuration the agent controls — most importantly the visibility
/// radius (client app isi radius ke andar wale users ko store dikhata hai).
class StoreSettings {
  final String storeName;
  final double radiusKm;
  final bool isOpen;

  const StoreSettings({
    required this.storeName,
    required this.radiusKm,
    required this.isOpen,
  });

  factory StoreSettings.initial() => const StoreSettings(
    storeName: AppConfig.defaultStoreName,
    radiusKm: AppConfig.defaultRadiusKm,
    isOpen: true,
  );

  StoreSettings copyWith({
    String? storeName,
    double? radiusKm,
    bool? isOpen,
  }) {
    return StoreSettings(
      storeName: storeName ?? this.storeName,
      radiusKm: radiusKm ?? this.radiusKm,
      isOpen: isOpen ?? this.isOpen,
    );
  }
}
