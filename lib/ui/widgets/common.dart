import 'package:flutter/material.dart';

import '../../config/app_config.dart';
import '../../config/app_theme.dart';
import '../../models/order.dart';

/// Format a price with the configured currency symbol.
String formatPrice(num value) {
  final s = value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(2);
  return '${AppConfig.currencySymbol}$s';
}

/// Human "x min ago" relative time.
String timeAgo(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} hr ago';
  return '${diff.inDays} d ago';
}

Color statusColor(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending:
      return AppColors.accent;
    case OrderStatus.rejected:
      return AppColors.danger;
    case OrderStatus.delivered:
      return AppColors.success;
    case OrderStatus.accepted:
    case OrderStatus.preparing:
    case OrderStatus.outForDelivery:
      return AppColors.primary;
  }
}

IconData statusIcon(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending:
      return Icons.fiber_new_rounded;
    case OrderStatus.accepted:
      return Icons.check_circle_outline_rounded;
    case OrderStatus.preparing:
      return Icons.restaurant_rounded;
    case OrderStatus.outForDelivery:
      return Icons.delivery_dining_rounded;
    case OrderStatus.delivered:
      return Icons.done_all_rounded;
    case OrderStatus.rejected:
      return Icons.cancel_outlined;
  }
}

/// Small rounded status chip.
class StatusChip extends StatelessWidget {
  final OrderStatus status;
  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon(status), size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            status.label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple centered empty state.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: AppColors.textSecondary),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
