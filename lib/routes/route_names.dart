/// Named route constants.
abstract final class RouteNames {
  static const String splash = '/';
  static const String activation = '/activation';
  static const String activationVerify = '/activation/verify';
  static const String activationSuccess = '/activation/success';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String forgotPasswordCheck = '/forgot-password/check';
  static const String setPin = '/set-pin';

  static const String home = '/home';
  static const String wallet = '/wallet';
  static const String transactions = '/transactions';
  static const String transactionDetail = '/transactions/:id';
  static const String receipt = '/receipts/:id';
  static const String card = '/card';
  static const String fullscreenQr = '/card/qr';
  static const String notifications = '/notifications';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String changePin = '/profile/change-pin';
  static const String settings = '/profile/settings';
  static const String trustedDevices = '/profile/trusted-devices';
  static const String help = '/help';
  static const String faq = '/help/faq';
}
