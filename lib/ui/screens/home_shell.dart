import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_strings.dart';
import '../../config/app_theme.dart';
import '../../data/repositories/agent_repository.dart';
import '../../providers/orders_provider.dart';
import '../../providers/products_provider.dart';
import '../../providers/settings_provider.dart';
import 'orders_screen.dart';
import 'products_screen.dart';
import 'store_settings_screen.dart';

/// Main authenticated shell with bottom navigation (Orders / Products / Store).
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Store doc ensure karo (pehli baar defaults), phir listeners start.
      await context.read<AgentRepository>().ensureStoreExists();
      if (!mounted) return;
      context.read<OrdersProvider>().start();
      context.read<ProductsProvider>().start();
      context.read<SettingsProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final newCount = context.watch<OrdersProvider>().newCount;

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          OrdersScreen(),
          ProductsScreen(),
          StoreSettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.12),
        destinations: [
          NavigationDestination(
            icon: _OrdersIcon(count: newCount, filled: false),
            selectedIcon: _OrdersIcon(count: newCount, filled: true),
            label: AppStrings.ordersTab,
          ),
          const NavigationDestination(
            icon: Icon(Icons.fastfood_outlined),
            selectedIcon: Icon(Icons.fastfood_rounded),
            label: AppStrings.productsTab,
          ),
          const NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront_rounded),
            label: AppStrings.storeTab,
          ),
        ],
      ),
    );
  }
}

class _OrdersIcon extends StatelessWidget {
  final int count;
  final bool filled;
  const _OrdersIcon({required this.count, required this.filled});

  @override
  Widget build(BuildContext context) {
    final icon = Icon(
      filled ? Icons.receipt_long_rounded : Icons.receipt_long_outlined,
    );
    if (count == 0) return icon;
    return Badge(
      label: Text('$count'),
      backgroundColor: AppColors.primary,
      child: icon,
    );
  }
}
