# FORJA Mobile — Fase 3 (Hoje + Semana): Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [x]`) syntax for tracking.

**Goal:** Substituir a tela provisória pelo Dashboard real (tab Hoje + tab Semana) com dados do Supabase, introduzindo a barra de abas com FAB central.

**Architecture:** ShellRoute do GoRouter envolve 4 tabs (Hoje, Semana, Exercícios-stub, Perfil). O ShellScaffold exibe BottomAppBar + FAB centralizado; cada tab é uma rota filha cuja UI o GoRouter injeta como `child`. Os dados vêm de FutureProviders (Riverpod) que consultam o Supabase; widgets recebem AsyncValue e exibem loading/erro/dados.

**Tech Stack:** Flutter 3.44 · Dart 3.x · flutter_riverpod 3.x · go_router 17.x · supabase_flutter 2.x · google_fonts 8.x (já no projeto).

**Spec:** `docs/superpowers/specs/2026-06-06-forja-mobile-fase-3-hoje-semana-design.md`

**Diretório de trabalho:** todos os caminhos relativos a `forja_app/`. Rodar `flutter` dentro de `forja_app/`.

---

## Mapa de arquivos

```
forja_app/
├── lib/
│   ├── router/
│   │   ├── redirect_logic.dart          [MOD] /home→/today; proteger shell routes
│   │   └── auth_providers.dart          [MOD] ShellRoute + 4 child routes; remover /home
│   ├── core/widgets/
│   │   ├── forja_card.dart              [NEW] container bg1+hairline+r14
│   │   └── forja_kpi_tile.dart          [NEW] label + valor Bebas + unidade
│   ├── features/
│   │   ├── shell/
│   │   │   └── shell_scaffold.dart      [NEW] BottomAppBar + FAB + _TabItem
│   │   ├── today/
│   │   │   ├── today_models.dart        [NEW] TodayWorkout, WeekDay, LastPr
│   │   │   ├── today_providers.dart     [NEW] 5 FutureProviders + helpers puros
│   │   │   └── today_page.dart          [NEW] UI do dashboard
│   │   ├── week/
│   │   │   ├── week_models.dart         [NEW] WeekWorkout
│   │   │   ├── week_providers.dart      [NEW] weekWorkoutsProvider
│   │   │   └── week_page.dart           [NEW] lista de 7 dias
│   │   ├── library/
│   │   │   └── library_stub_page.dart   [NEW] stub "Fase 4"
│   │   ├── profile/
│   │   │   └── profile_page.dart        [NEW] e-mail + sair (substitui placeholder)
│   │   └── home/
│   │       └── home_placeholder_page.dart [DEL]
└── test/
    ├── router/redirect_logic_test.dart  [MOD] atualizar /home→/today + shell routes
    ├── core/widgets/forja_card_test.dart          [NEW]
    ├── features/today/today_providers_test.dart   [NEW] helpers puros
    ├── features/today/today_page_test.dart        [NEW]
    ├── features/week/week_page_test.dart          [NEW]
    └── features/shell/shell_scaffold_test.dart    [NEW]
```

---

## Task 1: Branch + Modelos de dados

**Files:**
- Create: `lib/features/today/today_models.dart`
- Create: `lib/features/week/week_models.dart`
- Test: `test/features/today/today_providers_test.dart` (grupo "models")

- [x] **Step 1: Criar a branch**

```bash
git checkout master
git checkout -b fase-3-hoje-semana
```

- [x] **Step 2: Criar `lib/features/today/today_models.dart`**

```dart
/// Modelos de dados para o Dashboard "Hoje" e mini-semana.

class TodayWorkout {
  final String id;
  final String name;           // ex.: "PUSH A"
  final List<String> groups;   // ex.: ["Peito", "Ombro", "Tríceps"]
  final int exerciseCount;
  final int estimatedMinutes;
  final double totalVolumeKg;  // kg totais; UI divide por 1000 para exibir em t
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
  final String abbr;        // 'S','T','Q','Q','S','S','D'
  final int dayNumber;      // dia do mês (1–31)
  final bool isToday;
  final bool isRest;        // true se não há treino atribuído neste dia
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
```

- [x] **Step 3: Criar `lib/features/week/week_models.dart`**

```dart
/// Modelo de dado para a aba Semana.

class WeekWorkout {
  final String dayAbbr;      // 'SEG','TER','QUA','QUI','SEX','SÁB','DOM'
  final String name;         // ex.: "PULL A" ou "DESCANSO"
  final List<String> groups; // grupos musculares
  final bool isToday;
  final bool isDone;
  final bool isRest;
  final double? volumeKg;    // null se futuro ou descanso

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
```

- [x] **Step 4: Escrever o teste dos modelos**

Criar `test/features/today/today_providers_test.dart`:

```dart
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
```

- [x] **Step 5: Rodar o teste para verificar que passa**

Run: `flutter test test/features/today/today_providers_test.dart`
Expected: `All tests passed!`

- [x] **Step 6: Commit**

```bash
git add lib/features/today/today_models.dart lib/features/week/week_models.dart test/features/today/today_providers_test.dart
git commit -m "feat(fase3): modelos TodayWorkout, WeekDay, LastPr, WeekWorkout"
```

---

## Task 2: Widgets reutilizáveis (ForjaCard + ForjaKpiTile)

**Files:**
- Create: `lib/core/widgets/forja_card.dart`
- Create: `lib/core/widgets/forja_kpi_tile.dart`
- Test: `test/core/widgets/forja_card_test.dart`

- [x] **Step 1: Escrever o teste do ForjaCard**

