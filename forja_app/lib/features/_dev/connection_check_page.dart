// lib/features/_dev/connection_check_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Conta os exercícios no Supabase — prova de que a conexão funciona.
final exerciseCountProvider = FutureProvider<int>((ref) async {
  final rows = await Supabase.instance.client
      .from('exercise_library')
      .select('id');
  return (rows as List).length;
});

class ConnectionCheckPage extends ConsumerWidget {
  const ConnectionCheckPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(exerciseCountProvider);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('FORJA', style: Theme.of(context).textTheme.displayLarge),
              const SizedBox(height: 8),
              count.when(
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('Erro de conexão: $e',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center),
                data: (n) => Text('Conectado! $n exercícios no banco.',
                    style: Theme.of(context).textTheme.bodyLarge),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
