import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_strings.dart';
import '../../config/app_theme.dart';
import '../../models/order.dart';
import '../../providers/orders_provider.dart';
import '../widgets/common.dart';

class OrderDetailScreen extends StatelessWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrdersProvider>().byId(orderId);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.orderDetailTitle)),
      bottomNavigationBar: order == null
          ? null
          : _BottomActions(order: order),
      body: order == null
          ? const Center(child: Text('Order not found'))
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '#${order.id}',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    StatusChip(status: order.status),
                  ],
                ),
                Text(
                  timeAgo(order.createdAt),
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.lg),
                _Card(
                  title: AppStrings.customer,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person_outline_rounded,
                              size: 18, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Text(
                            order.customerName,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.phone_outlined,
                              size: 18, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Text(order.customerPhone),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _Card(
                  title: AppStrings.items,
                  child: Column(
                    children: [
                      for (final line in order.items)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Text(
                                '${line.quantity}×',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(line.name)),
                              Text(formatPrice(line.lineTotal)),
                            ],
                          ),
                        ),
                      const Divider(height: AppSpacing.lg),
                      Row(
                        children: [
                          const Text(
                            AppStrings.total,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            formatPrice(order.total),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final Widget child;
  const _Card({required this.title, required this.child});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: AppColors.textSecondary,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}

/// Sticky status-action bar at the bottom of the detail screen.
class _BottomActions extends StatelessWidget {
  final AgentOrder order;
  const _BottomActions({required this.order});

  @override
  Widget build(BuildContext context) {
    if (order.status.isTerminal) return const SizedBox.shrink();
    final provider = context.read<OrdersProvider>();

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: order.status == OrderStatus.pending
            ? Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await provider.reject(order.id);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        side: const BorderSide(color: AppColors.danger),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      icon: const Icon(Icons.close_rounded, size: 18),
                      label: const Text(AppStrings.reject),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () => provider.accept(order.id),
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: const Text(AppStrings.accept),
                    ),
                  ),
                ],
              )
            : SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => provider.advance(order.id),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: Text(switch (order.status) {
                    OrderStatus.accepted => AppStrings.startPreparing,
                    OrderStatus.preparing => AppStrings.markOutForDelivery,
                    OrderStatus.outForDelivery => AppStrings.markDelivered,
                    _ => '',
                  }),
                ),
              ),
      ),
    );
  }
}
