# FORJA Mobile — Contexto do Projeto para Claude Code

## O que é este projeto

App Flutter nativo (Android + iOS) do sistema FORJA Muscle Training.
Backend: Supabase existente em produção (https://forjamuscle.vercel.app).
Fases 0-3 concluídas. Próxima: Fase 4 (Biblioteca de Exercícios).

## Comandos essenciais

```bash
# Rodar no Chrome
flutter run -d web-server --web-port 8080

# Todos os testes (58 passando na Fase 3)
flutter test

# Checar erros/warnings
flutter analyze

# Instalar dependências
flutter pub get
```

> Sempre rodar `flutter analyze` antes de cada commit — deve retornar `No issues found!`

## Arquitetura

- **Flutter 3.44.1 / Dart 3.x**
- **Riverpod 3.x**: `FutureProvider` para dados async, `NotifierProvider` para estado mutável.
  - Em testes: usar `ProviderScope(overrides: [...])` com `.overrideWith((_) async => mock)`.
- **GoRouter 17.x**: `ShellRoute` envolve 4 tabs (/today, /week, /library, /profile).
  - Redirect logic em `lib/router/redirect_logic.dart` (função pura, testável).
- **Supabase Flutter 2.x**: queries PLANAS (sem junções aninhadas via PostgREST).
  - As foreign key relationships NÃO estão configuradas no Supabase ainda.
  - Usar selects simples + try/catch por query separada.
- **Feature-first**: `lib/features/{feature}/` — models, providers, page no mesmo diretório.

## Regras críticas de código

### Supabase queries — NUNCA usar junção aninhada
```dart
// ❌ ERRADO — falha se FK não estiver configurada no Supabase
final data = await client.from('workouts')
    .select('id, name, workout_exercises(sets, exercise_library(muscle_group))');

// ✅ CORRETO — query plana + try/catch
final workouts = await client.from('workouts').select('id, name, day_of_week');
int exerciseCount = 0;
try {
  final ex = await client.from('workout_exercises').select('id').eq('workout_id', id);
  exerciseCount = (ex as List).length;
} catch (_) {}
```

### Conversão de dia da semana (DOW)
```dart
// Dart: 1=Seg, 2=Ter, ... 7=Dom
// Postgres: 0=Dom, 1=Seg, ... 6=Sáb
int dartWeekdayToPostgresDow(int dartWeekday) => dartWeekday % 7;
```

### Flutter 3.44 — BottomAppBar
```dart
// ❌ ERRADO — parâmetro `shape` não existe em Flutter 3.44
BottomAppBar(shape: const CircularNotchRectangle(), ...);

// ✅ CORRETO — usar floatingActionButtonLocation com CircleBorder no FAB
BottomAppBar(color: ForjaColors.bg1, height: 64, ...);
FloatingActionButton(shape: const CircleBorder(), ...);
floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
```

### Dart lint — AsyncValue.when()
```dart
// ❌ ERRADO — lint: unnecessary_underscores
error: (_, __) => Text('erro'),

// ✅ CORRETO — usar mesmo nome para ambos
error: (_, _) => Text('erro'),
// OU nomes descritivos
error: (err, stack) => Text(err.toString()),
```

## Providers existentes

| Provider | Tipo | Retorna |
|----------|------|---------|
| `todayWorkoutProvider` | `FutureProvider<TodayWorkout?>` | Treino do dia (null se não há) |
| `weekStreakProvider` | `FutureProvider<int>` | Dias consecutivos de treino |
| `weekVolumeProvider` | `FutureProvider<double>` | Volume em kg desta semana |
| `miniWeekProvider` | `FutureProvider<List<WeekDay>>` | 7 dias Seg-Dom com status |
| `lastPrProvider` | `FutureProvider<LastPr?>` | Último recorde (null se não há) |
| `weekWorkoutsProvider` | `FutureProvider<List<WeekWorkout>>` | 7 treinos da semana |
| `accentProvider` | `NotifierProvider<AccentNotifier, AccentTheme>` | Tema de acento atual |
| `authControllerProvider` | `AsyncNotifierProvider` | Controle de login/logout |
| `currentUserEmailProvider` | `Provider<String?>` | E-mail do usuário logado |
| `onboardingSeenProvider` | `NotifierProvider<..., bool>` | Flag de onboarding |
| `goRouterProvider` | `Provider<GoRouter>` | Router configurado |

## Testes

- **58 testes passando** no final da Fase 3.
- Localização: `test/features/`, `test/core/`, `test/router/`.
- Para testar pages que usam Supabase, sempre usar `ProviderScope(overrides: [...])`.
- Em testes de widget: `await tester.pump()` + `await tester.pump(Duration(milliseconds: 100))` para resolver os FutureProviders.

## Tema FORJA

- **Cores**: `lib/theme/forja_colors.dart` — bg0, bg1, bg2, text, textDim, textFaint, hairline, border, danger, etc.
- **Tipografia**: Bebas Neue (títulos grandes), Space Grotesk (labels/body), JetBrains Mono (métricas).
- **Acento padrão**: Lime `#D4FF3A` (trocável pelo usuário, 6 opções).
- **Fundo padrão**: dark (`bg0 = #0A0A0A`).

## Próximas fases

- **Fase 4**: `lib/features/library/` — lista de exercícios, busca, filtros, detalhe.
  Stubs já existem em `library_stub_page.dart`.
- **Fase 5**: Execução de treino (o FAB central e botões "COMEÇAR TREINO" já estão na UI
  mas mostram SnackBar "chega na Fase 5").
- **Fase 7**: Perfil completo (ProfilePage atual é stub — e-mail + sair apenas).

## Onde ficam os docs

```
C:\Users\Marreta Preta\Desktop\FORJAMOBILE\
├── docs/superpowers/specs/   — documentos de design de cada fase
├── docs/superpowers/plans/   — planos de implementação de cada fase
└── Forja/design_handoff_forja_mobile/  — design visual hi-fi (referência)
```
