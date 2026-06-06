import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../router/auth_providers.dart';
import '../../theme/accent_theme.dart';
import '../../theme/forja_colors.dart';
import '../auth/auth_controller.dart';

/// Aba Perfil — versão parcial da Fase 3.
/// Exibe o e-mail do usuário e o botão de logout.
/// Perfil completo (dados, KPIs, preferências) chega na Fase 7.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = ref.watch(currentUserEmailProvider) ?? '';
    final accent = ref.watch(accentProvider);
    final initials = email.isNotEmpty ? email[0].toUpperCase() : 'A';

    ref.listen(authControllerProvider, (_, state) {
      if (state is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.error.toString())),
        );
      }
    });

    return Scaffold(
      backgroundColor: ForjaColors.bg0,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              // Avatar
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ForjaColors.bg2,
                  border: Border.all(color: accent.accent, width: 2),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: GoogleFonts.bebasNeue(
                      fontSize: 40,
                      color: accent.accent,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                email,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  color: ForjaColors.textDim,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Perfil completo chega na Fase 7',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  color: ForjaColors.textFaint,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed:
                      ref.read(authControllerProvider.notifier).signOut,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ForjaColors.danger,
                    side: const BorderSide(
                      color: ForjaColors.danger,
                      width: 1,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    'SAIR DA CONTA',
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
