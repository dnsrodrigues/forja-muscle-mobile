import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/forja_colors.dart';

/// Aba Exercícios — stub da Fase 3.
/// Biblioteca completa (busca, filtros, detalhe) chega na Fase 4.
class LibraryStubPage extends StatelessWidget {
  const LibraryStubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ForjaColors.bg0,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.fitness_center_rounded,
                size: 64,
                color: ForjaColors.textFaint,
              ),
              const SizedBox(height: 24),
              Text(
                'EXERCÍCIOS',
                style: GoogleFonts.bebasNeue(
                  fontSize: 32,
                  color: ForjaColors.text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Biblioteca completa com busca e filtros\nchega na Fase 4.',
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  color: ForjaColors.textFaint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
