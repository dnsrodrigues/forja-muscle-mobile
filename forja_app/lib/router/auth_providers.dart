import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/onboarding_prefs.dart';

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
