/// Build-time and runtime app configuration.
abstract final class AppConfig {
  /// Forces demo mode via `--dart-define=DEMO_MODE=true`.
  static const bool demoOverride = bool.fromEnvironment(
    'DEMO_MODE',
    defaultValue: false,
  );
  static const String demoLoginName = String.fromEnvironment(
    'DEMO_LOGIN_NAME',
    defaultValue: 'John Banda',
  );
  static const String demoLoginPin = String.fromEnvironment(
    'DEMO_LOGIN_PIN',
    defaultValue: '123456',
  );
  static const String demoActivationEmployeeNumber = String.fromEnvironment(
    'DEMO_ACTIVATION_EMPLOYEE',
    defaultValue: 'EMP-00123',
  );
  static const String demoActivationTemporaryPin = String.fromEnvironment(
    'DEMO_ACTIVATION_TEMP_PIN',
    defaultValue: '654321',
  );

  static String _environment() =>
      const String.fromEnvironment('ENV', defaultValue: 'dev').toLowerCase();

  static String _apiBaseUrl() {
    final env = _environment();
    if (env == 'prod') {
      return const String.fromEnvironment(
        'API_BASE_URL_PROD',
        defaultValue: '',
      );
    }
    return const String.fromEnvironment('API_BASE_URL_DEV', defaultValue: '');
  }

  /// True when the app should use demo/offline flows.
  ///
  /// By default, demo mode activates when no API base URL is provided.
  static bool get isDemo => demoOverride || _apiBaseUrl().isEmpty;
}
