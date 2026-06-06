# FORJA Mobile — Fase 3 (Hoje + Semana): Dashboard + Navegação por Abas — Documento de Design

**Versão:** 1.0
**Data:** 06 de junho de 2026
**Autor:** Denis Rodrigues (brainstorming com Claude Code)
**Status:** ✅ Design aprovado
**Fase:** 3 de 12 — "Hoje + Semana"
**Branch:** `fase-3-hoje-semana`

> Continuação de `docs/superpowers/specs/2026-06-03-forja-mobile-flutter-design.md`.
> Este documento detalha **apenas a Fase 3**.

---

## 1. Objetivo

Substituir a tela inicial provisória (Fase 2) pelo **Dashboard real** do aluno, introduzindo a
navegação por abas com FAB central e conectando o app aos dados reais do Supabase.

Ao final desta fase:
- O usuário logado vê o treino do dia, sua sequência e volume da semana.
- A mini-semana mostra o ciclo da semana com status de cada dia.
- O card "Último PR" exibe o recorde pessoal mais recente.
- A aba "Semana" lista os 7 treinos com status visual.
- As abas Exercícios e Perfil são stubs visualmente completos (sem dados reais ainda).

---

## 2. Decisões desta fase

| # | Decisão | Escolha |
|---|---------|---------|
| 1 | Navegação | **ShellRoute** com `BottomNavigationBar` customizado + FAB central (`BottomAppBar` + `FloatingActionButton`) |
| 2 | FAB "iniciar treino" | **Decorativo** nesta fase — abre SnackBar "Execução chega na Fase 5" |
| 3 | Dados | **Reais do Supabase** (workouts, workout_logs, exercise_logs) com Riverpod `AsyncValue` |
| 4 | Estado vazio | Cards com mensagem amigável quando não há dados (novo usuário) |
| 5 | Aba Exercícios | **Stub** — tela com mensagem "Fase 4" e ícone de haltere |
| 6 | Aba Perfil | **Parcial** — mostra e-mail + botão "Sair" (mesma lógica do placeholder da Fase 2) |
| 7 | Gráficos | **Fora de escopo** — chegam na Fase 6 (`fl_chart`) |
| 8 | Offline | **Fora de escopo** — Fase 5 |

### Fora de escopo (YAGNI)
- Execução de treino funcional (Fase 5)
- Biblioteca de exercícios com busca (Fase 4)
- Gráficos de progresso e medidas (Fase 6)
- Perfil completo e seletor de tema (Fase 7)
- Meus Alunos (Personal Trainer) — Fase 8

---

## 3. Fluxo de navegação

```
/today     ← tab Hoje (dashboard)
/week      ← tab Semana
/library   ← tab Exercícios (stub Fase 4)
/profile   ← tab Perfil (parcial)
```

O **ShellRoute** envolve estas 4 rotas. A rota `/home` (que existia como placeholder na Fase 2)
é removida do router e substituída por `/today`.

O redirect lógico muda: usuário logado vai para `/today` (em vez de `/home`).

O FAB não tem rota própria — é um botão que chama `ScaffoldMessenger.of(context).showSnackBar(...)`.

---

## 4. Estrutura de arquivos

```
lib/
├── router/
│   └── auth_providers.dart      [MOD] ShellRoute + 4 novas rotas; redirect /home→/today
├── features/
│   ├── shell/
│   │   └── shell_scaffold.dart  [NEW] BottomAppBar + FAB + IndexedStack
│   ├── today/
│   │   ├── today_page.dart      [NEW] UI do dashboard
│   │   ├── today_providers.dart [NEW] 4 providers de dados (treino, streak, mini-semana, PR)
│   │   └── today_models.dart    [NEW] TodayWorkout, WeekDay, LastPr
│   ├── week/
│   │   ├── week_page.dart       [NEW] UI da lista semanal
│   │   └── week_providers.dart  [NEW] weekWorkoutsProvider
│   ├── library/
│   │   └── library_stub_page.dart [NEW] stub "Fase 4"
│   ├── profile/
│   │   └── profile_page.dart    [NEW] e-mail + sair (reutiliza lógica do placeholder)
│   └── home/
│       └── home_placeholder_page.dart [DEL] substituída por today + profile
├── core/widgets/
│   ├── forja_card.dart          [NEW] widget de card reutilizável (bg1 + hairline)
│   └── forja_kpi_tile.dart      [NEW] tile de KPI (label + valor Bebas)
└── test/
    ├── features/today/today_providers_test.dart  [NEW]
    ├── features/today/today_page_test.dart       [NEW]
    ├── features/week/week_page_test.dart         [NEW]
    └── core/widgets/forja_card_test.dart         [NEW]
```

---

## 5. Modelos de dados

