import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'today_models.dart';

// ─── Helpers puros (públicos para serem testáveis) ────────────────────────────

/// Converte o weekday do Dart (1=Seg…7=Dom) para o DOW do Postgres (0=Dom…6=Sáb).
int dartWeekdayToPostgresDow(int dartWeekday) => dartWeekday % 7;

/// Formata um DateTime como "YYYY-MM-DD".
String dateToStr(DateTime d) => d.toIso8601String().substring(0, 10);

/// Retorna a segunda-feira da semana atual.
DateTime thisWeekMonday() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day)
      .subtract(Duration(days: now.weekday - 1));
}

/// Calcula a sequência de treinos consecutivos a partir de uma lista de datas
/// no formato "YYYY-MM-DD". Não quebra o streak se hoje ainda não tem log.
int calculateStreak(List<String> doneDateStrings) {
  if (doneDateStrings.isEmpty) return 0;
  final done = doneDateStrings.toSet();
  var day = DateTime.now();
  // Se hoje ainda não tem log, começa a contar de ontem.
  if (!done.contains(dateToStr(day))) {
    day = day.subtract(const Duration(days: 1));
  }
  int streak = 0;
  while (done.contains(dateToStr(day))) {
    streak++;
    day = day.subtract(const Duration(days: 1));
  }
  return streak;
}

// ─── Providers ────────────────────────────────────────────────────────────────

/// Treino do dia atual (null se não há treino atribuído).
/// Usa query plana, sem junções aninhadas.
final todayWorkoutProvider = FutureProvider<TodayWorkout?>((ref) async {
  final client = Supabase.instance.client;
  if (client.auth.currentUser == null) return null;

  final todayDow = dartWeekdayToPostgresDow(DateTime.now().weekday);
  final todayStr = dateToStr(DateTime.now());

  try {
    // Query simples: apenas colunas básicas
    final workoutData = await client
        .from('workouts')
        .select('id, name')
        .eq('day_of_week', todayDow)
        .limit(1)
        .maybeSingle();

    if (workoutData == null) return null;

    // Verificar se já foi concluído hoje
    bool isDone = false;
    try {
      final logData = await client
          .from('workout_logs')
          .select('id')
          .eq('workout_id', workoutData['id'] as String)
          .gte('started_at', todayStr)
          .limit(1)
          .maybeSingle();
      isDone = logData != null;
    } catch (_) {
      // Se workout_logs não existir, assume não feito
    }

    // Contar exercícios (query separada, sem aninhamento)
    int exerciseCount = 0;
    try {
      final exercises = await client
          .from('workout_exercises')
          .select('id')
          .eq('workout_id', workoutData['id'] as String);
      exerciseCount = (exercises as List).length;
    } catch (_) {
      // Se workout_exercises não existir, usa 0
    }

    return TodayWorkout(
      id: workoutData['id'] as String,
      name: (workoutData['name'] as String? ?? '').toUpperCase(),
      groups: [], // grupos musculares chegam depois quando schema for confirmado
      exerciseCount: exerciseCount,
      estimatedMinutes: exerciseCount * 8,
      totalVolumeKg: 0,
      isDone: isDone,
    );
  } catch (_) {
    return null;
  }
});

/// Número de dias consecutivos de treino (streak).
final weekStreakProvider = FutureProvider<int>((ref) async {
  final client = Supabase.instance.client;
  if (client.auth.currentUser == null) return 0;

  try {
    final cutoff = DateTime.now().subtract(const Duration(days: 60));
    final logs = await client
        .from('workout_logs')
        .select('started_at')
        .gte('started_at', cutoff.toIso8601String())
        .order('started_at', ascending: false);

    final dates = (logs as List)
        .map((l) => (l['started_at'] as String).substring(0, 10))
        .toList();
    return calculateStreak(dates);
  } catch (_) {
    return 0;
  }
});

/// Volume total (kg) da semana atual (segunda a hoje).
final weekVolumeProvider = FutureProvider<double>((ref) async {
  final client = Supabase.instance.client;
  if (client.auth.currentUser == null) return 0;

  try {
    final monday = thisWeekMonday();
    final logs = await client
        .from('workout_logs')
        .select('total_volume_kg')
        .gte('started_at', monday.toIso8601String());

    double total = 0;
    for (final log in (logs as List)) {
      total += ((log['total_volume_kg'] as num?)?.toDouble() ?? 0);
    }
    return total;
  } catch (_) {
    return 0;
  }
});

/// Lista de 7 WeekDay para a mini-semana (Seg a Dom da semana atual).
final miniWeekProvider = FutureProvider<List<WeekDay>>((ref) async {
  final client = Supabase.instance.client;
  if (client.auth.currentUser == null) return _emptyWeek();

  try {
    final monday = thisWeekMonday();
    final today = DateTime.now();

    // Logs desta semana
    List logsRaw = [];
    try {
      logsRaw = await client
          .from('workout_logs')
          .select('started_at')
          .gte('started_at', monday.toIso8601String()) as List;
    } catch (_) {}

    final doneDays = <String>{};
    for (final log in logsRaw) {
      doneDays.add((log['started_at'] as String).substring(0, 10));
    }

    // Dias que têm treino (query simples, sem is_active)
    List workoutsRaw = [];
    try {
      workoutsRaw = await client
          .from('workouts')
          .select('day_of_week') as List;
    } catch (_) {}

    final trainDays = <int>{};
    for (final w in workoutsRaw) {
      final dow = w['day_of_week'] as int?;
      if (dow != null) trainDays.add(dow);
    }

    const abbrs = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];
    return List.generate(7, (i) {
      final day = monday.add(Duration(days: i));
      final dow = dartWeekdayToPostgresDow(day.weekday);
      final dateStr = dateToStr(day);
      final todayStr = dateToStr(today);
      return WeekDay(
        abbr: abbrs[i],
        dayNumber: day.day,
        isToday: dateStr == todayStr,
        isRest: trainDays.isNotEmpty && !trainDays.contains(dow),
        isDone: doneDays.contains(dateStr),
      );
    });
  } catch (_) {
    return _emptyWeek();
  }
});

List<WeekDay> _emptyWeek() {
  final monday = thisWeekMonday();
  const abbrs = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];
  return List.generate(7, (i) {
    final day = monday.add(Duration(days: i));
    return WeekDay(
      abbr: abbrs[i],
      dayNumber: day.day,
      isToday: false,
      isRest: true,
      isDone: false,
    );
  });
}

/// PR mais recente do usuário (null se não há nenhum).
final lastPrProvider = FutureProvider<LastPr?>((ref) async {
  final client = Supabase.instance.client;
  if (client.auth.currentUser == null) return null;

  try {
    final data = await client
        .from('exercise_logs')
        .select('weight_kg, reps, done_at, exercise_id')
        .eq('is_pr', true)
        .order('done_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (data == null) return null;

    // Busca o nome do exercício separadamente
    String exerciseName = 'Exercício';
    try {
      final exerciseData = await client
          .from('exercise_library')
          .select('name')
          .eq('id', data['exercise_id'] as String)
          .maybeSingle();
      if (exerciseData != null) {
        exerciseName = exerciseData['name'] as String? ?? 'Exercício';
      }
    } catch (_) {}

    return LastPr(
      exerciseName: exerciseName,
      weightKg: (data['weight_kg'] as num).toDouble(),
      reps: data['reps'] as int,
      doneAt: DateTime.parse(data['done_at'] as String),
    );
  } catch (_) {
    return null;
  }
});
