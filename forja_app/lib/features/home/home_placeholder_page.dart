import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../router/auth_providers.dart';
import '../../theme/forja_colors.dart';
import '../auth/auth_controller.dart';

/// Tela inicial PROVISÓRIA — comprova o login de ponta a ponta.
/// Será substituída pelo Dashboard "Hoje" + navegação na Fase 3.
class HomePlaceholderPage extends ConsumerWidget {
  const HomePlaceholderPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = ref.watch(currentUserEmailProvider) ?? 'sem e-mail';
    final accent = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: ForjaColors.bg0,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.bebasNeue(
                      fontSize: 72,
                      color: ForjaColors.text,
                    ),
                    children: [
                      const TextSpan(text: 'FORJA'),
                      TextSpan(text: '.', style: TextStyle(color: accent)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  email,
                  style: GoogleFonts.spaceGrotesk(color: ForjaColors.textDim),
                ),
                const SizedBox(height: 24),
                Text(
                  'O Dashboard chega na Fase 3.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceGrotesk(
                    color: ForjaColors.textFaint,
                  ),
                ),
                const SizedBox(height: 32),
                OutlinedButton(
                  onPressed: () =>
                      ref.read(authControllerProvider.notifier).signOut(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ForjaColors.danger,
                    side: const BorderSide(color: ForjaColors.danger),
                  ),
                  child: const Text('SAIR DA CONTA'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
