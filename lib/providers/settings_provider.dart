import 'package:flutter/foundation.dart';

import '../data/repositories/agent_repository.dart';
import '../models/store_settings.dart';

/// Store settings (visibility radius, open/closed, name).
class SettingsProvider extends ChangeNotifier {
  final AgentRepository repository;
  SettingsProvider({required this.repository});

  StoreSettings _settings = StoreSettings.initial();
  bool _loaded = false;

  StoreSettings get settings => _settings;
  bool get isLoaded => _loaded;

  Future<void> load() async {
    _settings = await repository.getSettings();
    _loaded = true;
    notifyListeners();
  }

  /// Local edit (save se pehle). UI slider/toggle isse update karta hai.
  void update({String? storeName, double? radiusKm, bool? isOpen}) {
    _settings = _settings.copyWith(
      storeName: storeName,
      radiusKm: radiusKm,
      isOpen: isOpen,
    );
    notifyListeners();
  }

  Future<void> save() async {
    await repository.saveSettings(_settings);
    notifyListeners();
  }
}