Criar `test/core/widgets/forja_card_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/core/widgets/forja_card.dart';
import 'package:forja_app/theme/forja_colors.dart';

void main() {
  testWidgets('ForjaCard renderiza o filho e aplica bg1', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ForjaCard(child: Text('conteúdo')),
        ),
      ),
    );
    expect(find.text('conteúdo'), findsOneWidget);

    final container = tester.widget<Container>(
      find.ancestor(of: find.text('conteúdo'), matching: find.byType(Container)).first,
    );
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, ForjaColors.bg1);
    expect((decoration.borderRadius as BorderRadius).topLeft.x, 14);
  });

  testWidgets('ForjaCard aceita borderColor customizada', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ForjaCard(
            borderColor: ForjaColors.danger,
            child: Text('ok'),
          ),
        ),
      ),
    );
    final container = tester.widget<Container>(
      find.ancestor(of: find.text('ok'), matching: find.byType(Container)).first,
    );
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.border, isNotNull);
  });
}
```

- [x] **Step 2: Rodar o teste para verificar que FALHA**

Run: `flutter test test/core/widgets/forja_card_test.dart`
Expected: FAIL com `Could not find file 'package:forja_app/core/widgets/forja_card.dart'`

- [x] **Step 3: Criar `lib/core/widgets/forja_card.dart`**

```dart
import 'package:flutter/material.dart';
import '../../theme/forja_colors.dart';

/// Card padrão FORJA: fundo bg1, borda hairline, raio 14.
class ForjaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? borderColor;

  const ForjaCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: ForjaColors.bg1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor ?? ForjaColors.hairline),
      ),
      child: child,
    );
  }
}
```

- [x] **Step 4: Criar `lib/core/widgets/forja_kpi_tile.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/forja_colors.dart';

/// Tile de KPI: label pequeno + valor grande Bebas Neue + unidade opcional.
class ForjaKpiTile extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;

  const ForjaKpiTile({
    super.key,
    required this.label,
    required this.value,
    this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ForjaColors.bg1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ForjaColors.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.15,
              color: ForjaColors.textDim,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: GoogleFonts.bebasNeue(
                  fontSize: 38,
                  height: 0.95,
                  color: ForjaColors.text,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Text(
                  unit!,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    color: ForjaColors.textDim,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
```

- [x] **Step 5: Rodar o teste para verificar que passa**

Run: `flutter test test/core/widgets/forja_card_test.dart`
Expected: `All tests passed!`

- [x] **Step 6: Commit**

```bash
git add lib/core/widgets/forja_card.dart lib/core/widgets/forja_kpi_tile.dart test/core/widgets/forja_card_test.dart
git commit -m "feat(fase3): widgets ForjaCard e ForjaKpiTile"
```

---

## Task 3: Providers do Dashboard "Hoje"

**Files:**
- Create: `lib/features/today/today_providers.dart`
- Modify: `test/features/today/today_providers_test.dart` (adicionar grupo "helpers")

- [x] **Step 1: Adicionar testes dos helpers puros ao arquivo existente**

Abrir `test/features/today/today_providers_test.dart` e ADICIONAR ao final (antes do último `}`):

```dart
import 'package:forja_app/features/today/today_providers.dart';

// Adicionar DENTRO do main(), antes do último }:

  group('dartWeekdayToPostgresDow', () {
    test('segunda (1) → 1', () => expect(dartWeekdayToPostgresDow(1), 1));
    test('terça (2) → 2',   () => expect(dartWeekdayToPostgresDow(2), 2));
    test('domingo (7) → 0', () => expect(dartWeekdayToPostgresDow(7), 0));
    test('sábado (6) → 6',  () => expect(dartWeekdayToPostgresDow(6), 6));
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
```

O arquivo de teste completo ficará assim (com ambos os imports no topo):

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/features/today/today_models.dart';
import 'package:forja_app/features/today/today_providers.dart';

void main() {
  group('TodayWorkout', () { /* ... código existente ... */ });
  group('WeekDay',      () { /* ... código existente ... */ });
  group('LastPr',       () { /* ... código existente ... */ });

  group('dartWeekdayToPostgresDow', () { /* novos testes acima */ });
  group('calculateStreak',          () { /* novos testes acima */ });
  group('thisWeekMonday',           () { /* novos testes acima */ });
}
```

- [x] **Step 2: Rodar o teste para verificar que FALHA**

Run: `flutter test test/features/today/today_providers_test.dart`
Expected: FAIL com `Could not find 'package:forja_app/features/today/today_providers.dart'`

- [x] **Step 3: Criar `lib/features/today/today_providers.dart`**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'today_models.dart';

// ─── Helpers puros (públicos para serem testáveis) ───────────────────────────

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

// ─── Providers ───────────────────────────────────────────────────────────────

/// Treino do dia atual (null se não há treino atribuído).
final todayWorkoutProvider = FutureProvider<TodayWorkout?>((ref) async {
  final client = Supabase.instance.client;
  if (client.auth.currentUser == null) return null;

  final todayDow = dartWeekdayToPostgresDow(DateTime.now().weekday);
  final todayStr = dateToStr(DateTime.now());

  // Buscar o workout do dia
  final workoutData = await client
      .from('workouts')
      .select('id, name, workout_exercises(sets, load_kg, reps, exercise_library(muscle_group))')
      .eq('day_of_week', todayDow)
      .eq('is_active', true)
      .maybeSingle();

  if (workoutData == null) return null;

  // Verificar se já foi concluído hoje
  final logData = await client
      .from('workout_logs')
      .select('id')
      .eq('workout_id', workoutData['id'] as String)
      .gte('started_at', todayStr)
      .limit(1)
      .maybeSingle();

  final exercises = (workoutData['workout_exercises'] as List?) ?? [];

  // Grupos musculares únicos (máx. 3)
  final groups = <String>{};
  for (final e in exercises) {
    final mg = (e['exercise_library'] as Map?)?['muscle_group'] as String?;
    if (mg != null && mg.isNotEmpty) groups.add(mg);
  }

  // Volume estimado em kg (séries × reps × carga)
  double volume = 0;
  for (final e in exercises) {
    volume += ((e['sets'] as int? ?? 0) *
        (e['reps'] as int? ?? 0) *
        ((e['load_kg'] as num?)?.toDouble() ?? 0));
  }

  return TodayWorkout(
    id: workoutData['id'] as String,
    name: (workoutData['name'] as String).toUpperCase(),
    groups: groups.take(3).toList(),
    exerciseCount: exercises.length,
    estimatedMinutes: exercises.length * 8, // estimativa: 8 min por exercício
    totalVolumeKg: volume,
    isDone: logData != null,
  );
});

/// Número de dias consecutivos de treino (streak).
final weekStreakProvider = FutureProvider<int>((ref) async {
  final client = Supabase.instance.client;
  if (client.auth.currentUser == null) return 0;

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
});

/// Volume total (kg) da semana atual (segunda a hoje).
final weekVolumeProvider = FutureProvider<double>((ref) async {
  final client = Supabase.instance.client;
  if (client.auth.currentUser == null) return 0;

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
});

/// Lista de 7 WeekDay para a mini-semana (Seg a Dom da semana atual).
final miniWeekProvider = FutureProvider<List<WeekDay>>((ref) async {
  final client = Supabase.instance.client;
  if (client.auth.currentUser == null) return _emptyWeek();

  final monday = thisWeekMonday();
  final today = DateTime.now();

  // Logs concluídos nesta semana
  final logs = await client
      .from('workout_logs')
      .select('started_at')
      .gte('started_at', monday.toIso8601String());
  final doneDays = <String>{};
  for (final log in (logs as List)) {
    doneDays.add((log['started_at'] as String).substring(0, 10));
  }

  // Quais dias têm treino atribuído
  final workoutsData = await client
      .from('workouts')
      .select('day_of_week')
      .eq('is_active', true);
  final trainDays = <int>{};
  for (final w in (workoutsData as List)) {
    trainDays.add(w['day_of_week'] as int);
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
      isRest: !trainDays.contains(dow),
      isDone: doneDays.contains(dateStr),
    );
  });
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

  final data = await client
      .from('exercise_logs')
      .select('weight_kg, reps, done_at, exercise_library(name)')
      .eq('is_pr', true)
      .order('done_at', ascending: false)
      .limit(1)
      .maybeSingle();

  if (data == null) return null;

  return LastPr(
    exerciseName:
        (data['exercise_library'] as Map?)?['name'] as String? ?? 'Exercício',
    weightKg: (data['weight_kg'] as num).toDouble(),
    reps: data['reps'] as int,
    doneAt: DateTime.parse(data['done_at'] as String),
  );
});
```

