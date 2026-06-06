import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/accent_theme.dart';
import '../../theme/forja_colors.dart';
import 'week_models.dart';
import 'week_providers.dart';

/// Aba "Semana" — lista os 7 dias com status e nome do treino.
class WeekPage extends ConsumerWidget {
  const WeekPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekAsync = ref.watch(weekWorkoutsProvider);
    final accent = ref.watch(accentProvider);

    return Scaffold(
      backgroundColor: ForjaColors.bg0,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CICLO ATUAL',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11,
                            letterSpacing: 0.15,
                            color: ForjaColors.textDim,
                          ),
                        ),
                        Text(
                          'SUA SEMANA',
                          style: GoogleFonts.bebasNeue(
                            fontSize: 32,
                            height: 0.95,
                            color: ForjaColors.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_rounded,
                        color: ForjaColors.textDim),
                    onPressed: () =>
                        ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Montar treino chega na Fase 8 (Personal) 🏋️'),
                        duration: Duration(seconds: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Lista
            Expanded(
              child: weekAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (e, _) => Center(
                  child: Text(
                    'Erro ao carregar semana',
                    style: GoogleFonts.spaceGrotesk(
                        color: ForjaColors.textDim),
                  ),
                ),
                data: (workouts) => workouts.isEmpty
                    ? _buildEmpty()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        itemCount: workouts.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, i) =>
                            _buildDayCard(workouts[i], accent, context),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_today_rounded,
                size: 48, color: ForjaColors.textFaint),
            const SizedBox(height: 16),
            Text(
              'Nenhum treino planejado.',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 14, color: ForjaColors.textDim),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCard(
      WeekWorkout w, AccentTheme accent, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: ForjaColors.bg1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: w.isToday ? accent.accent : ForjaColors.hairline,
          width: w.isToday ? 1.5 : 1,
        ),
      ),
      child: Opacity(
        opacity: w.isRest ? 0.6 : 1,
        child: Row(
          children: [
            // Dia
            SizedBox(
              width: 40,
              child: Text(
                w.dayAbbr,
                style: GoogleFonts.bebasNeue(
                  fontSize: 20,
                  height: 1,
                  color: w.isToday ? accent.accent : ForjaColors.textDim,
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Nome + grupos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    w.name,
                    style: GoogleFonts.bebasNeue(
                      fontSize: 28,
                      height: 1,
                      color: ForjaColors.text,
                    ),
                  ),
                  if (w.groups.isNotEmpty)
                    Text(
                      w.groups.join(' · '),
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        color: ForjaColors.textDim,
                      ),
                    ),
                ],
              ),
            ),
            // Status
            if (w.isDone)
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: accent.accent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.check_rounded,
                    size: 16, color: Colors.black),
              )
            else if (w.isToday && !w.isRest)
              IconButton(
                icon: Icon(Icons.play_arrow_rounded, color: accent.accent),
                onPressed: () =>
                    ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Execução chega na Fase 5 💪'),
                    duration: Duration(seconds: 2),
                  ),
                ),
              )
            else if (w.volumeKg != null)
              Text(
                '${(w.volumeKg! / 1000).toStringAsFixed(1)}t',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: ForjaColors.textDim,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
