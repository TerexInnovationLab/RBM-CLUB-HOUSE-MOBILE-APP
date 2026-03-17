import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/app_error_widget.dart';
import '../../../shared/widgets/offline_banner.dart';
import '../../../shared/widgets/rbm_app_bar.dart';
import '../../../shared/widgets/rbm_tab_scaffold.dart';
import '../providers/transaction_provider.dart';
import '../widgets/transaction_filter_bar.dart';
import '../widgets/transaction_list_item.dart';

/// Transactions list screen.
class TransactionListScreen extends ConsumerWidget {
  /// Creates a transaction list screen.
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tx = ref.watch(transactionsProvider);

    return OfflineBanner(
      child: RbmTabScaffold(
        currentIndex: 1,
        appBar: RbmAppBar(
          title: AppStrings.transactionsTitle,
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search),
              tooltip: 'Search',
            ),
          ],
        ),
        body: tx.when(
          data: (items) => ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length + 1,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TransactionFilterBar(transactionCount: items.length),
                );
              }
              final item = items[index - 1];
              return TransactionListItem(
                transaction: item,
                onTap: () => context.go('/transactions/${item.id}'),
              );
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => AppErrorWidget(
            message: 'Failed to load transactions: $e',
            onRetry: () => ref.refresh(transactionsProvider),
          ),
        ),
      ),
    );
  }
}
