import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/features/week/week_models.dart';
import 'package:forja_app/features/week/week_page.dart';
import 'package:forja_app/features/week/week_providers.dart';

final _mockWeek = [
  const WeekWorkout(
      dayAbbr: 'SEG',
      name: 'PULL A',
      groups: ['Costas'],
      isToday: false,
      isDone: true,
      isRest: false,
      volumeKg: 6800),
  const WeekWorkout(
      dayAbbr: 'TER',
      name: 'LEGS A',
      groups: ['Quadríceps'],
      isToday: false,
      isDone: false,
      isRest: false),
  const WeekWorkout(
      dayAbbr: 'QUA',
      name: 'DESCANSO',
      groups: [],
      isToday: false,
      isDone: false,
      isRest: true),
  const WeekWorkout(
      dayAbbr: 'QUI',
      name: 'PUSH A',
      groups: ['Peito'],
      isToday: true,
      isDone: false,
      isRest: false),
  const WeekWorkout(
      dayAbbr: 'SEX',
      name: 'PULL B',
      groups: ['Costas'],
      isToday: false,
      isDone: false,
      isRest: false),
  const WeekWorkout(
      dayAbbr: 'SÁB',
      name: 'LEGS B',
      groups: ['Posterior'],
      isToday: false,
      isDone: false,
      isRest: false),
  const WeekWorkout(
      dayAbbr: 'DOM',
      name: 'DESCANSO',
      groups: [],
      isToday: false,
      isDone: false,
      isRest: true),
];

void main() {
  testWidgets('WeekPage exibe os 7 dias', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          weekWorkoutsProvider.overrideWith((_) async => _mockWeek),
        ],
        child: const MaterialApp(home: WeekPage()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('PULL A'), findsOneWidget);
    expect(find.text('PUSH A'), findsOneWidget);
    expect(find.text('DESCANSO'), findsWidgets); // 2 dias de descanso
    expect(find.text('SEG'), findsOneWidget);
    expect(find.text('QUI'), findsOneWidget);
  });

  testWidgets('dia de hoje tem botão play', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          weekWorkoutsProvider.overrideWith((_) async => _mockWeek),
        ],
        child: const MaterialApp(home: WeekPage()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // QUI é hoje (isToday: true) — deve exibir o botão play
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
  });
}
