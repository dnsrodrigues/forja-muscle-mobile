// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'router/auth_providers.dart';
import 'services/onboarding_prefs.dart';
import 'theme/accent_theme.dart';
import 'theme/forja_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
  final onboardingSeen = await OnboardingPrefs.isSeen();
  runApp(
    ProviderScope(
      overrides: [
        initialOnboardingSeenProvider.overrideWithValue(onboardingSeen),
      ],
      child: const ForjaApp(),
    ),
  );
}

class ForjaApp extends ConsumerWidget {
  const ForjaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = ref.watch(accentProvider);
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: 'FORJA',
      debugShowCheckedModeBanner: false,
      theme: forjaTheme(accent),
      routerConfig: router,
    );
  }
}
