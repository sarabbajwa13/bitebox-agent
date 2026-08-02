import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_strings.dart';
import '../../config/app_theme.dart';
import '../../models/order.dart';
import '../../providers/orders_provider.dart';
import '../widgets/common.dart';
import 'order_detail_screen.dart';

enum _Filter { newOrders, active, done }

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  _Filter _filter = _Filter.newOrders;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrdersProvider>();

    final List<AgentOrder> list;
    switch (_filter) {
      case _Filter.newOrders:
        list = provider.newOrders;
        break;
      case _Filter.active:
        list = provider.activeOrders;
        break;
      case _Filter.done:
        list = provider.doneOrders;
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.ordersTitle),
      ),
      body: Column(
        children: [
          _FilterBar(
            filter: _filter,
            newCount: provider.newOrders.length,
            activeCount: provider.activeOrders.length,
            doneCount: provider.doneOrders.length,
            onChanged: (f) => setState(() => _filter = f),
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    // Orders real-time stream se aate hain; pull sirf feel ke liye.
                    onRefresh: () =>
                        Future<void>.delayed(const Duration(milliseconds: 300)),
                    child: list.isEmpty
                        ? _emptyFor(_filter)
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.md,
                              AppSpacing.md,
                              AppSpacing.md,
                              96,
                            ),
                            itemCount: list.length,
                            itemBuilder: (context, i) =>
                                _OrderCard(order: list[i]),
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _emptyFor(_Filter f) {
    // ListView needed so pull-to-refresh works even when empty.
    late final Widget empty;
    switch (f) {
      case _Filter.newOrders:
        empty = const EmptyState(
          icon: Icons.inbox_outlined,
          title: AppStrings.noOrdersNew,
          subtitle: AppStrings.noOrdersNewSub,
        );
        break;
      case _Filter.active:
        empty = const EmptyState(
          icon: Icons.local_fire_department_outlined,
          title: AppStrings.noOrdersActive,
          subtitle: 'Accepted orders you are working on show here',
        );
        break;
      case _Filter.done:
        empty = const EmptyState(
          icon: Icons.done_all_rounded,
          title: AppStrings.noOrdersDone,
          subtitle: 'Delivered & rejected orders show here',
        );
        break;
    }
    return ListView(
      children: [SizedBox(height: 120), empty],
    );
  }
}

class _FilterBar extends StatelessWidget {
  final _Filter filter;
  final int newCount;
  final int activeCount;
  final int doneCount;
  final ValueChanged<_Filter> onChanged;
  const _FilterBar({
    required this.filter,
    required this.newCount,
    required this.activeCount,
    required this.doneCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          _chip('${AppStrings.filterNew} ($newCount)', _Filter.newOrders),
          const SizedBox(width: AppSpacing.sm),
          _chip('${AppStrings.filterActive} ($activeCount)', _Filter.active),
          const SizedBox(width: AppSpacing.sm),
          _chip('${AppStrings.filterDone} ($doneCount)', _Filter.done),
        ],
      ),
    );
  }

  Widget _chip(String label, _Filter value) {
    final selected = filter == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.background,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final AgentOrder order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => OrderDetailScreen(orderId: order.id),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.customerName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '#${order.id} · ${timeAgo(order.createdAt)}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    StatusChip(status: order.status),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  order.items
                      .map((e) => '${e.quantity}× ${e.name}')
                      .join(',  '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Text(
                      '${order.totalQuantity} ${AppStrings.items.toLowerCase()} · ',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      formatPrice(order.total),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                _Actions(order: order),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Inline quick actions per order status.
class _Actions extends StatelessWidget {
  final AgentOrder order;
  const _Actions({required this.order});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<OrdersProvider>();

    if (order.status == OrderStatus.pending) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => provider.accept(order.id),
                icon: const Icon(Icons.check_rounded, size: 18),
                label: const Text(AppStrings.accept),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _confirmReject(context, provider),
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
          ],
        ),
      );
    }

    if (order.status.isActive) {
      final label = switch (order.status) {
        OrderStatus.accepted => AppStrings.startPreparing,
        OrderStatus.preparing => AppStrings.markOutForDelivery,
        OrderStatus.outForDelivery => AppStrings.markDelivered,
        _ => '',
      };
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.md),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => provider.advance(order.id),
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            label: Text(label),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Future<void> _confirmReject(
    BuildContext context,
    OrdersProvider provider,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(AppStrings.rejectConfirmTitle),
        content: const Text(AppStrings.rejectConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text(AppStrings.reject),
          ),
        ],
      ),
    );
    if (ok == true) provider.reject(order.id);
  }
}
