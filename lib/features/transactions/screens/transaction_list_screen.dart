import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/app_error_widget.dart';
import '../../../shared/widgets/offline_banner.dart';
import '../../../shared/widgets/rbm_app_bar.dart';
import '../../../shared/widgets/rbm_card.dart';
import '../../../shared/widgets/rbm_tab_scaffold.dart';
import '../../profile/models/app_settings_model.dart';
import '../../profile/providers/app_settings_provider.dart';
import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../widgets/transaction_filter_bar.dart';
import '../widgets/transaction_list_item.dart';
import '../widgets/transaction_reports_view.dart';

/// Transactions list screen.
class TransactionListScreen extends ConsumerStatefulWidget {
  /// Creates a transaction list screen.
  const TransactionListScreen({super.key});

  @override
  ConsumerState<TransactionListScreen> createState() =>
      _TransactionListScreenState();
}

class _TransactionListScreenState extends ConsumerState<TransactionListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedSegment = 'Transactions';
  _TransactionFilterState _activeFilter = const _TransactionFilterState();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tx = ref.watch(transactionsProvider);
    final settings = ref.watch(appSettingsProvider);

    return OfflineBanner(
      child: RbmTabScaffold(
        currentIndex: 1,
        appBar: const RbmAppBar(
          title: AppStrings.transactionsTitle,
          centerTitle: true,
        ),
        body: tx.when(
          data: (items) {
            final filtered = _filterTransactions(
              items,
              _searchQuery,
              _activeFilter,
            );
            final sections = _buildSections(filtered);

            final content = ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                TransactionFilterBar(
                  transactionCount: filtered.length,
                  searchController: _searchController,
                  searchQuery: _searchQuery,
                  selectedSegment: _selectedSegment,
                  filterActive: _activeFilter.isActive,
                  onFilterTap: _openFilterSheet,
                  onSegmentChanged: (segment) {
                    setState(() => _selectedSegment = segment);
                  },
                  onSearchChanged: (value) =>
                      setState(() => _searchQuery = value),
                  onClearSearch: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                ),
                const SizedBox(height: 18),
                if (_selectedSegment == 'Reports')
                  TransactionReportsView(transactions: filtered)
                else if (sections.isEmpty)
                  const _NoTransactionsFound()
                else ...[
                  for (final section in sections) ...[
                    _SectionHeader(title: section.title),
                    const SizedBox(height: 8),
                    RbmCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      child: Column(
                        children: [
                          for (var i = 0; i < section.items.length; i++)
                            TransactionListItem(
                              transaction: section.items[i],
                              onTap: () => context.go(
                                '/transactions/${section.items[i].id}',
                              ),
                              showDivider: i != section.items.length - 1,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                ],
              ],
            );

            if (settings.refreshBehavior == RefreshBehavior.manual) {
              return RefreshIndicator(
                onRefresh: () async => ref.refresh(transactionsProvider.future),
                child: content,
              );
            }
            return content;
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => AppErrorWidget(
            message: 'Failed to load transactions: $e',
            onRetry: () => ref.refresh(transactionsProvider),
          ),
        ),
      ),
    );
  }

  List<TransactionModel> _filterTransactions(
    List<TransactionModel> items,
    String query,
    _TransactionFilterState filterState,
  ) {
    final normalized = query.trim().toLowerCase();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return items.where((item) {
      final merchant = item.merchant.toLowerCase();
      final type = item.transactionType.toLowerCase();
      final status = item.status.toLowerCase();
      final amount = CurrencyFormatter.formatTransaction(
        item.amount,
      ).toLowerCase();
      final matchesSearch =
          normalized.isEmpty ||
          merchant.contains(normalized) ||
          type.contains(normalized) ||
          status.contains(normalized) ||
          amount.contains(normalized);
      if (!matchesSearch) return false;

      final isCredit = _isCredit(item);
      final matchesType = switch (filterState.type) {
        _TransactionTypeFilter.all => true,
        _TransactionTypeFilter.purchases => !isCredit,
        _TransactionTypeFilter.credits => isCredit,
      };
      if (!matchesType) return false;

      final local = item.occurredAt.toLocal();
      final day = DateTime(local.year, local.month, local.day);
      final diffDays = today.difference(day).inDays;
      final matchesDate = switch (filterState.dateRange) {
        _TransactionDateFilter.all => true,
        _TransactionDateFilter.today => diffDays == 0,
        _TransactionDateFilter.last7Days => diffDays >= 0 && diffDays < 7,
        _TransactionDateFilter.last30Days => diffDays >= 0 && diffDays < 30,
      };
      return matchesDate;
    }).toList();
  }

  List<_TransactionSection> _buildSections(List<TransactionModel> items) {
    final sorted = [...items]
      ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayItems = <TransactionModel>[];
    final yesterdayItems = <TransactionModel>[];
    final past30Items = <TransactionModel>[];
    final earlierItems = <TransactionModel>[];

    for (final item in sorted) {
      final local = item.occurredAt.toLocal();
      final dateOnly = DateTime(local.year, local.month, local.day);
      final diffDays = today.difference(dateOnly).inDays;

      if (diffDays == 0) {
        todayItems.add(item);
      } else if (diffDays == 1) {
        yesterdayItems.add(item);
      } else if (diffDays > 1 && diffDays <= 30) {
        past30Items.add(item);
      } else {
        earlierItems.add(item);
      }
    }

    final sections = <_TransactionSection>[];
    if (todayItems.isNotEmpty) {
      sections.add(_TransactionSection(title: 'Today', items: todayItems));
    }
    if (yesterdayItems.isNotEmpty) {
      sections.add(
        _TransactionSection(title: 'Yesterday', items: yesterdayItems),
      );
    }
    if (past30Items.isNotEmpty) {
      sections.add(
        _TransactionSection(title: 'Past 30 Days', items: past30Items),
      );
    }
    if (earlierItems.isNotEmpty) {
      sections.add(_TransactionSection(title: 'Earlier', items: earlierItems));
    }
    return sections;
  }

  bool _isCredit(TransactionModel transaction) {
    final type = transaction.transactionType.toUpperCase();
    return type.contains('ALLOCATION') ||
        type.contains('CREDIT') ||
        type.contains('TOPUP');
  }

  Future<void> _openFilterSheet() async {
    final result = await showModalBottomSheet<_TransactionFilterState>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        var selectedType = _activeFilter.type;
        var selectedDate = _activeFilter.dateRange;

        return StatefulBuilder(
          builder: (context, setModalState) {
            Widget buildTypeChip(String label, _TransactionTypeFilter value) {
              return ChoiceChip(
                label: Text(label),
                selected: selectedType == value,
                showCheckmark: false,
                backgroundColor: AppColors.backgroundLight,
                selectedColor: AppColors.primaryBlue.withValues(alpha: 0.16),
                side: BorderSide(
                  color: selectedType == value
                      ? AppColors.primaryBlue.withValues(alpha: 0.32)
                      : AppColors.borderGray,
                ),
                labelStyle: TextStyle(
                  color: selectedType == value
                      ? AppColors.primaryBlue
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
                onSelected: (_) => setModalState(() => selectedType = value),
              );
            }

            Widget buildDateChip(String label, _TransactionDateFilter value) {
              return ChoiceChip(
                label: Text(label),
                selected: selectedDate == value,
                showCheckmark: false,
                backgroundColor: AppColors.backgroundLight,
                selectedColor: AppColors.primaryBlue.withValues(alpha: 0.16),
                side: BorderSide(
                  color: selectedDate == value
                      ? AppColors.primaryBlue.withValues(alpha: 0.32)
                      : AppColors.borderGray,
                ),
                labelStyle: TextStyle(
                  color: selectedDate == value
                      ? AppColors.primaryBlue
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
                onSelected: (_) => setModalState(() => selectedDate = value),
              );
            }

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filter Transactions',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Type',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        buildTypeChip('All', _TransactionTypeFilter.all),
                        buildTypeChip(
                          'Purchases',
                          _TransactionTypeFilter.purchases,
                        ),
                        buildTypeChip(
                          'Credits',
                          _TransactionTypeFilter.credits,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Date Range',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        buildDateChip('All', _TransactionDateFilter.all),
                        buildDateChip('Today', _TransactionDateFilter.today),
                        buildDateChip(
                          'Last 7 Days',
                          _TransactionDateFilter.last7Days,
                        ),
                        buildDateChip(
                          'Last 30 Days',
                          _TransactionDateFilter.last30Days,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(
                              context,
                              const _TransactionFilterState(),
                            ),
                            child: const Text('Clear'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton(
                            onPressed: () => Navigator.pop(
                              context,
                              _TransactionFilterState(
                                type: selectedType,
                                dateRange: selectedDate,
                              ),
                            ),
                            child: const Text('Apply'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result == null) return;
    setState(() => _activeFilter = result);
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _NoTransactionsFound extends StatelessWidget {
  const _NoTransactionsFound();

  @override
  Widget build(BuildContext context) {
    return const RbmCard(
      padding: EdgeInsets.fromLTRB(18, 20, 18, 20),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, color: AppColors.inactive, size: 28),
          SizedBox(height: 8),
          _NoTransactionsText(),
        ],
      ),
    );
  }
}

class _NoTransactionsText extends StatelessWidget {
  const _NoTransactionsText();

  @override
  Widget build(BuildContext context) {
    return Text(
      'No transactions match this search.',
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
      textAlign: TextAlign.center,
    );
  }
}

class _TransactionSection {
  const _TransactionSection({required this.title, required this.items});

  final String title;
  final List<TransactionModel> items;
}

class _TransactionFilterState {
  const _TransactionFilterState({
    this.type = _TransactionTypeFilter.all,
    this.dateRange = _TransactionDateFilter.all,
  });

  final _TransactionTypeFilter type;
  final _TransactionDateFilter dateRange;

  bool get isActive =>
      type != _TransactionTypeFilter.all ||
      dateRange != _TransactionDateFilter.all;
}

enum _TransactionTypeFilter { all, purchases, credits }

enum _TransactionDateFilter { all, today, last7Days, last30Days }
