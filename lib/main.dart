import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'routes/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the options from your google-services.json
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 5));
  } catch (e) {
    debugPrint('Firebase.initializeApp() timed out or failed: $e');
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
    // Use ref.read to get the service and call init without blocking the build.
    Future.microtask(() => ref.read(notificationServiceProvider).init());

    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'RBM Club House Staff App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}
