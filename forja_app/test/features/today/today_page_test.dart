import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/features/today/today_models.dart';
import 'package:forja_app/features/today/today_page.dart';
import 'package:forja_app/features/today/today_providers.dart';
import 'package:forja_app/router/auth_providers.dart';

const _workout = TodayWorkout(
  id: '1',
  name: 'PUSH A',
  groups: ['Peito', 'Ombro', 'Tríceps'],
  exerciseCount: 7,
  estimatedMinutes: 56,
  totalVolumeKg: 8400,
  isDone: false,
);

void main() {
  testWidgets('mostra hero card com nome do treino quando há treino',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserEmailProvider.overrideWithValue('test@example.com'),
          todayWorkoutProvider.overrideWith((_) async => _workout),
          weekStreakProvider.overrideWith((_) async => 5),
          weekVolumeProvider.overrideWith((_) async => 32000.0),
          miniWeekProvider.overrideWith((_) async => <WeekDay>[]),
          lastPrProvider.overrideWith((_) async => null),
        ],
        child: const MaterialApp(home: TodayPage()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('PUSH A'), findsOneWidget);
    expect(find.text('Peito · Ombro · Tríceps'), findsOneWidget);
    expect(find.text('COMEÇAR TREINO'), findsOneWidget);
  });

  testWidgets('mostra estado vazio quando não há treino', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserEmailProvider.overrideWithValue('test@example.com'),
          todayWorkoutProvider.overrideWith((_) async => null),
          weekStreakProvider.overrideWith((_) async => 0),
          weekVolumeProvider.overrideWith((_) async => 0.0),
          miniWeekProvider.overrideWith((_) async => <WeekDay>[]),
          lastPrProvider.overrideWith((_) async => null),
        ],
        child: const MaterialApp(home: TodayPage()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('NENHUM TREINO HOJE'), findsOneWidget);
  });

  testWidgets('mostra KPIs de streak e volume', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserEmailProvider.overrideWithValue('test@example.com'),
          todayWorkoutProvider.overrideWith((_) async => null),
          weekStreakProvider.overrideWith((_) async => 17),
          weekVolumeProvider.overrideWith((_) async => 32800.0),
          miniWeekProvider.overrideWith((_) async => <WeekDay>[]),
          lastPrProvider.overrideWith((_) async => null),
        ],
        child: const MaterialApp(home: TodayPage()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('17'), findsOneWidget); // streak value
    expect(find.text('32.8'), findsOneWidget); // volume em toneladas
  });
}
