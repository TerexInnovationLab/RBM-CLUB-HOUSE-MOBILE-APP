import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../routes/route_names.dart';
import '../../../shared/widgets/app_error_widget.dart';
import '../../../shared/widgets/offline_banner.dart';
import '../models/notification_model.dart';
import '../providers/notification_provider.dart';
import '../widgets/notification_list_item.dart';

/// Notification list screen.
class NotificationListScreen extends ConsumerStatefulWidget {
  /// Creates notification list screen.
  const NotificationListScreen({super.key});

  @override
  ConsumerState<NotificationListScreen> createState() =>
      _NotificationListScreenState();
}

class _NotificationListScreenState
    extends ConsumerState<NotificationListScreen> {
  String _searchQuery = '';
  bool _showUnreadOnly = false;
  final Set<String> _locallyReadIds = <String>{};
  final Set<String> _deletedIds = <String>{};
  final Map<String, _PendingDeletion> _pendingDeletions =
      <String, _PendingDeletion>{};
  bool _markingAllRead = false;
  OverlayEntry? _toastEntry;
  Timer? _toastTimer;

  @override
  void dispose() {
    _toastTimer?.cancel();
    _toastEntry?.remove();
    _toastEntry = null;
    super.dispose();
  }

  bool _isRead(NotificationModel notification) {
    return notification.isRead || _locallyReadIds.contains(notification.id);
  }

  List<NotificationModel> _applyFilters(List<NotificationModel> list) {
    final query = _searchQuery.trim().toLowerCase();

    final filtered = list.where((item) {
      if (_deletedIds.contains(item.id)) return false;

      final read = _isRead(item);
      if (_showUnreadOnly && read) return false;

      if (query.isEmpty) return true;
      final haystack = '${item.title} ${item.message} ${item.notificationType}'
          .toLowerCase();
      return haystack.contains(query);
    }).toList();

    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered;
  }

  List<_NotificationSection> _buildSections(List<NotificationModel> list) {
    final grouped = <DateTime, List<NotificationModel>>{};

    for (final item in list) {
      final local = item.createdAt.toLocal();
      final day = DateTime(local.year, local.month, local.day);
      grouped.putIfAbsent(day, () => <NotificationModel>[]).add(item);
    }

    final days = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return [
      for (final day in days)
        _NotificationSection(title: _sectionTitle(day), items: grouped[day]!),
    ];
  }

  String _sectionTitle(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (_isSameDay(day, today)) return 'Today';
    if (_isSameDay(day, yesterday)) return 'Yesterday';
    return DateFormat('EEEE, MMMM d, y').format(day);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _showTopToast({
    required String message,
    _ToastTone tone = _ToastTone.info,
  }) {
    if (!mounted) return;

    _toastTimer?.cancel();
    _toastEntry?.remove();
    _toastEntry = null;

    IconData icon;
    Color start;
    Color end;

    switch (tone) {
      case _ToastTone.success:
        icon = Icons.check_circle_outline_rounded;
        start = AppColors.successGreen;
        end = const Color(0xFF1F6B2A);
        break;
      case _ToastTone.error:
        icon = Icons.error_outline_rounded;
        start = AppColors.dangerRed;
        end = const Color(0xFF9F1F1F);
        break;
      case _ToastTone.info:
        icon = Icons.info_outline_rounded;
        start = AppColors.primaryBlue;
        end = AppColors.secondaryBlue;
        break;
    }

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    _toastEntry = OverlayEntry(
      builder: (overlayContext) {
        final topInset = MediaQuery.of(overlayContext).padding.top + 10;
        return Positioned(
          top: topInset,
          left: 16,
          right: 16,
          child: IgnorePointer(
            child: Material(
              color: Colors.transparent,
              child: _TopToastCard(
                icon: icon,
                message: message,
                start: start,
                end: end,
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(_toastEntry!);
    _toastTimer = Timer(const Duration(seconds: 3), _dismissTopToast);
  }

  void _dismissTopToast() {
    _toastTimer?.cancel();
    _toastTimer = null;
    _toastEntry?.remove();
    _toastEntry = null;
  }

  Future<void> _markAllAsRead(List<NotificationModel> source) async {
    if (_markingAllRead) return;

    setState(() {
      _markingAllRead = true;
      _locallyReadIds.addAll(source.map((n) => n.id));
    });

    try {
      await ref.read(notificationRepositoryProvider).markAllRead();
      ref.invalidate(notificationsProvider);
    } catch (_) {
      _showTopToast(
        message: 'Unable to mark all as read right now.',
        tone: _ToastTone.error,
      );
    } finally {
      if (mounted) {
        setState(() => _markingAllRead = false);
      }
    }
  }

  String _displayTitle(NotificationModel notification) {
    final title = notification.title.trim();
    if (title.isNotEmpty) {
      return title;
    }

    final type = notification.notificationType.trim();
    if (type.isEmpty) {
      return 'Notification';
    }

    return _friendlyType(type);
  }

  String _friendlyType(String rawType) {
    final parts = rawType
        .replaceAll('_', ' ')
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return 'Notification';
    }

    return parts
        .map((e) => '${e[0].toUpperCase()}${e.substring(1).toLowerCase()}')
        .join(' ');
  }

  IconData _iconForType(String notificationType) {
    final t = notificationType.toUpperCase();
    if (t.contains('ALLOCATION') || t.contains('CREDIT')) {
      return Icons.account_balance_wallet_outlined;
    }
    if (t.contains('ALERT') || t.contains('LOW')) {
      return Icons.warning_amber_rounded;
    }
    if (t.contains('SECURITY')) {
      return Icons.shield_outlined;
    }
    if (t.contains('PURCHASE') || t.contains('TRANSACTION')) {
      return Icons.receipt_long_outlined;
    }
    return Icons.notifications_outlined;
  }

  Future<bool> _deleteOnServer(String notificationId) async {
    try {
      await ref
          .read(notificationRepositoryProvider)
          .deleteNotification(notificationId);
      return true;
    } catch (_) {
      _showTopToast(
        message: 'Unable to delete notification right now.',
        tone: _ToastTone.error,
      );
      return false;
    }
  }

  void _removeLocally(String notificationId) {
    if (_deletedIds.contains(notificationId)) return;
    setState(() {
      _deletedIds.add(notificationId);
      _locallyReadIds.remove(notificationId);
    });
  }

  void _restoreLocally(String notificationId, {required bool hadLocalRead}) {
    setState(() {
      _deletedIds.remove(notificationId);
      if (hadLocalRead) {
        _locallyReadIds.add(notificationId);
      } else {
        _locallyReadIds.remove(notificationId);
      }
    });
  }

  void _showDeletedToast() {
    _showTopToast(message: 'Notification deleted.', tone: _ToastTone.success);
  }

  Future<void> _handleSwipeDeleted(NotificationModel notification) async {
    final id = notification.id;
    final hadLocalRead = _locallyReadIds.contains(id);

    _removeLocally(id);
    _pendingDeletions[id] = _PendingDeletion(hadLocalRead: hadLocalRead);

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    final controller = messenger.showSnackBar(
      SnackBar(
        content: const Text('Notification deleted'),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            final pending = _pendingDeletions.remove(id);
            if (pending == null) return;
            _restoreLocally(id, hadLocalRead: pending.hadLocalRead);
          },
        ),
      ),
    );

    final autoDismissTimer = Timer(const Duration(seconds: 4), () {
      if (!_pendingDeletions.containsKey(id)) return;
      controller.close();
    });

    final reason = await controller.closed;
    autoDismissTimer.cancel();
    final pending = _pendingDeletions.remove(id);
    if (pending == null || reason == SnackBarClosedReason.action) {
      return;
    }

    final deleted = await _deleteOnServer(id);
    if (!deleted && mounted) {
      _restoreLocally(id, hadLocalRead: pending.hadLocalRead);
    }
  }

  Future<void> _handleDeleteFromDetails(NotificationModel notification) async {
    final shouldDelete = await _showDeleteConfirmationDialog();
    if (!shouldDelete || !mounted) return;

    final deleted = await _deleteOnServer(notification.id);
    if (!deleted || !mounted) return;
    _removeLocally(notification.id);
    Navigator.of(context).pop();
    _showDeletedToast();
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x30000000),
                  blurRadius: 24,
                  offset: Offset(0, 12),
                  spreadRadius: -6,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(22),
                    ),
                    gradient: LinearGradient(
                      colors: [AppColors.dangerRed, Color(0xFF9D1F24)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.delete_forever_outlined,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Delete notification?',
                          style: Theme.of(dialogContext).textTheme.titleLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'This notification will be removed permanently and cannot be restored from this dialog.',
                    style: Theme.of(dialogContext).textTheme.bodyMedium
                        ?.copyWith(color: AppColors.textPrimary, height: 1.4),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(false),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFD9DFEC)),
                            foregroundColor: AppColors.textPrimary,
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.dangerRed,
                          ),
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(true),
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 18,
                          ),
                          label: const Text('Delete'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    return shouldDelete ?? false;
  }

  void _syncReadStatus(NotificationModel notification) async {
    if (notification.isRead) {
      return;
    }
    try {
      await ref.read(notificationRepositoryProvider).markRead(notification.id);
      ref.invalidate(notificationsProvider);
    } catch (_) {
      // Keep optimistic local state; backend sync can retry on next refresh.
    }
  }

  Future<void> _showNotificationDetails(NotificationModel notification) async {
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _NotificationDetailSheet(
        title: _displayTitle(notification),
        message: notification.message,
        typeLabel: _friendlyType(notification.notificationType),
        typeIcon: _iconForType(notification.notificationType),
        isRead: _isRead(notification),
        createdAt: notification.createdAt,
        onDelete: () => _handleDeleteFromDetails(notification),
      ),
    );
  }

  void _handleNotificationTap(NotificationModel notification) {
    if (!_isRead(notification)) {
      setState(() => _locallyReadIds.add(notification.id));
      _syncReadStatus(notification);
    }
    _showNotificationDetails(notification);
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(notificationsProvider);

    return OfflineBanner(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () => context.go(RouteNames.home),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            tooltip: 'Back to Home',
          ),
          centerTitle: true,
          title: const Text(
            'Notifications',
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: AppColors.primaryBlue,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          elevation: 0,
        ),
        body: items.when(
          data: (list) {
            final active = list
                .where((item) => !_deletedIds.contains(item.id))
                .toList();
            final allCount = active.length;
            final unreadCount = active.where((n) => !_isRead(n)).length;
            final filtered = _applyFilters(active);
            final sections = _buildSections(filtered);

            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Column(
                children: [
                  TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Search notifications',
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: const Color(0xFFF1F3F8),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: const BorderSide(
                          color: AppColors.secondaryBlue,
                          width: 1.1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            _FilterCountChip(
                              label: 'All',
                              count: allCount,
                              selected: !_showUnreadOnly,
                              onTap: () =>
                                  setState(() => _showUnreadOnly = false),
                            ),
                            const SizedBox(width: 10),
                            _FilterCountChip(
                              label: 'Unread',
                              count: unreadCount,
                              selected: _showUnreadOnly,
                              onTap: () =>
                                  setState(() => _showUnreadOnly = true),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: unreadCount == 0 || _markingAllRead
                            ? null
                            : () => _markAllAsRead(filtered),
                        child: Text(
                          _markingAllRead ? 'Marking...' : 'Mark all as read',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: filtered.isEmpty
                        ? _NotificationsEmptyState(
                            hasFilters:
                                _searchQuery.trim().isNotEmpty ||
                                _showUnreadOnly,
                          )
                        : ListView(
                            padding: const EdgeInsets.only(bottom: 18),
                            children: [
                              for (final section in sections) ...[
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    2,
                                    8,
                                    2,
                                    8,
                                  ),
                                  child: Text(
                                    section.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                                for (final item in section.items)
                                  Dismissible(
                                    key: ValueKey('notification-${item.id}'),
                                    direction: DismissDirection.endToStart,
                                    confirmDismiss: (_) async => true,
                                    onDismissed: (_) =>
                                        _handleSwipeDeleted(item),
                                    background: Container(
                                      color: Colors.transparent,
                                    ),
                                    secondaryBackground: Container(
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                      ),
                                      margin: const EdgeInsets.only(bottom: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.dangerRed,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: Colors.white,
                                      ),
                                    ),
                                    child: NotificationListItem(
                                      notification: item,
                                      isRead: _isRead(item),
                                      onTap: () => _handleNotificationTap(item),
                                    ),
                                  ),
                                const SizedBox(height: 6),
                              ],
                            ],
                          ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => AppErrorWidget(
            message: 'Failed to load notifications: $e',
            onRetry: () => ref.refresh(notificationsProvider),
          ),
        ),
      ),
    );
  }
}

enum _ToastTone { info, success, error }

class _TopToastCard extends StatelessWidget {
  const _TopToastCard({
    required this.icon,
    required this.message,
    required this.start,
    required this.end,
  });

  final IconData icon;
  final String message;
  final Color start;
  final Color end;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(colors: [start, end]),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 14,
            offset: Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterCountChip extends StatelessWidget {
  const _FilterCountChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? const Color(0xFFE9EEFF) : const Color(0xFFF1F3F8);

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 8, 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: const BoxDecoration(
                  color: AppColors.secondaryBlue,
                  borderRadius: BorderRadius.all(Radius.circular(999)),
                ),
                child: Text(
                  '$count',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationsEmptyState extends StatelessWidget {
  const _NotificationsEmptyState({required this.hasFilters});

  final bool hasFilters;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 94,
              height: 94,
              decoration: const BoxDecoration(
                color: Color(0xFFE9EEFF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 44,
                color: AppColors.secondaryBlue,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              hasFilters
                  ? 'No notifications match your filters.'
                  : 'Looks like there\'s nothing here',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hasFilters
                  ? 'Try adjusting search or switching to All.'
                  : 'You are all caught up for now.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationDetailSheet extends StatelessWidget {
  const _NotificationDetailSheet({
    required this.title,
    required this.message,
    required this.typeLabel,
    required this.typeIcon,
    required this.isRead,
    required this.createdAt,
    required this.onDelete,
  });

  final String title;
  final String message;
  final String typeLabel;
  final IconData typeIcon;
  final bool isRead;
  final DateTime createdAt;
  final Future<void> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          18,
          4,
          18,
          18 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primaryBlue, AppColors.secondaryBlue],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(typeIcon, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          typeLabel,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.88),
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE8ECF7)),
              ),
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE6EAF3)),
              ),
              child: Column(
                children: [
                  _DetailLine(label: 'Type', value: typeLabel),
                  const SizedBox(height: 10),
                  _DetailLine(
                    label: 'Status',
                    value: isRead ? 'Read' : 'Unread',
                    valueColor: isRead
                        ? AppColors.successGreen
                        : AppColors.warningOrange,
                  ),
                  const SizedBox(height: 10),
                  _DetailLine(
                    label: 'Received',
                    value: Formatters.formatLocalDateTime(createdAt),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.dangerRed,
                    ),
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 88,
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: valueColor ?? AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _PendingDeletion {
  const _PendingDeletion({required this.hadLocalRead});

  final bool hadLocalRead;
}

class _NotificationSection {
  const _NotificationSection({required this.title, required this.items});

  final String title;
  final List<NotificationModel> items;
}