- [x] **Step 4: Rodar o teste para verificar que passa**

Run: `flutter test test/features/today/today_providers_test.dart`
Expected: `All tests passed!`

- [x] **Step 5: Commit**

```bash
git add lib/features/today/today_providers.dart test/features/today/today_providers_test.dart
git commit -m "feat(fase3): providers do dashboard (treino do dia, streak, volume, mini-semana, PR)"
```

---

## Task 4: Provider da aba Semana

**Files:**
- Create: `lib/features/week/week_providers.dart`
- Test: `test/features/week/week_page_test.dart` (o widget test vai usar o provider; testado na Task 8)

- [x] **Step 1: Criar `lib/features/week/week_providers.dart`**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../today/today_providers.dart'; // reutiliza dateToStr, thisWeekMonday, dartWeekdayToPostgresDow
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
```

- [x] **Step 2: Commit**

```bash
git add lib/features/week/week_providers.dart lib/features/week/week_models.dart
git commit -m "feat(fase3): weekWorkoutsProvider para a aba Semana"
```

---

## Task 5: Shell scaffold (barra de abas + FAB)

**Files:**
- Create: `lib/features/shell/shell_scaffold.dart`
- Test: `test/features/shell/shell_scaffold_test.dart`

- [x] **Step 1: Escrever o teste do shell**

Criar `test/features/shell/shell_scaffold_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/features/shell/shell_scaffold.dart';

void main() {
  testWidgets('ShellScaffold exibe os 4 labels das abas', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: ShellScaffold(
            tabIndex: 0,
            child: const Text('conteúdo'),
          ),
        ),
      ),
    );
    expect(find.text('Hoje'), findsOneWidget);
    expect(find.text('Semana'), findsOneWidget);
    expect(find.text('Exercícios'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);
  });

  testWidgets('ShellScaffold exibe o filho (child)', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: ShellScaffold(
            tabIndex: 1,
            child: const Text('aba semana'),
          ),
        ),
      ),
    );
    expect(find.text('aba semana'), findsOneWidget);
  });
}
```

- [x] **Step 2: Rodar o teste para verificar que FALHA**

Run: `flutter test test/features/shell/shell_scaffold_test.dart`
Expected: FAIL com `Could not find 'package:forja_app/features/shell/shell_scaffold.dart'`

- [x] **Step 3: Criar `lib/features/shell/shell_scaffold.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/accent_theme.dart';
import '../../theme/forja_colors.dart';

/// Scaffold principal com BottomAppBar de 4 abas + FAB central.
/// Recebe [tabIndex] (0=Hoje, 1=Semana, 2=Exercícios, 3=Perfil) e [child]
/// vindo do ShellRoute do GoRouter.
class ShellScaffold extends ConsumerWidget {
  final int tabIndex;
  final Widget child;

  const ShellScaffold({
    super.key,
    required this.tabIndex,
    required this.child,
  });

