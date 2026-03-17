import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../routes/route_names.dart';

/// Scaffold wrapper that provides the canonical bottom navigation.
class RbmTabScaffold extends StatelessWidget {
  const RbmTabScaffold({
    super.key,
    required this.currentIndex,
    required this.body,
    this.appBar,
  });

  final int currentIndex;
  final PreferredSizeWidget? appBar;
  final Widget body;

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(RouteNames.home);
        return;
      case 1:
        context.go(RouteNames.transactions);
        return;
      case 2:
        context.go(RouteNames.wallet);
        return;
      case 3:
        context.go(RouteNames.card);
        return;
      case 4:
        context.go(RouteNames.profile);
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) => _onTap(context, i),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
          NavigationDestination(
            icon: Icon(Icons.credit_card_outlined),
            selectedIcon: Icon(Icons.credit_card),
            label: 'Card',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      backgroundColor: AppColors.backgroundLight,
    );
  }
}
