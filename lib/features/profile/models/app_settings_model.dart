/// Theme preference options.
enum AppThemePreference { system, light, dark }

/// Default receipt behavior options.
enum ReceiptBehavior { ask, download, share }

/// Data refresh behavior options.
enum RefreshBehavior { auto, manual }

/// Persisted app settings model.
class AppSettingsModel {
  const AppSettingsModel({
    required this.notificationPermission,
    required this.notificationTransactions,
    required this.notificationLowBalance,
    required this.notificationWalletCycle,
    required this.notificationSecurityAlerts,
    required this.quietHoursEnabled,
    required this.quietHoursStartHour,
    required this.quietHoursEndHour,
    required this.notificationSound,
    required this.notificationVibration,
    required this.hideBalancesByDefault,
    required this.screenshotProtection,
    required this.biometricPermission,
    required this.themePreference,
    required this.textScale,
    required this.compactMode,
    required this.receiptBehavior,
    required this.confirmationPrompts,
    required this.amountMasking,
    required this.refreshBehavior,
    required this.offlineDataControls,
  });

  final bool notificationPermission;
  final bool notificationTransactions;
  final bool notificationLowBalance;
  final bool notificationWalletCycle;
  final bool notificationSecurityAlerts;
  final bool quietHoursEnabled;
  final int quietHoursStartHour;
  final int quietHoursEndHour;
  final bool notificationSound;
  final bool notificationVibration;
  final bool hideBalancesByDefault;
  final bool screenshotProtection;
  final bool biometricPermission;
  final AppThemePreference themePreference;
  final double textScale;
  final bool compactMode;
  final ReceiptBehavior receiptBehavior;
  final bool confirmationPrompts;
  final bool amountMasking;
  final RefreshBehavior refreshBehavior;
  final bool offlineDataControls;

  static const AppSettingsModel defaults = AppSettingsModel(
    notificationPermission: true,
    notificationTransactions: true,
    notificationLowBalance: true,
    notificationWalletCycle: true,
    notificationSecurityAlerts: true,
    quietHoursEnabled: false,
    quietHoursStartHour: 22,
    quietHoursEndHour: 6,
    notificationSound: true,
    notificationVibration: true,
    hideBalancesByDefault: true,
    screenshotProtection: false,
    biometricPermission: true,
    themePreference: AppThemePreference.system,
    textScale: 1.0,
    compactMode: false,
    receiptBehavior: ReceiptBehavior.ask,
    confirmationPrompts: true,
    amountMasking: false,
    refreshBehavior: RefreshBehavior.auto,
    offlineDataControls: true,
  );

  AppSettingsModel copyWith({
    bool? notificationPermission,
    bool? notificationTransactions,
    bool? notificationLowBalance,
    bool? notificationWalletCycle,
    bool? notificationSecurityAlerts,
    bool? quietHoursEnabled,
    int? quietHoursStartHour,
    int? quietHoursEndHour,
    bool? notificationSound,
    bool? notificationVibration,
    bool? hideBalancesByDefault,
    bool? screenshotProtection,
    bool? biometricPermission,
    AppThemePreference? themePreference,
    double? textScale,
    bool? compactMode,
    ReceiptBehavior? receiptBehavior,
    bool? confirmationPrompts,
    bool? amountMasking,
    RefreshBehavior? refreshBehavior,
    bool? offlineDataControls,
  }) {
    return AppSettingsModel(
      notificationPermission:
          notificationPermission ?? this.notificationPermission,
      notificationTransactions:
          notificationTransactions ?? this.notificationTransactions,
      notificationLowBalance:
          notificationLowBalance ?? this.notificationLowBalance,
      notificationWalletCycle:
          notificationWalletCycle ?? this.notificationWalletCycle,
      notificationSecurityAlerts:
          notificationSecurityAlerts ?? this.notificationSecurityAlerts,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursStartHour: quietHoursStartHour ?? this.quietHoursStartHour,
      quietHoursEndHour: quietHoursEndHour ?? this.quietHoursEndHour,
      notificationSound: notificationSound ?? this.notificationSound,
      notificationVibration:
          notificationVibration ?? this.notificationVibration,
      hideBalancesByDefault:
          hideBalancesByDefault ?? this.hideBalancesByDefault,
      screenshotProtection: screenshotProtection ?? this.screenshotProtection,
      biometricPermission: biometricPermission ?? this.biometricPermission,
      themePreference: themePreference ?? this.themePreference,
      textScale: textScale ?? this.textScale,
      compactMode: compactMode ?? this.compactMode,
      receiptBehavior: receiptBehavior ?? this.receiptBehavior,
      confirmationPrompts: confirmationPrompts ?? this.confirmationPrompts,
      amountMasking: amountMasking ?? this.amountMasking,
      refreshBehavior: refreshBehavior ?? this.refreshBehavior,
      offlineDataControls: offlineDataControls ?? this.offlineDataControls,
    );
  }

