import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_config.dart';
import '../../config/app_strings.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';

class StoreSettingsScreen extends StatelessWidget {
  const StoreSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final settings = settingsProvider.settings;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.storeSettingsTitle),
        actions: [
          IconButton(
            tooltip: AppStrings.logout,
            onPressed: () => context.read<AuthProvider>().logout(),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // ---- Store status (open / closed) ----
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _CardTitle(AppStrings.storeStatus),
                const SizedBox(height: AppSpacing.sm),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: settings.isOpen,
                  activeThumbColor: AppColors.primary,
                  onChanged: (v) =>
                      context.read<SettingsProvider>().update(isOpen: v),
                  title: Text(
                    settings.isOpen
                        ? AppStrings.openLabel
                        : AppStrings.closedLabel,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ---- Visibility radius (the key agent control) ----
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: _CardTitle(AppStrings.visibilityRadius),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        '${settings.radiusKm.toStringAsFixed(0)} ${AppStrings.km}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  AppStrings.visibilityRadiusHelp,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                Slider(
                  value: settings.radiusKm,
                  min: AppConfig.minRadiusKm,
                  max: AppConfig.maxRadiusKm,
                  divisions:
                      (AppConfig.maxRadiusKm - AppConfig.minRadiusKm).toInt(),
                  label: '${settings.radiusKm.toStringAsFixed(0)} km',
                  activeColor: AppColors.primary,
                  onChanged: (v) =>
                      context.read<SettingsProvider>().update(radiusKm: v),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${AppConfig.minRadiusKm.toStringAsFixed(0)} ${AppStrings.km}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${AppConfig.maxRadiusKm.toStringAsFixed(0)} ${AppStrings.km}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          ElevatedButton(
            onPressed: () async {
              await context.read<SettingsProvider>().save();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text(AppStrings.settingsSaved)),
              );
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text(AppStrings.saveSettings),
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _CardTitle extends StatelessWidget {
  final String text;
  const _CardTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
    );
  }
}
