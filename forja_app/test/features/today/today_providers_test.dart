import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/features/today/today_models.dart';
import 'package:forja_app/features/today/today_providers.dart';

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

  group('dartWeekdayToPostgresDow', () {
    test('segunda (1) → 1', () => expect(dartWeekdayToPostgresDow(1), 1));
    test('terça (2) → 2', () => expect(dartWeekdayToPostgresDow(2), 2));
    test('domingo (7) → 0', () => expect(dartWeekdayToPostgresDow(7), 0));
    test('sábado (6) → 6', () => expect(dartWeekdayToPostgresDow(6), 6));
  });

  group('calculateStreak', () {
    test('retorna 0 com lista vazia', () {
      expect(calculateStreak([]), 0);
    });

    test('retorna 1 com apenas hoje', () {
      final today = dateToStr(DateTime.now());
      expect(calculateStreak([today]), 1);
    });

    test('conta 3 dias consecutivos incluindo hoje', () {
      final now = DateTime.now();
      final dates = [0, 1, 2]
          .map((d) => dateToStr(now.subtract(Duration(days: d))))
          .toList();
      expect(calculateStreak(dates), 3);
    });

    test('quebra na lacuna', () {
      final now = DateTime.now();
      // hoje e anteontem, mas sem ontem → streak = 1
      final dates = [
        dateToStr(now),
        dateToStr(now.subtract(const Duration(days: 2))),
      ];
      expect(calculateStreak(dates), 1);
    });

    test('conta de ontem se hoje não tem log', () {
      final now = DateTime.now();
      final dates = [
        dateToStr(now.subtract(const Duration(days: 1))),
        dateToStr(now.subtract(const Duration(days: 2))),
      ];
      expect(calculateStreak(dates), 2);
    });
  });

  group('thisWeekMonday', () {
    test('retorna uma segunda-feira', () {
      expect(thisWeekMonday().weekday, DateTime.monday);
    });
  });
}