  Map<String, dynamic> toJson() => {
    'notificationPermission': notificationPermission,
    'notificationTransactions': notificationTransactions,
    'notificationLowBalance': notificationLowBalance,
    'notificationWalletCycle': notificationWalletCycle,
    'notificationSecurityAlerts': notificationSecurityAlerts,
    'quietHoursEnabled': quietHoursEnabled,
    'quietHoursStartHour': quietHoursStartHour,
    'quietHoursEndHour': quietHoursEndHour,
    'notificationSound': notificationSound,
    'notificationVibration': notificationVibration,
    'hideBalancesByDefault': hideBalancesByDefault,
    'screenshotProtection': screenshotProtection,
    'biometricPermission': biometricPermission,
    'themePreference': themePreference.name,
    'textScale': textScale,
    'compactMode': compactMode,
    'receiptBehavior': receiptBehavior.name,
    'confirmationPrompts': confirmationPrompts,
    'amountMasking': amountMasking,
    'refreshBehavior': refreshBehavior.name,
    'offlineDataControls': offlineDataControls,
  };

  factory AppSettingsModel.fromJson(Map<String, dynamic> json) {
    AppThemePreference parseTheme(String? v) {
      return AppThemePreference.values.firstWhere(
        (e) => e.name == v,
        orElse: () => AppThemePreference.system,
      );
    }

    ReceiptBehavior parseReceipt(String? v) {
      return ReceiptBehavior.values.firstWhere(
        (e) => e.name == v,
        orElse: () => ReceiptBehavior.ask,
      );
    }

    RefreshBehavior parseRefresh(String? v) {
      return RefreshBehavior.values.firstWhere(
        (e) => e.name == v,
        orElse: () => RefreshBehavior.auto,
      );
    }

    final startHour = (json['quietHoursStartHour'] as num?)?.toInt() ?? 22;
    final endHour = (json['quietHoursEndHour'] as num?)?.toInt() ?? 6;
    final scaleRaw = (json['textScale'] as num?)?.toDouble() ?? 1.0;

    return AppSettingsModel(
      notificationPermission: json['notificationPermission'] as bool? ?? true,
      notificationTransactions:
          json['notificationTransactions'] as bool? ?? true,
      notificationLowBalance: json['notificationLowBalance'] as bool? ?? true,
      notificationWalletCycle: json['notificationWalletCycle'] as bool? ?? true,
      notificationSecurityAlerts:
          json['notificationSecurityAlerts'] as bool? ?? true,
      quietHoursEnabled: json['quietHoursEnabled'] as bool? ?? false,
      quietHoursStartHour: startHour.clamp(0, 23),
      quietHoursEndHour: endHour.clamp(0, 23),
      notificationSound: json['notificationSound'] as bool? ?? true,
      notificationVibration: json['notificationVibration'] as bool? ?? true,
      hideBalancesByDefault: json['hideBalancesByDefault'] as bool? ?? true,
      screenshotProtection: json['screenshotProtection'] as bool? ?? false,
      biometricPermission: json['biometricPermission'] as bool? ?? true,
      themePreference: parseTheme(json['themePreference'] as String?),
      textScale: scaleRaw.clamp(0.85, 1.25),
      compactMode: json['compactMode'] as bool? ?? false,
      receiptBehavior: parseReceipt(json['receiptBehavior'] as String?),
      confirmationPrompts: json['confirmationPrompts'] as bool? ?? true,
      amountMasking: json['amountMasking'] as bool? ?? false,
      refreshBehavior: parseRefresh(json['refreshBehavior'] as String?),
      offlineDataControls: json['offlineDataControls'] as bool? ?? true,
    );
  }
}
