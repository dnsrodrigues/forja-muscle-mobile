import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../features/auth/auth_page.dart';
import '../features/library/library_stub_page.dart';
import '../features/onboarding/onboarding_page.dart';
import '../features/profile/profile_page.dart';
import '../features/shell/shell_scaffold.dart';
import '../features/splash/splash_page.dart';
import '../features/today/today_page.dart';
import '../features/week/week_page.dart';
import '../services/onboarding_prefs.dart';
import 'go_router_refresh_stream.dart';
import 'redirect_logic.dart';

/// Valor inicial da flag de onboarding, carregado no main() e injetado via override.
final initialOnboardingSeenProvider = Provider<bool>((ref) => false);

/// Estado reativo de "onboarding já visto".
class OnboardingSeenNotifier extends Notifier<bool> {
  @override
  bool build() => ref.read(initialOnboardingSeenProvider);

  /// Marca como visto (estado + persistência).
  Future<void> markSeen() async {
    state = true;
    await OnboardingPrefs.markSeen();
  }
}

final onboardingSeenProvider =
    NotifierProvider<OnboardingSeenNotifier, bool>(OnboardingSeenNotifier.new);

/// E-mail do usuário logado (ou null). Pode ser sobrescrito em testes.
final currentUserEmailProvider = Provider<String?>(
  (ref) => Supabase.instance.client.auth.currentUser?.email,
);

/// O "porteiro": monta o GoRouter com ShellRoute para as 4 abas principais.
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(
      Supabase.instance.client.auth.onAuthStateChange,
    ),
    redirect: (context, state) {
      final loggedIn = Supabase.instance.client.auth.currentSession != null;
      final onboardingSeen = ref.read(onboardingSeenProvider);
      return resolveRedirect(
        loggedIn: loggedIn,
        onboardingSeen: onboardingSeen,
        location: state.matchedLocation,
      );
    },
    routes: [
      GoRoute(path: '/', builder: (c, s) => const SplashPage()),
      GoRoute(path: '/onboarding', builder: (c, s) => const OnboardingPage()),
      GoRoute(path: '/auth', builder: (c, s) => const AuthPage()),
      ShellRoute(
        builder: (context, state, child) {
          final tabIndex = switch (state.uri.path) {
            '/week' => 1,
            '/library' => 2,
            '/profile' => 3,
            _ => 0, // /today e fallback
          };
          return ShellScaffold(tabIndex: tabIndex, child: child);
        },
        routes: [
          GoRoute(path: '/today', builder: (c, s) => const TodayPage()),
          GoRoute(path: '/week', builder: (c, s) => const WeekPage()),
          GoRoute(
              path: '/library', builder: (c, s) => const LibraryStubPage()),
          GoRoute(path: '/profile', builder: (c, s) => const ProfilePage()),
        ],
      ),
    ],
  );
});
