import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../today/today_providers.dart';
import 'week_models.dart';

/// Lista de 7 WeekWorkout (Seg a Dom da semana atual) com status de cada dia.
/// Usa queries planas (sem junções aninhadas) para máxima compatibilidade.
final weekWorkoutsProvider = FutureProvider<List<WeekWorkout>>((ref) async {
  final client = Supabase.instance.client;
  if (client.auth.currentUser == null) return [];

  final monday = thisWeekMonday();
  final today = DateTime.now();

  try {
    // Query simples: apenas colunas básicas de workouts
    final workoutsRaw = await client
        .from('workouts')
        .select('id, name, day_of_week');

    final workoutByDow = <int, Map<String, dynamic>>{};
    for (final w in (workoutsRaw as List)) {
      final dow = w['day_of_week'] as int?;
      if (dow != null) workoutByDow[dow] = w as Map<String, dynamic>;
    }

    // Logs desta semana: só workout_id e started_at
    List logsRaw = [];
    try {
      logsRaw = await client
          .from('workout_logs')
          .select('workout_id, started_at')
          .gte('started_at', monday.toIso8601String()) as List;
    } catch (_) {
      // Se workout_logs não existir ou falhar, continua sem logs
    }

    final logWorkoutIds = <String>{};
    for (final log in logsRaw) {
      final wid = log['workout_id'] as String?;
      if (wid != null) logWorkoutIds.add(wid);
    }

    const dayAbbrs = ['SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SÁB', 'DOM'];

    return List.generate(7, (i) {
      final day = monday.add(Duration(days: i));
      final dow = dartWeekdayToPostgresDow(day.weekday);
      final isToday = dateToStr(day) == dateToStr(today);
      final workout = workoutByDow[dow];

      if (workout == null) {
        return WeekWorkout(
          dayAbbr: dayAbbrs[i],
          name: 'DESCANSO',
          groups: [],
          isToday: isToday,
          isDone: false,
          isRest: true,
        );
      }

      final workoutId = workout['id'] as String;
      final isDone = logWorkoutIds.contains(workoutId);

      return WeekWorkout(
        dayAbbr: dayAbbrs[i],
        name: (workout['name'] as String? ?? '').toUpperCase(),
        groups: [],
        isToday: isToday,
        isDone: isDone,
        isRest: false,
      );
    });
  } catch (e) {
    // Em caso de erro total, retorna semana vazia (não erro)
    const dayAbbrs = ['SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SÁB', 'DOM'];
    return List.generate(7, (i) {
      final day = monday.add(Duration(days: i));
      return WeekWorkout(
        dayAbbr: dayAbbrs[i],
        name: 'SEM DADOS',
        groups: [],
        isToday: dateToStr(day) == dateToStr(today),
        isDone: false,
        isRest: false,
      );
    });
  }
});
