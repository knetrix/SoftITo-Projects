import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/app_toast.dart';
import '../features/appointments/appointment_detail_screen.dart';
import '../features/appointments/appointments_screen.dart';
import '../features/auth/signin_screen.dart';
import '../features/auth/signup_screen.dart';
import '../features/home/main_shell.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/onboarding/welcome_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/social/chat_screen.dart';
import '../features/social/invite_detail_screen.dart';
import '../features/social/social_screen.dart';
import '../features/team/team_screen.dart';
import '../services/auth_service.dart';
import '../services/firebase_providers.dart';
import 'theme/theme_controller.dart';

const _public = {'/welcome', '/signin', '/signup'};

/// Rotalar (§3 tablosu). Korumalı rotalar oturum yoksa `/signin`'e,
/// girişten sonra hedefe döner (`?from=`).
final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final refresh = _RouterRefresh(auth.authStateChanges(), AuthService.suppressRedirect);
  ref.onDispose(refresh.dispose);
  final seen = ref.read(onboardingSeenProvider);

  final router = GoRouter(
    navigatorKey: AppToast.navigatorKey,
    initialLocation: seen ? '/team' : '/welcome',
    refreshListenable: refresh,
    redirect: (context, state) {
      if (AuthService.suppressRedirect.value) return null;
      final signedIn = auth.currentUser != null;
      final path = state.uri.path;
      final isPublic = _public.contains(path) || path.startsWith('/debug');
      if (!signedIn && !isPublic) {
        return Uri(path: '/signin', queryParameters: {'from': state.uri.toString()})
            .toString();
      }
      if (signedIn && (path == '/signin' || path == '/signup' || path == '/welcome')) {
        final from = state.uri.queryParameters['from'];
        return (from != null && from.startsWith('/') && !_public.contains(from))
            ? from
            : '/team';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', redirect: (_, _) => '/team'),
      GoRoute(path: '/welcome', builder: (_, _) => const WelcomeScreen()),
      GoRoute(
        path: '/signin',
        builder: (_, s) => SignInScreen(
          prefillEmail: s.uri.queryParameters['email'],
          created: s.uri.queryParameters['created'] == '1',
        ),
      ),
      GoRoute(path: '/signup', builder: (_, _) => const SignUpScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => MainShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/team', builder: (_, _) => const TeamScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/appointments',
              builder: (_, _) => const AppointmentsScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/social',
              builder: (_, s) => SocialScreen(tab: s.uri.queryParameters['tab']),
            ),
          ]),
        ],
      ),
      GoRoute(
        path: '/appointments/:id',
        builder: (_, s) => AppointmentDetailScreen(id: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/chats/:chatId',
        builder: (_, s) => ChatScreen(chatId: s.pathParameters['chatId']!),
      ),
      GoRoute(
        path: '/invites/:id',
        builder: (_, s) => InviteDetailScreen(id: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/notifications',
        builder: (_, _) => const NotificationsScreen(),
      ),
    ],
  );
  AppToast.tabBarVisible = () => _tabs.contains(
      router.routerDelegate.currentConfiguration.uri.path);
  return router;
});

const _tabs = {'/team', '/appointments', '/profile', '/social'};

class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(Stream<User?> s, ValueListenable<bool> suppress) : _suppress = suppress {
    _sub = s.listen((_) => notifyListeners());
    _suppress.addListener(notifyListeners);
  }
  late final StreamSubscription<User?> _sub;
  final ValueListenable<bool> _suppress;

  @override
  void dispose() {
    _sub.cancel();
    _suppress.removeListener(notifyListeners);
    super.dispose();
  }
}

/// Geri: yığında önceki ekran varsa ona, yoksa [fallback] rotasına.
void goBack(BuildContext context, String fallback) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(fallback);
  }
}
