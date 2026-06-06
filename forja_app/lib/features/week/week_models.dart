/// Modelo de dado para a aba Semana.

class WeekWorkout {
  final String dayAbbr; // 'SEG','TER','QUA','QUI','SEX','SÁB','DOM'
  final String name; // ex.: "PULL A" ou "DESCANSO"
  final List<String> groups; // grupos musculares
  final bool isToday;
  final bool isDone;
  final bool isRest;
  final double? volumeKg; // null se futuro ou descanso

  const WeekWorkout({
    required this.dayAbbr,
    required this.name,
    required this.groups,
    required this.isToday,
    required this.isDone,
    required this.isRest,
    this.volumeKg,
  });
}
