/// Centralized API endpoint paths.
///
/// This file intentionally contains only *paths* (not base URLs). Base URL
/// selection is handled by `ApiService`.
abstract final class ApiEndpoints {
  static const String authActivate = '/auth/activate';
  static const String authLogin = '/auth/login';
  static const String authRefresh = '/auth/refresh';
  static const String authLogout = '/auth/logout';

  static const String dashboardSummary = '/dashboard/summary';

  static const String walletBalance = '/wallet/balance';
  static const String walletMonthlySummary = '/wallet/monthly-summary';
  static const String walletAllocationHistory = '/wallet/allocation-history';

  static const String transactions = '/transactions';
  static String transactionById(String id) => '/transactions/$id';
  static String receiptById(String id) => '/receipts/$id';

  static const String virtualCard = '/card/virtual';

  static const String notifications = '/notifications';
  static String notificationById(String id) => '/notifications/$id';
  static String notificationRead(String id) => '/notifications/$id/read';
  static const String notificationsReadAll = '/notifications/read-all';

  static const String devicesRegister = '/devices/register';
  static String deviceById(String id) => '/devices/$id';

  static const String profile = '/profile';
  static const String trustedDevices = '/profile/trusted-devices';
  static const String changePin = '/profile/change-pin';

  static const String helpFaq = '/help/faq';
}
