import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/features/today/today_models.dart';

void main() {
  group('TodayWorkout', () {
    test('cria com todos os campos', () {
      const w = TodayWorkout(
        id: '1',
        name: 'PUSH A',
        groups: ['Peito', 'Ombro'],
        exerciseCount: 7,
        estimatedMinutes: 56,
        totalVolumeKg: 8400,
        isDone: false,
      );
      expect(w.name, 'PUSH A');
      expect(w.groups, ['Peito', 'Ombro']);
      expect(w.isDone, false);
      expect(w.totalVolumeKg, 8400);
    });
  });

  group('WeekDay', () {
    test('isRest true quando não há treino', () {
      const d = WeekDay(
        abbr: 'D',
        dayNumber: 22,
        isToday: false,
        isRest: true,
        isDone: false,
      );
      expect(d.isRest, true);
      expect(d.workoutName, isNull);
    });

    test('isToday correto', () {
      const d = WeekDay(
        abbr: 'Q',
        dayNumber: 21,
        isToday: true,
        isRest: false,
        isDone: false,
        workoutName: 'PUSH A',
      );
      expect(d.isToday, true);
      expect(d.workoutName, 'PUSH A');
    });
  });

  group('LastPr', () {
    test('cria com todos os campos', () {
      final pr = LastPr(
        exerciseName: 'Supino Reto',
        weightKg: 100,
        reps: 5,
        doneAt: DateTime(2026, 6, 4),
      );
      expect(pr.exerciseName, 'Supino Reto');
      expect(pr.weightKg, 100);
    });
  });
}
