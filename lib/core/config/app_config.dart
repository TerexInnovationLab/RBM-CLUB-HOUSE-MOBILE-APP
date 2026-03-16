/// Build-time and runtime app configuration.
abstract final class AppConfig {
  /// Forces demo mode via `--dart-define=DEMO_MODE=true`.
  static const bool demoOverride = bool.fromEnvironment('DEMO_MODE', defaultValue: false);

  static String _environment() =>
      const String.fromEnvironment('ENV', defaultValue: 'dev').toLowerCase();

  static String _apiBaseUrl() {
    final env = _environment();
    if (env == 'prod') {
      return const String.fromEnvironment('API_BASE_URL_PROD', defaultValue: '');
    }
    return const String.fromEnvironment('API_BASE_URL_DEV', defaultValue: '');
  }

  /// True when the app should use demo/offline flows.
  ///
  /// By default, demo mode activates when no API base URL is provided.
  static bool get isDemo => demoOverride || _apiBaseUrl().isEmpty;
}

