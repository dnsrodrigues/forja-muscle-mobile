import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/widgets/forja_card.dart';
import '../../core/widgets/forja_kpi_tile.dart';
import '../../router/auth_providers.dart';
import '../../theme/accent_theme.dart';
import '../../theme/forja_colors.dart';
import 'today_models.dart';
import 'today_providers.dart';

/// Dashboard "Hoje" — tab principal do aluno.
class TodayPage extends ConsumerWidget {
  const TodayPage({super.key});

  static const _weekdays = [
    'SEG',
    'TER',
    'QUA',
    'QUI',
    'SEX',
    'SÁB',
    'DOM',
  ];
  static const _months = [
    'jan',
    'fev',
    'mar',
    'abr',
    'mai',
    'jun',
    'jul',
    'ago',
    'set',
    'out',
    'nov',
    'dez',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayWorkoutAsync = ref.watch(todayWorkoutProvider);
    final weekStreakAsync = ref.watch(weekStreakProvider);
    final weekVolumeAsync = ref.watch(weekVolumeProvider);
    final miniWeekAsync = ref.watch(miniWeekProvider);
    final lastPrAsync = ref.watch(lastPrProvider);
    final accent = ref.watch(accentProvider);

    final now = DateTime.now();
    final hour = now.hour;
    final greeting =
        hour < 12 ? 'BOM DIA' : hour < 18 ? 'BOA TARDE' : 'BOA NOITE';
    final email = ref.watch(currentUserEmailProvider) ?? '';
    final firstName = email.split('@').first.toUpperCase();
    final dateLabel =
        '${_weekdays[now.weekday - 1]} · ${now.day} ${_months[now.month - 1]}';

    return Scaffold(
      backgroundColor: ForjaColors.bg0,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            // ── Header ────────────────────────────────────────────────────
            _buildHeader(firstName, greeting, dateLabel, accent.accent),
            const SizedBox(height: 16),

            // ── Hero card ─────────────────────────────────────────────────
            todayWorkoutAsync.when(
              loading: () => _buildHeroSkeleton(),
              error: (_, _) => _buildHeroEmpty(),
              data: (w) => w == null
                  ? _buildHeroEmpty()
                  : _buildHeroCard(w, accent, context),
            ),
            const SizedBox(height: 14),

            // ── KPIs ──────────────────────────────────────────────────────
            Row(children: [
              Expanded(
                child: weekStreakAsync.when(
                  loading: () => const _SkeletonBox(height: 80),
                  error: (_, _) =>
                      const ForjaKpiTile(label: 'Streak', value: '–'),
                  data: (s) => ForjaKpiTile(
                      label: 'Streak', value: '$s', unit: 'dias'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: weekVolumeAsync.when(
                  loading: () => const _SkeletonBox(height: 80),
                  error: (_, _) =>
                      const ForjaKpiTile(label: 'Vol. semana', value: '–'),
                  data: (v) => ForjaKpiTile(
                    label: 'Vol. semana',
                    value: (v / 1000).toStringAsFixed(1),
                    unit: 't',
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 14),

            // ── Mini-semana ───────────────────────────────────────────────
            miniWeekAsync.when(
              loading: () => const _SkeletonBox(height: 90),
              error: (_, _) => const SizedBox.shrink(),
              data: (days) => days.isEmpty
                  ? const SizedBox.shrink()
                  : _buildMiniWeek(days, accent.accent),
            ),

            // ── Último PR ─────────────────────────────────────────────────
            lastPrAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
              data: (pr) => pr == null
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: _buildLastPrCard(pr, accent.accent),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Builders privados ────────────────────────────────────────────────────

  Widget _buildHeader(
      String name, String greeting, String dateLabel, Color accent) {
    final initials = name.isNotEmpty ? name[0] : 'A';
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateLabel.toUpperCase(),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  letterSpacing: 0.15,
                  color: ForjaColors.textDim,
                ),
              ),
              Text(
                '$greeting, $name',
                style: GoogleFonts.bebasNeue(
                  fontSize: 32,
                  height: 0.95,
                  color: ForjaColors.text,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ForjaColors.bg2,
            border: Border.all(color: accent, width: 1.5),
          ),
          child: Center(
            child: Text(
              initials,
              style: GoogleFonts.bebasNeue(fontSize: 20, color: accent),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSkeleton() => const _SkeletonBox(height: 200);

  Widget _buildHeroEmpty() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: ForjaColors.bg1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ForjaColors.hairline),
      ),
      child: Column(
        children: [
          const Icon(Icons.fitness_center_rounded,
              size: 48, color: ForjaColors.textFaint),
          const SizedBox(height: 16),
          Text(
            'NENHUM TREINO HOJE',
            style: GoogleFonts.bebasNeue(fontSize: 24, color: ForjaColors.text),
          ),
          const SizedBox(height: 8),
          Text(
            'Seu personal vai montar seu plano em breve.',
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
                fontSize: 13, color: ForjaColors.textDim),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(
      TodayWorkout w, AccentTheme accent, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: accent.accent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Stack(
        children: [
          // Número fantasma de fundo
          Positioned(
            right: -30,
            top: -30,
            child: Text(
              '${DateTime.now().weekday}',
              style: GoogleFonts.bebasNeue(
                fontSize: 220,
                height: 1,
                color: Colors.black.withValues(alpha: 0.08),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HOJE · ${_weekdays[DateTime.now().weekday - 1]}',
                style: GoogleFonts.bebasNeue(
                  fontSize: 12,
                  letterSpacing: 0.18,
                  color: Colors.black.withValues(alpha: 0.55),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                w.name,
                style: GoogleFonts.bebasNeue(
                  fontSize: 68,
                  height: 0.85,
                  color: accent.fg,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                w.groups.join(' · '),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  color: Colors.black.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 14),
              Row(children: [
                _metricMono('${w.exerciseCount}', 'exercícios'),
                const SizedBox(width: 14),
                _metricMono('${w.estimatedMinutes}', 'min'),
                const SizedBox(width: 14),
                _metricMono(
                  (w.totalVolumeKg / 1000).toStringAsFixed(1),
                  't vol.',
                ),
              ]),
              const SizedBox(height: 16),
              w.isDone
                  ? _buildDoneBadge()
                  : SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: accent.accent,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () =>
                            ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Execução de treino chega na Fase 5 💪'),
                            duration: Duration(seconds: 2),
                          ),
                        ),
                        icon:
                            const Icon(Icons.play_arrow_rounded, size: 16),
                        label: const Text('COMEÇAR TREINO'),
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricMono(String value, String label) {
    return RichText(
      text: TextSpan(children: [
        TextSpan(
          text: '$value ',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black.withValues(alpha: 0.85),
          ),
        ),
        TextSpan(
          text: label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 12,
            color: Colors.black.withValues(alpha: 0.7),
          ),
        ),
      ]),
    );
  }

  Widget _buildDoneBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_rounded, size: 16, color: Colors.black87),
          const SizedBox(width: 8),
          Text(
            'TREINO CONCLUÍDO',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniWeek(List<WeekDay> days, Color accent) {
    return ForjaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ESTA SEMANA',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.15,
              color: ForjaColors.textDim,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: days.map((day) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(
                      vertical: 10, horizontal: 2),
                  decoration: BoxDecoration(
                    color: day.isToday
                        ? accent
                        : day.isRest
                            ? Colors.transparent
                            : ForjaColors.bg2,
                    borderRadius: BorderRadius.circular(6),
                    border: day.isRest
                        ? Border.all(color: ForjaColors.border)
                        : null,
                  ),
                  child: Column(
                    children: [
                      Text(
                        day.abbr,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 9,
                          letterSpacing: 0.1,
                          color: day.isToday
                              ? Colors.black.withValues(alpha: 0.6)
                              : ForjaColors.textFaint,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        day.isDone
                            ? '✓'
                            : day.isRest
                                ? '—'
                                : '${day.dayNumber}',
                        style: GoogleFonts.bebasNeue(
                          fontSize: 18,
                          height: 1,
                          color: day.isToday
                              ? Colors.black87
                              : day.isRest
                                  ? ForjaColors.textFaint
                                  : ForjaColors.text,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLastPrCard(LastPr pr, Color accent) {
    final daysAgo = DateTime.now().difference(pr.doneAt).inDays;
    final daysStr = daysAgo == 0
        ? 'hoje'
        : daysAgo == 1
            ? 'há 1 dia'
            : 'há $daysAgo dias';
    final weightStr = pr.weightKg % 1 == 0
        ? '${pr.weightKg.toInt()}'
        : pr.weightKg.toStringAsFixed(1);

    return ForjaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ÚLTIMO PR',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.15,
              color: ForjaColors.textDim,
            ),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: ForjaColors.bg2,
                shape: BoxShape.circle,
              ),
              child:
                  Icon(Icons.emoji_events_rounded, color: accent, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pr.exerciseName,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ForjaColors.text,
                    ),
                  ),
                  Text(
                    daysStr,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      color: ForjaColors.textDim,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${weightStr}kg×${pr.reps}',
              style: GoogleFonts.bebasNeue(
                fontSize: 24,
                height: 0.95,
                color: accent,
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

/// Caixa cinza de loading (skeleton).
class _SkeletonBox extends StatelessWidget {
  final double height;
  const _SkeletonBox({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: ForjaColors.bg2,
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }
}