```dart
// lib/features/today/today_models.dart

class TodayWorkout {
  final String id;
  final String name;          // ex.: "PUSH A"
  final List<String> groups;  // ex.: ["Peito", "Ombro", "Tríceps"]
  final int exerciseCount;
  final int estimatedMinutes;
  final double totalVolumeKg; // soma de séries × carga (0 se novo)
  final bool isDone;
  const TodayWorkout({...});
}

class WeekDay {
  final String abbr;          // 'S', 'T', 'Q', 'Q', 'S', 'S', 'D'
  final String dayLabel;      // 'SEG', 'TER', ...
  final int dayNumber;        // dia do mês (ex.: 23)
  final bool isToday;
  final bool isRest;
  final bool isDone;
  final String? workoutName;  // null se descanso
  const WeekDay({...});
}

class LastPr {
  final String exerciseName;
  final double weightKg;
  final int reps;
  final DateTime doneAt;
  const LastPr({...});
}

class WeekWorkout {
  final String dayAbbr;       // 'SEG' ... 'DOM'
  final String name;
  final List<String> groups;
  final bool isToday;
  final bool isDone;
  final bool isRest;
  final double? volumeKg;     // null se ainda não feito / descanso
  const WeekWorkout({...});
}
```

---

## 6. Camada de dados (Supabase)

### Pressupostos do schema (a confirmar com o banco real)

| Tabela | Colunas relevantes |
|--------|-------------------|
| `workouts` | `id`, `user_id`, `name`, `day_of_week` (0=Dom…6=Sáb), `is_active` |
| `workout_exercises` | `id`, `workout_id`, `exercise_id`, `sets`, `reps`, `load_kg`, `rest_seconds`, `position` |
| `exercise_library` | `id`, `name`, `muscle_group` |
| `workout_logs` | `id`, `user_id`, `workout_id`, `started_at`, `finished_at`, `total_volume_kg`, `is_active` |
| `exercise_logs` | `id`, `workout_log_id`, `exercise_id`, `weight_kg`, `reps`, `is_pr`, `done_at` |

> **Nota de implementação:** se algum nome de coluna diferir, ajustar apenas nos providers.
> Os modelos e a UI não mudam.

### Queries por provider

**`todayWorkoutProvider`** — `FutureProvider<TodayWorkout?>`
```sql
-- Busca workout do dia atual (day_of_week = weekday local)
SELECT w.id, w.name,
       COUNT(we.id) AS exercise_count,
       COALESCE(SUM(we.sets * we.load_kg * we.reps), 0) AS estimated_volume
FROM workouts w
LEFT JOIN workout_exercises we ON we.workout_id = w.id
WHERE w.user_id = auth.uid()
  AND w.day_of_week = :todayWeekday   -- 0=Dom, 1=Seg...6=Sab
  AND w.is_active = true
GROUP BY w.id
LIMIT 1
```
O status `isDone` vem de um `workout_logs` com `workout_id = w.id` e `started_at::date = today`.

**`weekStreakProvider`** — `FutureProvider<int>` (contagem de dias consecutivos com log)
```
Busca workout_logs ordenados por started_at desc; conta quantos dias consecutivos
retroativos a partir de ontem têm pelo menos 1 log.
```

**`weekVolumeProvider`** — `FutureProvider<double>` (soma de total_volume_kg nos últimos 7 dias)

**`miniWeekProvider`** — `FutureProvider<List<WeekDay>>`
- Gera 7 `WeekDay` para a semana atual (Seg→Dom)
- Cruza com `workouts` (tem treino neste dia?) e `workout_logs` (foi concluído?)
- Dias sem treino atribuído = `isRest: true`

**`lastPrProvider`** — `FutureProvider<LastPr?>`
```sql
SELECT el.weight_kg, el.reps, el.done_at, ex.name
FROM exercise_logs el
JOIN exercise_library ex ON ex.id = el.exercise_id
WHERE el.is_pr = true
  AND el.workout_log_id IN (
    SELECT id FROM workout_logs WHERE user_id = auth.uid()
  )
ORDER BY el.done_at DESC
LIMIT 1
```

**`weekWorkoutsProvider`** — `FutureProvider<List<WeekWorkout>>`
- Lista os 7 workouts da semana (ou "DESCANSO" se não houver)
- Cruza com `workout_logs` para status (done/today/future)

---

## 7. UI — Tab "Hoje"

### Layout (de cima para baixo, fundo `bg0`)

```
┌─────────────────────────────┐
│ [eyebrow: "Qui · 21 mai"]   │
│ BOM DIA, LUCAS     [avatar] │  ← MobHead
├─────────────────────────────┤
│ ╔═══ CARD HERÓI (accent) ══╗│
│ ║ [04 fantasma atrás]       ║│
│ ║ HOJE · DIA 04 / 06        ║│
│ ║ PUSH              Bebas68 ║│
│ ║ Peito · Ombro · Tríceps   ║│
│ ║ 7 exerc · 62min · 8.4t    ║│
│ ║ [COMEÇAR TREINO]          ║│
│ ╚═══════════════════════════╝│
│                              │
│ ┌────────────┐ ┌────────────┐│
│ │ Streak     │ │ Vol. semana││  ← 2 KPIs
│ │ 17 dias    │ │ 32.8t      ││
│ └────────────┘ └────────────┘│
│                              │
│ ┌──────────── SEMANA 22 ────┐│
│ │ [S][T][Q][Q★][S][S][D///] ││  ← mini-semana
│ └──────────────────────────┘│
│                              │
│ ┌── ÚLTIMO PR ──────────────┐│
│ │ 🏆 Supino Inclinado       ││
│ │    30kg×8   há 2 dias     ││
│ └──────────────────────────┘│
└─────────────────────────────┘
```

