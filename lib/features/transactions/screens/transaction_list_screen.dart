import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/app_error_widget.dart';
import '../../../shared/widgets/offline_banner.dart';
import '../../../shared/widgets/rbm_app_bar.dart';
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
      child: Scaffold(
        appBar: const RbmAppBar(title: AppStrings.transactionsTitle),
        body: tx.when(
          data: (items) => ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length + 1,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              if (index == 0) {
                return const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: TransactionFilterBar(),
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
