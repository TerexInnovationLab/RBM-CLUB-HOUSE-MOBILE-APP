import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/rbm_card.dart';
import '../../profile/providers/app_settings_provider.dart';
import '../models/transaction_model.dart';

/// Reports overview content for the transactions module.
class TransactionReportsView extends ConsumerWidget {
  /// Creates a reports view.
  const TransactionReportsView({super.key, required this.transactions});

  /// Transactions used to build reports.
  final List<TransactionModel> transactions;

  bool _isCredit(TransactionModel t) {
    final type = t.transactionType.toUpperCase();
    return type.contains('ALLOCATION') ||
        type.contains('CREDIT') ||
        type.contains('TOPUP');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mask = ref.watch(appSettingsProvider).amountMasking;
    final monthly = _buildMonthlyStats(transactions);
    final categories = _buildCategoryTotals(transactions);
    final trend = _buildDailyTrend(transactions);
    final trendChange = _buildTrendChange(transactions);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ReportSummaryCard(stats: monthly, maskAmounts: mask),
        const SizedBox(height: 14),
        _CategoryBreakdownCard(categories: categories, maskAmounts: mask),
        const SizedBox(height: 14),
        _TrendCard(points: trend, trendChange: trendChange, maskAmounts: mask),
      ],
    );
  }

  _MonthlyStats _buildMonthlyStats(List<TransactionModel> items) {
    final now = DateTime.now();
    final monthItems = items.where((t) {
      final local = t.occurredAt.toLocal();
      return local.year == now.year && local.month == now.month;
    });

    var spent = 0.0;
    var credited = 0.0;
    var debitCount = 0;
    var largestSpend = 0.0;

    for (final t in monthItems) {
      if (_isCredit(t)) {
        credited += t.amount;
      } else {
        spent += t.amount;
        debitCount += 1;
        if (t.amount > largestSpend) largestSpend = t.amount;
      }
    }

    final avgSpend = debitCount == 0 ? 0.0 : spent / debitCount;
    return _MonthlyStats(
      spent: spent,
      credited: credited,
      net: credited - spent,
      averageSpend: avgSpend,
      largestSpend: largestSpend,
    );
  }

  Map<String, double> _buildCategoryTotals(List<TransactionModel> items) {
    final map = <String, double>{};
    for (final t in items) {
      if (_isCredit(t)) continue;
      final category = _inferCategory(t);
      map[category] = (map[category] ?? 0) + t.amount;
    }

    if (map.isEmpty) return map;

    final sorted = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(4).toList();
    final rest = sorted.skip(4).fold<double>(0, (sum, e) => sum + e.value);

    final normalized = <String, double>{for (final e in top) e.key: e.value};
    if (rest > 0) normalized['Other'] = rest;
    return normalized;
  }

  String _inferCategory(TransactionModel t) {
    final merchant = t.merchant.toLowerCase();
    if (merchant.contains('club house')) return 'Club House';
    if (merchant.contains('amazon') || merchant.contains('book')) {
      return 'Shopping';
    }
    if (merchant.contains('vimeo') ||
        merchant.contains('facebook') ||
        merchant.contains('skype') ||
        merchant.contains('subscription')) {
      return 'Subscriptions';
    }
    if (merchant.contains('transfer') || merchant.contains('bank')) {
      return 'Transfers';
    }
    if (merchant.contains('fuel') ||
        merchant.contains('taxi') ||
        merchant.contains('transport')) {
      return 'Transport';
    }
    return 'General';
  }

  List<_TrendPoint> _buildDailyTrend(List<TransactionModel> items) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final buckets = <DateTime, double>{};

    for (var i = 6; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      buckets[day] = 0;
    }

    for (final t in items) {
      if (_isCredit(t)) continue;
      final local = t.occurredAt.toLocal();
      final day = DateTime(local.year, local.month, local.day);
      if (!buckets.containsKey(day)) continue;
      buckets[day] = (buckets[day] ?? 0) + t.amount;
    }

    final points = buckets.entries
        .map((e) => _TrendPoint(day: e.key, amount: e.value))
        .toList();
    points.sort((a, b) => a.day.compareTo(b.day));
    return points;
  }

  double _buildTrendChange(List<TransactionModel> items) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final currentStart = today.subtract(const Duration(days: 6));
    final prevStart = currentStart.subtract(const Duration(days: 7));
    final prevEnd = currentStart.subtract(const Duration(days: 1));

    var current = 0.0;
    var previous = 0.0;

    for (final t in items) {
      if (_isCredit(t)) continue;
      final local = t.occurredAt.toLocal();
      final day = DateTime(local.year, local.month, local.day);
      if (!day.isBefore(currentStart) && !day.isAfter(today)) {
        current += t.amount;
      } else if (!day.isBefore(prevStart) && !day.isAfter(prevEnd)) {
        previous += t.amount;
      }
    }

    if (previous == 0) return current == 0 ? 0 : 1;
    return (current - previous) / previous;
  }
}

