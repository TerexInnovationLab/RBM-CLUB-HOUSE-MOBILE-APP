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

  static const List<String> _tabRoutes = [
    RouteNames.home,
    RouteNames.transactions,
    RouteNames.card,
    RouteNames.wallet,
    RouteNames.profile,
  ];

  void _onTap(BuildContext context, int index) {
    if (index < 0 || index >= _tabRoutes.length) {
      return;
    }
    context.go(_tabRoutes[index]);
  }

  void _onHorizontalDragEnd(BuildContext context, DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    const velocityThreshold = 260.0;
    if (velocity.abs() < velocityThreshold) return;

    final swipeDirection = velocity < 0 ? 1 : -1;
    final nextIndex = currentIndex + swipeDirection;
    if (nextIndex < 0 || nextIndex >= _tabRoutes.length) return;
    _onTap(context, nextIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragEnd: (details) =>
            _onHorizontalDragEnd(context, details),
        child: body,
      ),
      bottomNavigationBar: _RbmBottomNav(
        currentIndex: currentIndex,
        onTap: (index) => _onTap(context, index),
      ),
      backgroundColor: AppColors.backgroundLight,
    );
  }
}

class _RbmBottomNav extends StatelessWidget {
  const _RbmBottomNav({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const List<_NavItemData> _items = [
    _NavItemData(
      label: 'Home',
      selectedLabel: 'Home',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
    ),
    _NavItemData(
      label: 'Transactions',
      selectedLabel: 'Trans',
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long_rounded,
    ),
    _NavItemData(
      label: 'Card',
      selectedLabel: 'Card',
      icon: Icons.credit_card_outlined,
      selectedIcon: Icons.credit_card_rounded,
    ),
    _NavItemData(
      label: 'Wallet',
      selectedLabel: 'Wallet',
      icon: Icons.account_balance_wallet_outlined,
      selectedIcon: Icons.account_balance_wallet_rounded,
    ),
    _NavItemData(
      label: 'Profile',
      selectedLabel: 'Profile',
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      child: SizedBox(
        height: 72,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryBlue, AppColors.secondaryBlue],
            ),
            borderRadius: BorderRadius.circular(38),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 24,
                offset: Offset(0, 12),
                spreadRadius: -8,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final barWidth = constraints.maxWidth;
                var selectedWidth = (barWidth * 0.34).clamp(96.0, 132.0);
                var otherWidth =
                    (barWidth - selectedWidth) / (_items.length - 1);

                // Guarantee every non-selected tab keeps enough space to stay visible.
                if (otherWidth < 44) {
                  selectedWidth = (barWidth - (44 * (_items.length - 1))).clamp(
                    84.0,
                    132.0,
                  );
                  otherWidth = (barWidth - selectedWidth) / (_items.length - 1);
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(_items.length, (index) {
                    final item = _items[index];
                    final isSelected = index == currentIndex;
                    return SizedBox(
                      width: isSelected ? selectedWidth : otherWidth,
                      child: _BottomNavItem(
                        data: item,
                        isSelected: isSelected,
                        onTap: () => onTap(index),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.data,
    required this.isSelected,
    required this.onTap,
  });

  final _NavItemData data;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final inactiveIconColor = Colors.white.withAlpha(224);
    final activeIconColor = AppColors.primaryBlue;

    return Semantics(
      button: true,
      selected: isSelected,
      label: data.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            height: 58,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                height: 52,
                padding: EdgeInsets.symmetric(horizontal: isSelected ? 10 : 0),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withAlpha(245)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(28),
                  border: isSelected
                      ? Border.all(
                          color: AppColors.warningOrange.withAlpha(150),
                          width: 1,
                        )
                      : null,
                  boxShadow: isSelected
                      ? const [
                          BoxShadow(
                            color: Color(0x22000000),
                            blurRadius: 14,
                            offset: Offset(0, 6),
                            spreadRadius: -4,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isSelected ? data.selectedIcon : data.icon,
                      size: 23,
                      color: isSelected ? activeIconColor : inactiveIconColor,
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      child: isSelected
                          ? Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: Text(
                                data.selectedLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: activeIconColor,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.1,
                                    ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  const _NavItemData({
    required this.label,
    required this.selectedLabel,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final String selectedLabel;
  final IconData icon;
  final IconData selectedIcon;
}
