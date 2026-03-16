import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/activation_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/set_pin_screen.dart';
import '../features/card/screens/fullscreen_qr_screen.dart';
import '../features/card/screens/virtual_card_screen.dart';
import '../features/dashboard/screens/home_screen.dart';
import '../features/help/screens/faq_screen.dart';
import '../features/help/screens/help_screen.dart';
import '../features/notifications/screens/notification_list_screen.dart';
import '../features/profile/screens/change_pin_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/profile/screens/settings_screen.dart';
import '../features/profile/screens/trusted_devices_screen.dart';
import '../features/transactions/screens/receipt_screen.dart';
import '../features/transactions/screens/transaction_detail_screen.dart';
import '../features/transactions/screens/transaction_list_screen.dart';
import '../features/wallet/screens/wallet_detail_screen.dart';
import '../shared/widgets/splash_screen.dart';
import 'route_names.dart';

/// A `ChangeNotifier` that triggers GoRouter refresh when auth state changes.
class RouterNotifier extends ChangeNotifier {
  /// Creates a router notifier.
  RouterNotifier(this.ref) {
    _sub = ref.listen<AuthState>(
      authProvider,
      (previous, next) => notifyListeners(),
    );
  }

  /// Riverpod ref.
  final Ref ref;

  late final ProviderSubscription<AuthState> _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}

/// Provider for the application router.
final goRouterProvider = Provider<GoRouter>((ref) {
  final notifier = RouterNotifier(ref);
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: RouteNames.splash,
    refreshListenable: notifier,
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final loc = state.matchedLocation;

      if (auth.isBootstrapping) return RouteNames.splash;

      final isAuthRoute = loc == RouteNames.login ||
          loc == RouteNames.activation ||
          loc == RouteNames.setPin ||
          loc == RouteNames.splash;

      if (!auth.isAuthenticated) {
        return isAuthRoute ? null : RouteNames.login;
      }

      if (auth.isAuthenticated && (loc == RouteNames.login || loc == RouteNames.activation)) {
        return RouteNames.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.activation,
        builder: (context, state) => const ActivationScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.setPin,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is SetPinArgs) return SetPinScreen(args: extra);
          return const SetPinScreen(args: SetPinArgs(employeeNumber: '', temporaryPin: ''));
        },
      ),
      GoRoute(
        path: RouteNames.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: RouteNames.wallet,
        builder: (context, state) => const WalletDetailScreen(),
      ),
      GoRoute(
        path: RouteNames.transactions,
        builder: (context, state) => const TransactionListScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) =>
                TransactionDetailScreen(transactionId: state.pathParameters['id'] ?? ''),
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.receipt,
        builder: (context, state) => ReceiptScreen(receiptId: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: RouteNames.card,
        builder: (context, state) => const VirtualCardScreen(),
        routes: [
          GoRoute(
            path: 'qr',
            builder: (context, state) => const FullscreenQrScreen(),
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.notifications,
        builder: (context, state) => const NotificationListScreen(),
      ),
      GoRoute(
        path: RouteNames.profile,
        builder: (context, state) => const ProfileScreen(),
        routes: [
          GoRoute(
            path: 'change-pin',
            builder: (context, state) => const ChangePinScreen(),
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: 'trusted-devices',
            builder: (context, state) => const TrustedDevicesScreen(),
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.help,
        builder: (context, state) => const HelpScreen(),
        routes: [
          GoRoute(
            path: 'faq',
            builder: (context, state) => const FaqScreen(),
          ),
        ],
      ),
    ],
  );
});
