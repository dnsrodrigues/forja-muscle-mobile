import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../features/auth/auth_page.dart';
import '../features/home/home_placeholder_page.dart';
import '../features/onboarding/onboarding_page.dart';
import '../features/splash/splash_page.dart';
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

/// O "porteiro": monta o GoRouter, reage a login/logout e aplica o redirect.
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
      GoRoute(path: '/home', builder: (c, s) => const HomePlaceholderPage()),
    ],
  );
});