  static const _routes = ['/today', '/week', '/library', '/profile'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = ref.watch(accentProvider);

    void onTabTap(int index) => context.go(_routes[index]);

    return Scaffold(
      backgroundColor: ForjaColors.bg0,
      body: child,
      bottomNavigationBar: BottomAppBar(
        color: ForjaColors.bg1,
        notchMargin: 6,
        shape: const CircularNotchRectangle(),
        height: 64,
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            _TabItem(
              icon: Icons.home_rounded,
              label: 'Hoje',
              index: 0,
              currentIndex: tabIndex,
              accent: accent.accent,
              onTap: () => onTabTap(0),
            ),
            _TabItem(
              icon: Icons.calendar_today_rounded,
              label: 'Semana',
              index: 1,
              currentIndex: tabIndex,
              accent: accent.accent,
              onTap: () => onTabTap(1),
            ),
            const SizedBox(width: 72), // espaço do FAB
            _TabItem(
              icon: Icons.fitness_center_rounded,
              label: 'Exercícios',
              index: 2,
              currentIndex: tabIndex,
              accent: accent.accent,
              onTap: () => onTabTap(2),
            ),
            _TabItem(
              icon: Icons.person_rounded,
              label: 'Perfil',
              index: 3,
              currentIndex: tabIndex,
              accent: accent.accent,
              onTap: () => onTabTap(3),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: accent.accent,
        foregroundColor: accent.fg,
        shape: const CircleBorder(),
        elevation: 4,
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Execução de treino chega na Fase 5 💪'),
            duration: Duration(seconds: 2),
          ),
        ),
        child: const Icon(Icons.play_arrow_rounded, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class _TabItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int currentIndex;
  final Color accent;
  final VoidCallback onTap;

  const _TabItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;
    final color = isActive ? accent : ForjaColors.textFaint;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [x] **Step 4: Rodar o teste para verificar que passa**

Run: `flutter test test/features/shell/shell_scaffold_test.dart`
Expected: `All tests passed!`

- [x] **Step 5: Commit**

```bash
git add lib/features/shell/shell_scaffold.dart test/features/shell/shell_scaffold_test.dart
git commit -m "feat(fase3): ShellScaffold com BottomAppBar 4 abas + FAB central"
```

---

## Task 6: Páginas stub (Perfil + Exercícios)

**Files:**
- Create: `lib/features/profile/profile_page.dart`
- Create: `lib/features/library/library_stub_page.dart`

> Sem testes dedicados: funcionalidade simples, verificada no smoke test.

- [x] **Step 1: Criar `lib/features/profile/profile_page.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../router/auth_providers.dart';
import '../../theme/accent_theme.dart';
import '../../theme/forja_colors.dart';
import '../auth/auth_controller.dart';

/// Aba Perfil — versão parcial da Fase 3.
/// Exibe o e-mail do usuário e o botão de logout.
/// Perfil completo (dados, KPIs, preferências) chega na Fase 7.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = ref.watch(currentUserEmailProvider) ?? '';
    final accent = ref.watch(accentProvider);
    final initials =
        email.isNotEmpty ? email[0].toUpperCase() : 'A';

    ref.listen(authControllerProvider, (_, state) {
      if (state is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.error.toString())),
        );
      }
    });

    return Scaffold(
      backgroundColor: ForjaColors.bg0,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              // Avatar
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ForjaColors.bg2,
                  border: Border.all(color: accent.accent, width: 2),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: GoogleFonts.bebasNeue(
                      fontSize: 40,
                      color: accent.accent,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                email,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  color: ForjaColors.textDim,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Perfil completo chega na Fase 7',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  color: ForjaColors.textFaint,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: ref.read(authControllerProvider.notifier).signOut,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ForjaColors.danger,
                    side: const BorderSide(
                      color: ForjaColors.danger,
                      width: 1,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('SAIR DA CONTA'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [x] **Step 2: Criar `lib/features/library/library_stub_page.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/forja_colors.dart';

/// Aba Exercícios — stub da Fase 3.
/// Biblioteca completa (busca, filtros, detalhe) chega na Fase 4.
class LibraryStubPage extends StatelessWidget {
  const LibraryStubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ForjaColors.bg0,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.fitness_center_rounded,
                size: 64,
                color: ForjaColors.textFaint,
              ),
              const SizedBox(height: 24),
              Text(
                'EXERCÍCIOS',
                style: GoogleFonts.bebasNeue(
                  fontSize: 32,
                  color: ForjaColors.text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Biblioteca completa com busca e filtros\nchega na Fase 4.',
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  color: ForjaColors.textFaint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [x] **Step 3: Commit**

```bash
git add lib/features/profile/profile_page.dart lib/features/library/library_stub_page.dart
git commit -m "feat(fase3): ProfilePage parcial + LibraryStubPage"
```

---

## Task 7: Tela "Hoje" (TodayPage)

**Files:**
- Create: `lib/features/today/today_page.dart`
- Test: `test/features/today/today_page_test.dart`

- [x] **Step 1: Escrever o teste da TodayPage**

Criar `test/features/today/today_page_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/features/today/today_models.dart';
import 'package:forja_app/features/today/today_page.dart';
import 'package:forja_app/features/today/today_providers.dart';

const _workout = TodayWorkout(
  id: '1',
  name: 'PUSH A',
  groups: ['Peito', 'Ombro', 'Tríceps'],
  exerciseCount: 7,
  estimatedMinutes: 56,
  totalVolumeKg: 8400,
  isDone: false,
);

Widget _wrap(Widget child, {List<Override> overrides = const []}) =>
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(home: child),
    );

void main() {
  testWidgets('mostra hero card com nome do treino quando há treino',
      (tester) async {
    await tester.pumpWidget(_wrap(
      const TodayPage(),
      overrides: [
        todayWorkoutProvider.overrideWith((_) async => _workout),
        weekStreakProvider.overrideWith((_) async => 5),
        weekVolumeProvider.overrideWith((_) async => 32000),
        miniWeekProvider.overrideWith((_) async => []),
        lastPrProvider.overrideWith((_) async => null),
      ],
    ));
    await tester.pump(); // dispara futures
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('PUSH A'), findsOneWidget);
    expect(find.text('Peito · Ombro · Tríceps'), findsOneWidget);
    expect(find.text('COMEÇAR TREINO'), findsOneWidget);
  });

  testWidgets('mostra estado vazio quando não há treino', (tester) async {
    await tester.pumpWidget(_wrap(
      const TodayPage(),
      overrides: [
        todayWorkoutProvider.overrideWith((_) async => null),
        weekStreakProvider.overrideWith((_) async => 0),
        weekVolumeProvider.overrideWith((_) async => 0),
        miniWeekProvider.overrideWith((_) async => []),
        lastPrProvider.overrideWith((_) async => null),
      ],
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('NENHUM TREINO HOJE'), findsOneWidget);
  });

  testWidgets('mostra KPIs de streak e volume', (tester) async {
    await tester.pumpWidget(_wrap(
      const TodayPage(),
      overrides: [
        todayWorkoutProvider.overrideWith((_) async => null),
        weekStreakProvider.overrideWith((_) async => 17),
        weekVolumeProvider.overrideWith((_) async => 32800),
        miniWeekProvider.overrideWith((_) async => []),
        lastPrProvider.overrideWith((_) async => null),
      ],
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('17'), findsOneWidget);  // streak value
    expect(find.text('32.8'), findsOneWidget); // volume em toneladas
  });
}
```

- [x] **Step 2: Rodar o teste para verificar que FALHA**

Run: `flutter test test/features/today/today_page_test.dart`
Expected: FAIL com `Could not find 'package:forja_app/features/today/today_page.dart'`

- [x] **Step 3: Criar `lib/features/today/today_page.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/widgets/forja_card.dart';
import '../../core/widgets/forja_kpi_tile.dart';
import '../../theme/accent_theme.dart';
import '../../theme/forja_colors.dart';
import 'today_models.dart';
import 'today_providers.dart';

/// Dashboard "Hoje" — tab principal do aluno.
class TodayPage extends ConsumerWidget {
  const TodayPage({super.key});

  // Rótulos de dias da semana (index 0 = segunda, alinhado com DateTime.weekday-1)
  static const _weekdays = ['SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SÁB', 'DOM'];
  static const _months = [
    'jan','fev','mar','abr','mai','jun','jul','ago','set','out','nov','dez'
  ];
  static const _miniAbbrs = ['S','T','Q','Q','S','S','D'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayWorkoutAsync = ref.watch(todayWorkoutProvider);
    final weekStreakAsync   = ref.watch(weekStreakProvider);
    final weekVolumeAsync   = ref.watch(weekVolumeProvider);
    final miniWeekAsync     = ref.watch(miniWeekProvider);
    final lastPrAsync       = ref.watch(lastPrProvider);
    final accent            = ref.watch(accentProvider);

    final now       = DateTime.now();
    final hour      = now.hour;
    final greeting  = hour < 12 ? 'BOM DIA' : hour < 18 ? 'BOA TARDE' : 'BOA NOITE';
    final email     = Supabase.instance.client.auth.currentUser?.email ?? '';
    final firstName = email.split('@').first.toUpperCase();
    final dateLabel =
        '${_weekdays[now.weekday - 1]} · ${now.day} ${_months[now.month - 1]}';

    return Scaffold(
      backgroundColor: ForjaColors.bg0,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            // ── Header ──────────────────────────────────────────────────────
            _buildHeader(firstName, greeting, dateLabel, accent.accent),
            const SizedBox(height: 16),

            // ── Hero card ───────────────────────────────────────────────────
            todayWorkoutAsync.when(
              loading: () => _buildHeroSkeleton(),
              error: (_, __) => _buildHeroEmpty(),
              data: (w) => w == null
                  ? _buildHeroEmpty()
                  : _buildHeroCard(w, accent, context),
            ),
            const SizedBox(height: 14),

            // ── KPIs ─────────────────────────────────────────────────────────
            Row(children: [
              Expanded(
                child: weekStreakAsync.when(
                  loading: () => const _SkeletonBox(height: 80),
                  error: (_, __) =>
                      const ForjaKpiTile(label: 'Streak', value: '–'),
                  data: (s) =>
                      ForjaKpiTile(label: 'Streak', value: '$s', unit: 'dias'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: weekVolumeAsync.when(
                  loading: () => const _SkeletonBox(height: 80),
                  error: (_, __) =>
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

            // ── Mini-semana ──────────────────────────────────────────────────
            miniWeekAsync.when(
              loading: () => const _SkeletonBox(height: 90),
              error: (_, __) => const SizedBox.shrink(),
              data: (days) => days.isEmpty
                  ? const SizedBox.shrink()
                  : _buildMiniWeek(days, accent.accent),
            ),

            // ── Último PR ────────────────────────────────────────────────────
            lastPrAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
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

  // ─── Builders privados ──────────────────────────────────────────────────────

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
            style: GoogleFonts.bebasNeue(
                fontSize: 24, color: ForjaColors.text),
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
                        icon: const Icon(Icons.play_arrow_rounded,
                            size: 16),
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
              child: Icon(Icons.emoji_events_rounded,
                  color: accent, size: 20),
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
```

- [x] **Step 4: Rodar o teste para verificar que passa**

Run: `flutter test test/features/today/today_page_test.dart`
Expected: `All tests passed!`

- [x] **Step 5: Commit**

```bash
git add lib/features/today/today_page.dart test/features/today/today_page_test.dart
git commit -m "feat(fase3): TodayPage — dashboard com hero card, KPIs, mini-semana e último PR"
```

---

## Task 8: Tela "Semana" (WeekPage)

**Files:**
- Create: `lib/features/week/week_page.dart`
- Test: `test/features/week/week_page_test.dart`

- [x] **Step 1: Escrever o teste da WeekPage**

Criar `test/features/week/week_page_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/features/week/week_models.dart';
import 'package:forja_app/features/week/week_page.dart';
import 'package:forja_app/features/week/week_providers.dart';

final _mockWeek = [
  const WeekWorkout(dayAbbr: 'SEG', name: 'PULL A', groups: ['Costas'], isToday: false, isDone: true, isRest: false, volumeKg: 6800),
  const WeekWorkout(dayAbbr: 'TER', name: 'LEGS A', groups: ['Quadríceps'], isToday: false, isDone: false, isRest: false),
  const WeekWorkout(dayAbbr: 'QUA', name: 'DESCANSO', groups: [], isToday: false, isDone: false, isRest: true),
  const WeekWorkout(dayAbbr: 'QUI', name: 'PUSH A', groups: ['Peito'], isToday: true, isDone: false, isRest: false),
  const WeekWorkout(dayAbbr: 'SEX', name: 'PULL B', groups: ['Costas'], isToday: false, isDone: false, isRest: false),
  const WeekWorkout(dayAbbr: 'SÁB', name: 'LEGS B', groups: ['Posterior'], isToday: false, isDone: false, isRest: false),
  const WeekWorkout(dayAbbr: 'DOM', name: 'DESCANSO', groups: [], isToday: false, isDone: false, isRest: true),
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

  testWidgets('dia de hoje tem borda em accent', (tester) async {
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
```

- [x] **Step 2: Rodar o teste para verificar que FALHA**

Run: `flutter test test/features/week/week_page_test.dart`
Expected: FAIL com `Could not find 'package:forja_app/features/week/week_page.dart'`

- [x] **Step 3: Criar `lib/features/week/week_page.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/accent_theme.dart';
import '../../theme/forja_colors.dart';
import 'week_models.dart';
import 'week_providers.dart';

/// Aba "Semana" — lista os 7 dias com status e nome do treino.
class WeekPage extends ConsumerWidget {
  const WeekPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekAsync = ref.watch(weekWorkoutsProvider);
    final accent    = ref.watch(accentProvider);

    return Scaffold(
      backgroundColor: ForjaColors.bg0,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CICLO ATUAL',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11,
                            letterSpacing: 0.15,
                            color: ForjaColors.textDim,
                          ),
                        ),
                        Text(
                          'SUA SEMANA',
                          style: GoogleFonts.bebasNeue(
                            fontSize: 32,
                            height: 0.95,
                            color: ForjaColors.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_rounded,
                        color: ForjaColors.textDim),
                    onPressed: () =>
                        ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Montar treino chega na Fase 8 (Personal) 🏋️'),
                        duration: Duration(seconds: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Lista
            Expanded(
              child: weekAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (e, _) => Center(
                  child: Text(
                    'Erro ao carregar semana',
                    style: GoogleFonts.spaceGrotesk(
                        color: ForjaColors.textDim),
                  ),
                ),
                data: (workouts) => workouts.isEmpty
                    ? _buildEmpty()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        itemCount: workouts.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, i) =>
                            _buildDayCard(workouts[i], accent, context),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_today_rounded,
                size: 48, color: ForjaColors.textFaint),
            const SizedBox(height: 16),
            Text(
              'Nenhum treino planejado.',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 14, color: ForjaColors.textDim),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCard(
      WeekWorkout w, AccentTheme accent, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: ForjaColors.bg1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: w.isToday ? accent.accent : ForjaColors.hairline,
          width: w.isToday ? 1.5 : 1,
        ),
      ),
      child: Opacity(
        opacity: w.isRest ? 0.6 : 1,
        child: Row(
          children: [
            // Dia
            SizedBox(
              width: 40,
              child: Text(
                w.dayAbbr,
                style: GoogleFonts.bebasNeue(
                  fontSize: 20,
                  height: 1,
                  color: w.isToday ? accent.accent : ForjaColors.textDim,
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Nome + grupos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    w.name,
                    style: GoogleFonts.bebasNeue(
                      fontSize: 28,
                      height: 1,
                      color: ForjaColors.text,
                    ),
                  ),
                  if (w.groups.isNotEmpty)
                    Text(
                      w.groups.join(' · '),
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        color: ForjaColors.textDim,
                      ),
                    ),
                ],
              ),
            ),
            // Status
            if (w.isDone)
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: accent.accent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.check_rounded,
                    size: 16, color: Colors.black),
              )
            else if (w.isToday && !w.isRest)
              IconButton(
                icon: Icon(Icons.play_arrow_rounded, color: accent.accent),
                onPressed: () =>
                    ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Execução chega na Fase 5 💪'),
                    duration: Duration(seconds: 2),
                  ),
                ),
              )
            else if (w.volumeKg != null)
              Text(
                '${(w.volumeKg! / 1000).toStringAsFixed(1)}t',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: ForjaColors.textDim,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
```

- [x] **Step 4: Rodar o teste para verificar que passa**

Run: `flutter test test/features/week/week_page_test.dart`
Expected: `All tests passed!`

- [x] **Step 5: Commit**

```bash
git add lib/features/week/week_page.dart test/features/week/week_page_test.dart
git commit -m "feat(fase3): WeekPage — lista de 7 dias com status"
```

---

## Task 9: Atualizar o router + redirect + limpeza

**Files:**
- Modify: `lib/router/redirect_logic.dart`
- Modify: `lib/router/auth_providers.dart`
- Modify: `test/router/redirect_logic_test.dart`
- Delete: `lib/features/home/home_placeholder_page.dart`
- Delete: `test/features/home/home_placeholder_test.dart`

- [x] **Step 1: Atualizar `lib/router/redirect_logic.dart`**

Substituir todo o conteúdo por:

```dart
/// Rotas que fazem parte do shell (requerem login).
const _shellRoutes = {'/today', '/week', '/library', '/profile'};

/// Decide para onde o "porteiro" deve mandar o usuário.
///
/// Retorna a rota de destino, ou `null` se já está no lugar certo.
/// Função PURA — sem dependências externas — para ser facilmente testável.
String? resolveRedirect({
  required bool loggedIn,
  required bool onboardingSeen,
  required String location,
}) {
  final inOnboarding = location == '/onboarding';
  final inAuth       = location == '/auth';

  if (loggedIn) {
    // Usuário logado não deve ver splash, onboarding nem login.
    if (location == '/' || inOnboarding || inAuth || location == '/home') {
      return '/today';
    }
    return null; // /today, /week, /library, /profile → OK
  }

  // A partir daqui: NÃO está logado.
  // Proteger as rotas do shell.
  if (_shellRoutes.contains(location) || location == '/home') {
    return onboardingSeen ? '/auth' : '/onboarding';
  }

  if (!onboardingSeen) {
    return inOnboarding ? null : '/onboarding';
  }

  // Onboarding já visto e não logado → tela de login.
  return inAuth ? null : '/auth';
}
```

- [x] **Step 2: Atualizar os testes do redirect_logic**

Substituir o conteúdo de `test/router/redirect_logic_test.dart` por:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/router/redirect_logic.dart';

void main() {
  group('resolveRedirect', () {
    // ── Logado ──────────────────────────────────────────────────────────────
    test('logado em "/" vai para /today', () {
      expect(
        resolveRedirect(loggedIn: true, onboardingSeen: true, location: '/'),
        '/today',
      );
    });

    test('logado já em /today permanece (null)', () {
      expect(
        resolveRedirect(loggedIn: true, onboardingSeen: true, location: '/today'),
        isNull,
      );
    });

    test('logado já em /week permanece (null)', () {
      expect(
        resolveRedirect(loggedIn: true, onboardingSeen: true, location: '/week'),
        isNull,
      );
    });

    test('logado em /auth é mandado para /today', () {
      expect(
        resolveRedirect(loggedIn: true, onboardingSeen: true, location: '/auth'),
        '/today',
      );
    });

    test('logado em /home (legado) é mandado para /today', () {
      expect(
        resolveRedirect(loggedIn: true, onboardingSeen: true, location: '/home'),
        '/today',
      );
    });

    // ── Deslogado ────────────────────────────────────────────────────────────
    test('deslogado sem onboarding em "/" vai para /onboarding', () {
      expect(
        resolveRedirect(loggedIn: false, onboardingSeen: false, location: '/'),
        '/onboarding',
      );
    });

    test('deslogado sem onboarding já em /onboarding permanece (null)', () {
      expect(
        resolveRedirect(loggedIn: false, onboardingSeen: false, location: '/onboarding'),
        isNull,
      );
    });

    test('deslogado sem onboarding tentando /auth volta para /onboarding', () {
      expect(
        resolveRedirect(loggedIn: false, onboardingSeen: false, location: '/auth'),
        '/onboarding',
      );
    });

    test('deslogado com onboarding visto em "/" vai para /auth', () {
      expect(
        resolveRedirect(loggedIn: false, onboardingSeen: true, location: '/'),
        '/auth',
      );
    });

    test('deslogado com onboarding visto já em /auth permanece (null)', () {
      expect(
        resolveRedirect(loggedIn: false, onboardingSeen: true, location: '/auth'),
        isNull,
      );
    });

    test('deslogado tentando /today é mandado para /auth', () {
      expect(
        resolveRedirect(loggedIn: false, onboardingSeen: true, location: '/today'),
        '/auth',
      );
    });

    test('deslogado tentando /week é mandado para /auth', () {
      expect(
        resolveRedirect(loggedIn: false, onboardingSeen: true, location: '/week'),
        '/auth',
      );
    });

    test('deslogado tentando /home (legado) é mandado para /auth', () {
      expect(
        resolveRedirect(loggedIn: false, onboardingSeen: true, location: '/home'),
        '/auth',
      );
    });
  });
}
```

- [x] **Step 3: Atualizar `lib/router/auth_providers.dart` — adicionar ShellRoute e remover /home**

Substituir todo o conteúdo por:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../features/auth/auth_page.dart';
import '../features/library/library_stub_page.dart';
import '../features/onboarding/onboarding_page.dart';
import '../features/profile/profile_page.dart';
import '../features/shell/shell_scaffold.dart';
import '../features/splash/splash_page.dart';
import '../features/today/today_page.dart';
import '../features/week/week_page.dart';
import '../services/onboarding_prefs.dart';
import 'go_router_refresh_stream.dart';
import 'redirect_logic.dart';

/// Valor inicial da flag de onboarding, carregado no main() e injetado via override.
final initialOnboardingSeenProvider = Provider<bool>((ref) => false);

/// Estado reativo de "onboarding já visto".
class OnboardingSeenNotifier extends Notifier<bool> {
  @override
  bool build() => ref.read(initialOnboardingSeenProvider);

  /// Marca como visto (estado + persistência).
  Future<void> markSeen() async {
    state = true;
    await OnboardingPrefs.markSeen();
  }
}

final onboardingSeenProvider =
    NotifierProvider<OnboardingSeenNotifier, bool>(OnboardingSeenNotifier.new);

/// E-mail do usuário logado (ou null).
final currentUserEmailProvider = Provider<String?>(
  (ref) => Supabase.instance.client.auth.currentUser?.email,
);

/// O "porteiro": monta o GoRouter com ShellRoute para as 4 abas principais.
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(
      Supabase.instance.client.auth.onAuthStateChange,
    ),
    redirect: (context, state) {
      final loggedIn = Supabase.instance.client.auth.currentSession != null;
      final onboardingSeen = ref.read(onboardingSeenProvider);
      return resolveRedirect(
        loggedIn: loggedIn,
        onboardingSeen: onboardingSeen,
        location: state.uri.path,
      );
    },
    routes: [
      GoRoute(path: '/', builder: (c, s) => const SplashPage()),
      GoRoute(path: '/onboarding', builder: (c, s) => const OnboardingPage()),
      GoRoute(path: '/auth', builder: (c, s) => const AuthPage()),
      ShellRoute(
        builder: (context, state, child) {
          final tabIndex = switch (state.uri.path) {
            '/week'    => 1,
            '/library' => 2,
            '/profile' => 3,
            _          => 0, // /today e fallback
          };
          return ShellScaffold(tabIndex: tabIndex, child: child);
        },
        routes: [
          GoRoute(path: '/today',   builder: (c, s) => const TodayPage()),
          GoRoute(path: '/week',    builder: (c, s) => const WeekPage()),
          GoRoute(path: '/library', builder: (c, s) => const LibraryStubPage()),
          GoRoute(path: '/profile', builder: (c, s) => const ProfilePage()),
        ],
      ),
    ],
  );
});
```

- [x] **Step 4: Deletar os arquivos obsoletos**

```bash
git rm lib/features/home/home_placeholder_page.dart
git rm test/features/home/home_placeholder_test.dart
```

Expected: ambos removidos sem erro.

- [x] **Step 5: Rodar `flutter analyze`**

Run: `flutter analyze`
Expected: `No issues found!`

Se houver erro de import de `home_placeholder_page.dart` em algum arquivo, corrigir. (Não deve haver — apenas `auth_providers.dart` o referenciava, e já foi reescrito.)

- [x] **Step 6: Rodar TODOS os testes**

Run: `flutter test`
Expected: todos passando. A contagem deve ser ≥ 32 (Fase 2) + novos testes da Fase 3.

> Atenção: o `smoke_test.dart` que encontra "FORJA" pode precisar ser revisado — se ainda buscar a palavra em `HomePlaceholderPage`, ajustar para buscar em `SplashPage` ou remover o teste de smoke e substituir por um que reflita o novo fluxo.

Se o `smoke_test.dart` falhar porque buscava conteúdo da `HomePlaceholderPage`, substituir seu conteúdo por:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/features/splash/splash_page.dart';
import 'package:forja_app/theme/forja_colors.dart';

void main() {
  testWidgets('SplashPage compila e exibe CircularProgressIndicator', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: SplashPage()),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
```

- [x] **Step 7: Commit**

```bash
git add lib/router/redirect_logic.dart \
        lib/router/auth_providers.dart \
        test/router/redirect_logic_test.dart \
        test/smoke_test.dart
git commit -m "feat(fase3): ShellRoute + redirect /today + remoção do home placeholder"
```

---

## Task 10: Verificação no Chrome + merge

- [x] **Step 1: Subir o app no Chrome**

```bash
flutter run -d web-server --web-port 8080
```

Abrir `http://localhost:8080` no Chrome.

- [x] **Step 2: Verificar os 6 cenários**

1. Usuário logado → abre direto na aba **Hoje** (sem passar pelo onboarding).
2. Aba **Hoje** mostra o treino do dia (ou estado "Nenhum treino hoje" se não há dados).
3. Tocar em **"COMEÇAR TREINO"** → SnackBar "Execução chega na Fase 5".
4. Tocar no FAB (botão play central) → SnackBar "Execução chega na Fase 5".
5. Trocar para aba **Semana** → lista de 7 dias visível.
6. Aba **Perfil** → e-mail visível + "SAIR DA CONTA" funcional (redireciona para login).
7. Aba **Exercícios** → mensagem "Biblioteca chega na Fase 4".
8. Sair e logar novamente → cai na aba Hoje.

- [x] **Step 3: Atualizar o doc de design geral**

Editar `docs/superpowers/specs/2026-06-03-forja-mobile-flutter-design.md`, na tabela da seção 8, marcar a Fase 3 como concluída:

```
| 3 — Hoje + Semana | ✅ Dashboard do dia, KPIs, mini-semana; lista da semana |
```

- [x] **Step 4: Commit final**

```bash
git add docs/superpowers/specs/2026-06-03-forja-mobile-flutter-design.md
git commit -m "docs: marca Fase 3 (Hoje + Semana) como concluída no plano macro"
```

- [x] **Step 5: Merge na master + push**

```bash
git checkout master
git merge fase-3-hoje-semana --no-ff -m "feat: Fase 3 (Hoje + Semana) — Dashboard + navegação por abas"
git push origin master:main
```

---

## Self-Review (cobertura do spec)

- **ShellRoute + BottomAppBar + FAB** → Task 5 (ShellScaffold) + Task 9 (router) ✅
- **FAB decorativo (SnackBar)** → Task 5 e Task 7 ✅
- **Tab Hoje: hero card** → Task 7 (TodayPage) ✅
- **Tab Hoje: estado vazio** → Task 7 (_buildHeroEmpty) ✅
- **Tab Hoje: treino concluído** → Task 7 (_buildDoneBadge) ✅
- **Tab Hoje: 2 KPIs (streak + volume)** → Tasks 3 + 7 ✅
- **Tab Hoje: mini-semana** → Tasks 3 + 7 ✅
- **Tab Hoje: último PR** → Tasks 3 + 7 ✅
- **Tab Semana: 7 dias** → Tasks 4 + 8 ✅
- **Tab Semana: hoje com borda accent** → Task 8 ✅
- **Tab Semana: botão play hoje (decorativo)** → Task 8 ✅
- **Tab Exercícios: stub** → Task 6 ✅
- **Tab Perfil: e-mail + logout** → Task 6 ✅
- **Redirect /home → /today** → Task 9 ✅
- **Shell routes protegidas (deslogado → /auth)** → Task 9 ✅
- **HomePlaceholderPage removida** → Task 9 ✅
- **Testes** → Tasks 1, 2, 3, 5, 7, 8, 9 ✅

**Consistência de nomes:** `TodayWorkout/WeekDay/LastPr/WeekWorkout`, `todayWorkoutProvider/weekStreakProvider/weekVolumeProvider/miniWeekProvider/lastPrProvider/weekWorkoutsProvider`, `dartWeekdayToPostgresDow/dateToStr/thisWeekMonday/calculateStreak` — usados de forma idêntica em todos os arquivos.

**Placeholders:** nenhum "TBD". Todos os estados de UI (loading, erro, vazio, dados) implementados. Dados reais do Supabase nos providers; testes usam overrides de providers.

---

## ✅ Fase 3 concluída — 07/06/2026

**58 testes passando.** `flutter analyze` sem issues.

### Correção pós-execução: queries simplificadas

Durante o teste no browser, a aba **Semana** retornava "Erro ao carregar semana".
**Causa:** os providers originais (Tasks 3 e 4 acima) usavam junções aninhadas via PostgREST:
```
workouts → workout_exercises → exercise_library
```
Essas junções exigem que as foreign key relationships estejam explicitamente configuradas
no Supabase Dashboard, o que não estava feito.

**Fix aplicado** (commit `08d9043`): reescrevemos `today_providers.dart` e `week_providers.dart`
para usar queries planas separadas com `try/catch` individual por sub-query. Resultado:
- A aba Semana carrega sem erros.
- Falhas parciais (ex.: `workout_exercises` não acessível) retornam 0 em vez de explodir.
- Os grupos musculares ficam como `[]` por enquanto — serão buscados na Fase 4 quando as
  FK relationships estiverem configuradas ou quando buscarmos exercícios diretamente.

**Regra para todas as fases futuras:** nunca usar select aninhado no Supabase sem antes
confirmar que as FK relationships estão configuradas no dashboard do projeto.
