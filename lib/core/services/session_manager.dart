import 'dart:async';

import 'package:flutter/foundation.dart';

/// Session timeout manager (15-minute inactivity with 2-minute warning).
///
/// The UI layer is expected to call `registerActivity()` on pointer events.
class SessionManager {
  /// Creates a session manager.
  SessionManager({
    this.inactivityTimeout = const Duration(minutes: 15),
    this.warningDuration = const Duration(minutes: 2),
    required this.onWarning,
    required this.onTimeout,
  });

  /// Total inactivity duration before timeout.
  final Duration inactivityTimeout;

  /// Warning duration before timeout.
  final Duration warningDuration;

  /// Called when warning window begins.
  final VoidCallback onWarning;

  /// Called when session times out.
  final VoidCallback onTimeout;

  Timer? _warningTimer;
  Timer? _timeoutTimer;

  /// Starts tracking.
  void start() => _resetTimers();

  /// Stops tracking.
  void stop() {
    _warningTimer?.cancel();
    _timeoutTimer?.cancel();
    _warningTimer = null;
    _timeoutTimer = null;
  }

  /// Registers user activity.
  void registerActivity() => _resetTimers();

  void _resetTimers() {
    stop();
    final warningAt = inactivityTimeout - warningDuration;
    _warningTimer = Timer(warningAt, onWarning);
    _timeoutTimer = Timer(inactivityTimeout, onTimeout);
  }
}