class _ReportSummaryCard extends StatelessWidget {
  const _ReportSummaryCard({required this.stats, required this.maskAmounts});

  final _MonthlyStats stats;
  final bool maskAmounts;

  String _money(double value) {
    if (maskAmounts) return 'MWK ******';
    return CurrencyFormatter.formatTransaction(value);
  }

  String _moneySigned(double value) {
    if (maskAmounts) return value >= 0 ? '+ MWK ******' : '- MWK ******';
    return '${value >= 0 ? '+' : '-'} '
        '${CurrencyFormatter.formatTransaction(value.abs())}';
  }

  @override
  Widget build(BuildContext context) {
    return RbmCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Summary',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: 'Spent',
                  value: _money(stats.spent),
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricTile(
                  label: 'Credited',
                  value: _money(stats.credited),
                  color: AppColors.successGreen,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricTile(
                  label: 'Net',
                  value: _moneySigned(stats.net),
                  color: stats.net >= 0
                      ? AppColors.successGreen
                      : AppColors.dangerRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Avg spend: ${_money(stats.averageSpend)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Largest: ${_money(stats.largestSpend)}',
                  textAlign: TextAlign.end,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _CategoryBreakdownCard extends StatelessWidget {
  const _CategoryBreakdownCard({
    required this.categories,
    required this.maskAmounts,
  });

  final Map<String, double> categories;
  final bool maskAmounts;

  @override
  Widget build(BuildContext context) {
    final palette = [
      AppColors.primaryBlue,
      AppColors.secondaryBlue,
      AppColors.warningOrange,
      AppColors.successGreen,
      const Color(0xFF78909C),
    ];
    final entries = categories.entries.toList();
    final total = entries.fold<double>(0, (sum, e) => sum + e.value);

    return RbmCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category Breakdown',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            Text(
              'No spending data available.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 110,
                  height: 110,
                  child: PieChart(
                    PieChartData(
                      centerSpaceRadius: 30,
                      sectionsSpace: 2,
                      borderData: FlBorderData(show: false),
                      sections: [
                        for (var i = 0; i < entries.length; i++)
                          PieChartSectionData(
                            value: entries[i].value,
                            radius: 22,
                            color: palette[i % palette.length],
                            showTitle: false,
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      for (var i = 0; i < entries.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: palette[i % palette.length],
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              const SizedBox(width: 7),
                              Expanded(
                                child: Text(
                                  entries[i].key,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: AppColors.textPrimary),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _share(entries[i].value, total),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          if (entries.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Total spending: ${maskAmounts ? 'MWK ******' : CurrencyFormatter.formatTransaction(total)}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }

  String _share(double value, double total) {
    if (total == 0) return '0%';
    return '${((value / total) * 100).toStringAsFixed(0)}%';
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({
    required this.points,
    required this.trendChange,
    required this.maskAmounts,
  });

  final List<_TrendPoint> points;
  final double trendChange;
  final bool maskAmounts;

  @override
  Widget build(BuildContext context) {
    final maxY = points.isEmpty
        ? 1.0
        : points
              .map((e) => e.amount)
              .reduce((a, b) => a > b ? a : b)
              .clamp(1.0, double.infinity);

    final positiveChange = trendChange >= 0;
    final changeColor = positiveChange
        ? AppColors.warningOrange
        : AppColors.successGreen;
    final changeLabel = points.isEmpty
        ? 'No trend yet'
        : '${positiveChange ? '+' : ''}${(trendChange * 100).toStringAsFixed(0)}% vs previous 7 days';

    return RbmCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spending Trend (7 days)',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 160,
            child: points.isEmpty
                ? Center(
                    child: Text(
                      'No transaction trend data.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : BarChart(
                    BarChartData(
                      gridData: FlGridData(
                        drawVerticalLine: false,
                        horizontalInterval: maxY / 4,
                        getDrawingHorizontalLine: (value) =>
                            FlLine(color: AppColors.borderGray, strokeWidth: 1),
                      ),
                      borderData: FlBorderData(show: false),
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= points.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  DateFormat('E').format(points[index].day),
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      barGroups: [
                        for (var i = 0; i < points.length; i++)
                          BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: points[i].amount,
                                width: 14,
                                borderRadius: BorderRadius.circular(5),
                                gradient: const LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    AppColors.primaryBlue,
                                    AppColors.secondaryBlue,
                                  ],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            changeLabel,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: changeColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            maskAmounts
                ? 'Peak day spend: MWK ******'
                : 'Peak day spend: ${CurrencyFormatter.formatTransaction(maxY)}',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _MonthlyStats {
  const _MonthlyStats({
    required this.spent,
    required this.credited,
    required this.net,
    required this.averageSpend,
    required this.largestSpend,
  });

  final double spent;
  final double credited;
  final double net;
  final double averageSpend;
  final double largestSpend;
}

class _TrendPoint {
  const _TrendPoint({required this.day, required this.amount});

  final DateTime day;
  final double amount;
}