**Estado vazio (novo usuário sem treinos):**
- Hero card: fundo `bg1`, ícone de haltere, texto "Nenhum treino hoje. Seu personal vai montar seu plano em breve."
- KPIs: "–" como valor
- Mini-semana: 7 colunas cinzas (sem dados)
- Último PR: card oculto

**Estado de carregamento:** skeleton com retângulos `bg2` animados (shimmer).

**Estado de treino já concluído:** hero card em `bg1` com ✓ e texto "TREINO CONCLUÍDO", sem botão.

---

## 8. UI — Tab "Semana"

```
┌─────────────────────────────┐
│ Ciclo Hipertrofia · Sem 22  │
│ SUA SEMANA             [+]  │  ← MobHead
├─────────────────────────────┤
│ ┌──────────────────── bg1 ─┐│
│ │ SEG  PULL A              ││  ← card normal
│ │      Costas · Bíceps  ✓  ││
│ └──────────────────────────┘│
│ ┌─── borda accent ─────────┐│
│ │ QUI  PUSH A           [▶]││  ← hoje
│ │      Peito · Ombro        ││
│ └──────────────────────────┘│
│ ┌────── opacidade 60% ─────┐│
│ │ DOM  DESCANSO            ││  ← descanso
│ └──────────────────────────┘│
└─────────────────────────────┘
```

O botão `[+]` do header é decorativo nesta fase (SnackBar "Montar treino chega na Fase 8").

---

## 9. Shell — BottomAppBar + FAB

```dart
// Implementação sugerida
Scaffold(
  body: IndexedStack(index: _tab, children: [TodayPage(), WeekPage(), LibraryStubPage(), ProfilePage()]),
  bottomNavigationBar: BottomAppBar(
    color: ForjaColors.bg1,
    notchMargin: 6,
    shape: const CircularNotchRectangle(),
    child: Row(children: [
      _TabItem(icon: Icons.home_rounded, label: 'Hoje',      index: 0),
      _TabItem(icon: Icons.calendar_today_rounded, label: 'Semana', index: 1),
      const SizedBox(width: 64), // espaço do FAB
      _TabItem(icon: Icons.fitness_center_rounded, label: 'Exercícios', index: 2),
      _TabItem(icon: Icons.person_rounded, label: 'Perfil',   index: 3),
    ]),
  ),
  floatingActionButton: FloatingActionButton(
    backgroundColor: accent,
    foregroundColor: accentFg,
    elevation: 0,
    shape: const CircleBorder(),
    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Execução de treino chega na Fase 5 💪')),
    ),
    child: const Icon(Icons.play_arrow_rounded, size: 28),
  ),
  floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
)
```

---

## 10. Widgets reutilizáveis novos

### `ForjaCard`
```dart
// Container com bg1, borda hairline, radius 14, padding configurável
ForjaCard({ required Widget child, EdgeInsets? padding, Color? borderColor })
```

### `ForjaKpiTile`
```dart
// Label pequeno + valor Bebas grande
ForjaKpiTile({ required String label, required String value, String? unit })
```

---

## 11. Testes

- **`today_providers_test.dart`:** testa `TodayWorkout`, `WeekDay`, `LastPr` com dados mockados; testa estado vazio (null) e estado com dados.
- **`today_page_test.dart`:** renderiza a página com provider mockado; verifica card-herói, KPIs, mini-semana.
- **`week_page_test.dart`:** renderiza com lista mockada; verifica card de hoje com borda accent, card de descanso.
- **`forja_card_test.dart`:** verifica que aplica decoração correta.
- **Regressão:** `flutter test` no final deve passar todos os testes anteriores (32 da Fase 2 + novos).

---

## 12. Critério de conclusão da fase

- App compila e roda no Chrome.
- Usuário logado vê o treino de hoje (ou estado vazio limpo).
- Mini-semana mostra os 7 dias com status correto.
- Aba Semana lista os 7 treinos.
- FAB mostra SnackBar "Fase 5".
- Abas Exercícios e Perfil mostram conteúdo stub.
- Testes todos passando.
- `HomePlaceholderPage` removida.

---

## 13. Riscos e atenção

- **Schema do Supabase:** os nomes de colunas assumidos precisam ser confirmados no painel do Supabase antes de implementar os providers. Se algum nome diferir, é uma mudança de 1 linha por campo.
- **`day_of_week`:** verificar se o banco usa 0=Dom (padrão Postgres `EXTRACT(DOW)`) ou 1=Seg (ISO). Dart usa `DateTime.weekday` onde 1=Seg…7=Dom. Alinhar a conversão.
- **RLS:** as queries assumem que o RLS do Supabase filtra por `auth.uid()` automaticamente. Confirmar que as políticas existentes cobrem as tabelas usadas.
- **Usuário sem treinos:** estado vazio bem testado para evitar erros de null.
