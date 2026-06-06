// Modelos de dados para o Dashboard "Hoje" e mini-semana.

class TodayWorkout {
  final String id;
  final String name; // ex.: "PUSH A"
  final List<String> groups; // ex.: ["Peito", "Ombro", "Tríceps"]
  final int exerciseCount;
  final int estimatedMinutes;
  final double totalVolumeKg; // kg totais; UI divide por 1000 para exibir em t
  final bool isDone;

  const TodayWorkout({
    required this.id,
    required this.name,
    required this.groups,
    required this.exerciseCount,
    required this.estimatedMinutes,
    required this.totalVolumeKg,
    required this.isDone,
  });
}

class WeekDay {
  final String abbr; // 'S','T','Q','Q','S','S','D'
  final int dayNumber; // dia do mês (1–31)
  final bool isToday;
  final bool isRest; // true se não há treino atribuído neste dia
  final bool isDone;
  final String? workoutName;

  const WeekDay({
    required this.abbr,
    required this.dayNumber,
    required this.isToday,
    required this.isRest,
    required this.isDone,
    this.workoutName,
  });
}

class LastPr {
  final String exerciseName;
  final double weightKg;
  final int reps;
  final DateTime doneAt;

  const LastPr({
    required this.exerciseName,
    required this.weightKg,
    required this.reps,
    required this.doneAt,
  });
}
