import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../today/today_providers.dart';
import 'week_models.dart';

/// Lista de 7 WeekWorkout (Seg a Dom da semana atual) com status de cada dia.
final weekWorkoutsProvider = FutureProvider<List<WeekWorkout>>((ref) async {
  final client = Supabase.instance.client;
  if (client.auth.currentUser == null) return [];

  final monday = thisWeekMonday();
  final today = DateTime.now();

  // Todos os workouts ativos com seus exercícios
  final workoutsData = await client
      .from('workouts')
      .select(
          'id, name, day_of_week, workout_exercises(sets, load_kg, reps, exercise_library(muscle_group))')
      .eq('is_active', true);

  final workoutByDow = <int, Map<String, dynamic>>{};
  for (final w in (workoutsData as List)) {
    workoutByDow[w['day_of_week'] as int] = w as Map<String, dynamic>;
  }

  // Logs desta semana
  final logs = await client
      .from('workout_logs')
      .select('workout_id, total_volume_kg, started_at')
      .gte('started_at', monday.toIso8601String());

  final logByWorkoutId = <String, Map<String, dynamic>>{};
  for (final log in (logs as List)) {
    logByWorkoutId[log['workout_id'] as String] = log as Map<String, dynamic>;
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

    final log = logByWorkoutId[workout['id'] as String];
    final exercises = (workout['workout_exercises'] as List?) ?? [];

    final groups = <String>{};
    for (final e in exercises) {
      final mg = (e['exercise_library'] as Map?)?['muscle_group'] as String?;
      if (mg != null && mg.isNotEmpty) groups.add(mg);
    }

    return WeekWorkout(
      dayAbbr: dayAbbrs[i],
      name: (workout['name'] as String).toUpperCase(),
      groups: groups.take(2).toList(),
      isToday: isToday,
      isDone: log != null,
      isRest: false,
      volumeKg: log != null
          ? (log['total_volume_kg'] as num?)?.toDouble()
          : null,
    );
  });
});
