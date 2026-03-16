import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase configuration (google-services / GoogleService-Info) is expected
  // to be provided by the consuming environment. The app remains usable without
  // push notifications if initialization fails.
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase.initializeApp() skipped/failed: $e');
  }

  runApp(const ProviderScope(child: RbmClubStaffApp()));
}

/// RBM Club House Staff App root.
class RbmClubStaffApp extends ConsumerWidget {
  /// Creates the root application widget.
  const RbmClubStaffApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize FCM handlers (safe no-op if Firebase isn't configured).
    ref.listen(notificationServiceProvider, (_, next) => next.init());

    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'RBM Club House Staff App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}

