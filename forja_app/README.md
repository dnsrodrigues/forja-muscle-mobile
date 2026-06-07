# FORJA Mobile — Flutter App

> Aplicativo nativo (Android + iOS) do sistema FORJA Muscle Training.
> Consome o backend Supabase já existente em produção.

---

## Estado atual do projeto

| Fase | Entrega | Status |
|------|---------|--------|
| 0 — Ferramentas | Flutter SDK + Android Studio + emulador | ✅ Concluída |
| 1 — Fundação | Tema FORJA, fontes, GoRouter, Riverpod, Supabase | ✅ Concluída |
| 2 — Entrada | Onboarding + Login/Cadastro (Auth real) | ✅ Concluída |
| 3 — Hoje + Semana | Dashboard do dia, KPIs, mini-semana; lista da semana | ✅ Concluída |
| 4 — Exercícios | Biblioteca + busca/filtros + Detalhe | 🔜 Próxima |
| 5 — Treino ⭐ | Execução + Cronômetro + offline + sincronização | ⏳ Pendente |
| 6 — Progresso + Medidas | Gráficos fl_chart; peso/medidas | ⏳ Pendente |
| 7 — Perfil | Perfil + Preferências + seletor de tema | ⏳ Pendente |
| 8 — Personal | Meus Alunos + Montar Treino | ⏳ Pendente |
| 9 — Conquistas | Medalhas + sequência (criar no backend) | ⏳ Pendente |
| 10 — Nutrição | Telas + diário + IA (Edge Function existente) | ⏳ Pendente |
| 11 — Notificações | Locais + Firebase push | ⏳ Pendente |
| 12 — Publicação | Build Android + Play Store | ⏳ Pendente |

---

## Stack técnica

| Necessidade | Pacote / Versão |
|---|---|
| Framework | Flutter 3.44.1 / Dart 3.x |
| Backend | `supabase_flutter 2.x` |
| Navegação | `go_router 17.x` (ShellRoute com 4 abas) |
| Estado / dados | `flutter_riverpod 3.x` (FutureProvider, NotifierProvider) |
| Fontes | `google_fonts 8.x` — Bebas Neue, Space Grotesk, JetBrains Mono |
| Testes | `flutter_test` + provider overrides via `ProviderScope` |

---

## Rodar localmente

```bash
# 1. Instalar dependências
flutter pub get

# 2. Rodar no Chrome (desenvolvimento)
flutter run -d web-server --web-port 8080
# Abrir: http://localhost:8080

# 3. Rodar no Android (emulador ou aparelho)
flutter run -d android

# 4. Rodar todos os testes (58 passando na Fase 3)
flutter test
```

---

## Estrutura de pastas

```
lib/
├── core/
│   └── widgets/
│       ├── forja_card.dart         # Card bg1 + borda hairline + r14
│       └── forja_kpi_tile.dart     # KPI: label + valor Bebas Neue + unidade
├── features/
│   ├── auth/                       # AuthController + AuthPage
│   ├── library/                    # LibraryStubPage (Fase 4)
│   ├── onboarding/                 # OnboardingPage (3 passos)
│   ├── profile/                    # ProfilePage (parcial, Fase 7 completa)
│   ├── shell/                      # ShellScaffold (BottomAppBar + FAB)
│   ├── splash/                     # SplashPage
│   ├── today/                      # TodayPage + providers + models
│   └── week/                       # WeekPage + providers + models
├── router/
│   ├── auth_providers.dart         # GoRouter + ShellRoute + providers de auth
│   ├── go_router_refresh_stream.dart
│   └── redirect_logic.dart         # Lógica pura do "porteiro" (testável)
├── services/
│   └── onboarding_prefs.dart       # SharedPreferences para flag de onboarding
├── theme/
│   ├── accent_theme.dart           # 6 temas de acento (padrão Lime #D4FF3A)
│   ├── forja_colors.dart           # Tokens de cor FORJA
│   └── forja_theme.dart            # ThemeData completo
└── main.dart

test/
├── core/widgets/                   # forja_card_test.dart
├── features/
│   ├── today/                      # today_providers_test.dart, today_page_test.dart
│   ├── week/                       # week_page_test.dart
│   └── shell/                      # shell_scaffold_test.dart
├── router/                         # redirect_logic_test.dart
└── smoke_test.dart
```

---

## Notas sobre o backend (Supabase)

- **Queries**: todas as queries usam selects planos (sem junções aninhadas via PostgREST).
  As foreign key relationships do PostgREST precisam ser configuradas no Supabase para
  `workout_exercises → exercise_library` funcionar via select aninhado. Por enquanto,
  os dados de grupos musculares são buscados com queries separadas quando necessário.
- **Tabelas usadas até a Fase 3**:
  - `workouts` — fichas de treino (colunas: `id`, `name`, `day_of_week`)
  - `workout_exercises` — exercícios de cada ficha (colunas: `id`, `workout_id`)
  - `workout_logs` — sessões realizadas (colunas: `workout_id`, `started_at`, `total_volume_kg`)
  - `exercise_logs` — séries individuais (colunas: `exercise_id`, `weight_kg`, `reps`, `done_at`, `is_pr`)
  - `exercise_library` — catálogo de exercícios (colunas: `id`, `name`, `muscle_group`)
- **DOW (day_of_week)**: Postgres usa 0=Dom … 6=Sáb. Dart usa 1=Seg … 7=Dom.
  Conversão: `dartWeekday % 7`

---

## Documentação

| Documento | Descrição |
|-----------|-----------|
| `docs/superpowers/specs/2026-06-03-forja-mobile-flutter-design.md` | Design geral do app (todas as fases) |
| `docs/superpowers/specs/2026-06-06-forja-mobile-fase-3-hoje-semana-design.md` | Design detalhado da Fase 3 |
| `docs/superpowers/plans/2026-06-03-forja-mobile-fase-0-1-fundacao.md` | Plano de execução Fases 0-1 |
| `docs/superpowers/plans/2026-06-06-forja-mobile-fase-2-entrada.md` | Plano de execução Fase 2 |
| `docs/superpowers/plans/2026-06-06-forja-mobile-fase-3-hoje-semana.md` | Plano de execução Fase 3 ✅ |
| `Forja/design_handoff_forja_mobile/` | Design handoff visual hi-fi (HTML + assets) |
