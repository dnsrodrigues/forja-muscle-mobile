// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'router/app_router.dart';
import 'theme/accent_theme.dart';
import 'theme/forja_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
  runApp(const ProviderScope(child: ForjaApp()));
}

class ForjaApp extends ConsumerWidget {
  const ForjaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = ref.watch(accentProvider);
    return MaterialApp.router(
      title: 'FORJA',
      debugShowCheckedModeBanner: false,
      theme: forjaTheme(accent),
      routerConfig: appRouter,
    );
  }
}
