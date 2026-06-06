# FORJA Mobile (Flutter) — Documento de Design

**Versão:** 1.0
**Data:** 03 de junho de 2026
**Autor:** Denis Rodrigues (brainstorming com Claude Code)
**Status:** ✅ Design aprovado — pronto para gerar plano de implementação

> Este documento descreve o design do aplicativo **FORJA Mobile**, a versão nativa (Flutter)
> do sistema web **MUSCLE TRAINING / FORJA** (já em produção em https://forjamuscle.vercel.app).
> O próximo passo é a skill **writing-plans**, que transforma este design num plano tarefa-a-tarefa.

---

## 1. Objetivo

Construir um aplicativo móvel **nativo** (Android + iOS) em **Flutter** que reproduz o sistema
FORJA, reaproveitando integralmente o backend existente (Supabase) e aplicando, com alta
fidelidade, o design já entregue no handoff `Forja/design_handoff_forja_mobile`.

### Motivações do usuário (todas confirmadas)
- Publicar nas lojas (Google Play e App Store)
- Notificações push (locais + vindas do servidor)
- Experiência nativa fluida
- Acesso a recursos do aparelho

---

## 2. Decisões do brainstorming

| # | Decisão | Escolha |
|---|---------|---------|
| 1 | Público do app | **Aluno + Personal Trainer** (app completo) |
| 2 | Plataformas | **Android + iOS** (código cross-platform); testar e lançar **Android primeiro**; iOS quando houver acesso a Mac/serviço de nuvem |
| 3 | Fidelidade visual | **Alta fidelidade** ao Design System FORJA (handoff hi-fi pronto) |
| 4 | Escopo da v1 | **Máximo**: as 15 telas do design **+ Nutrição com IA** |
| 5 | Offline | **Treino funciona offline** com sincronização posterior |
| 6 | Notificações | **Locais + push do servidor** (Firebase Cloud Messaging) |
| 7 | Backend | **Reutilizar o Supabase existente** (não refazer) |

**Estratégia de construção:** mesmo com escopo máximo, a implementação é **faseada** — cada fase
entrega algo funcional e visível. Nutrição e Conquistas (que exigem ajustes no backend) ficam nas
fases finais.

---

## 3. Arquitetura geral

```
┌──────────────────────────────────────────────────────┐
│  APP FLUTTER (Android + iOS)                           │
│  • 15 telas FORJA (hi-fi) + telas de Nutrição          │
│  • Cofre local offline (treino)                        │
│  • Notificações locais                                 │
└──────────────┬──────────────────────────┬──────────────┘
               │ supabase_flutter          │ FCM
               ▼                           ▼
┌──────────────────────────────┐   ┌────────────────────┐
│  SUPABASE (existente)         │   │  FIREBASE (novo)    │
│  • Auth, Postgres + RLS       │   │  • Push do servidor │
│  • Storage (fotos)            │   │    para o aparelho  │
│  • Edge Functions (IA Groq)   │   └────────────────────┘
└──────────────────────────────┘
```

- **Supabase** é a fonte da verdade. O app consome via pacote oficial `supabase_flutter`.
- **Cofre local (offline)**: banco local no aparelho (`drift`) para a sessão de treino;
  fila de sincronização que envia ao Supabase quando a conexão volta.
- **Firebase Cloud Messaging (FCM)**: canal de push do servidor → aparelho. Disparado por uma
  Edge Function/trigger no Supabase em eventos relevantes.

### Stack técnica (seguindo a recomendação do handoff)
| Necessidade | Pacote |
|---|---|
| Ponte com o backend | `supabase_flutter` |
| Navegação | `go_router` |
| Estado/dados na tela | `flutter_riverpod` |
| Gráficos | `fl_chart` |
| Notificações locais | `flutter_local_notifications` + `timezone` |
| Push do servidor | `firebase_core` + `firebase_messaging` |
| Cofre local offline | `drift` (SQLite) |
| Preferências (tema, unidades) | `shared_preferences` |
| Imagens de exercício | `cached_network_image` |
| Fontes | `google_fonts` (Bebas Neue, Space Grotesk, JetBrains Mono) |

### Tema FORJA (do handoff)
- Dark por padrão; **acento trocável** pelo usuário (6 temas, padrão Lime `#D4FF3A`).
- Tokens de cor, tipografia, raios e espaçamento já definidos em código Dart no handoff
  (`forja_colors.dart`, `forja_theme.dart`, `accent_theme.dart`).
- Navegação principal do Aluno: `BottomNavigationBar` com **FAB central** (Hoje · Semana · ▶ · Exercícios · Perfil).
- Navegação do Personal: home em "Meus Alunos".

---

## 4. Backend: o que reusar e o que ajustar

### Já existe e será reutilizado (sem mudanças)
Login/Auth, perfis, catálogo de exercícios (`exercise_library`), fichas (`workouts` +
`workout_exercises`), sessões/séries (`workout_logs` + `exercise_logs`), peso e medidas
(`user_weights`, `body_measurements`), nutrição com IA (`nutrition_logs` + Edge Function
`analyze-meal`), gestão de alunos/trainers.

### Ajustes necessários no backend (previstos nas fases finais)
1. **Conquistas** — nova tabela (ex.: `achievements` + `user_achievements`) e lógica de
   medalhas/sequências (streak). Não existe hoje.
2. **% de gordura / massa magra** — adicionar campos/cálculo às medidas corporais.
3. **Push do servidor** — armazenar o token FCM do aparelho (ex.: coluna em `profiles` ou tabela
   `device_tokens`) e uma Edge Function que dispara o push em eventos:
   - treino novo atribuído ao aluno;
   - aluno concluiu/atrasou treino (para o personal);
   - novo recorde (PR).

> Toda mudança de banco segue as regras do projeto web: RLS ativo, soft delete (`is_active=false`),
> nada de DELETE físico. Usar a skill `/supabase-postgres-best-practices` ao escrever SQL.

---

## 5. Módulos e telas (15 telas + Nutrição)

| Módulo | Telas | Origem dos dados |
|--------|-------|------------------|
| Entrada | Onboarding (3 passos), Login/Cadastro | Auth (existe) |
| Hoje | Dashboard do dia, KPIs, mini-semana, último PR | Fichas + histórico (existe) |
| Semana | Lista de treinos da semana | Fichas (existe) |
| Exercícios | Biblioteca + busca + filtros, Detalhe do exercício | Catálogo (existe) |
| Treino ⭐ | Treino em execução, Cronômetro de descanso | Sessões/séries (existe) + **offline** |
| Progresso | Gráficos de carga e volume por grupo | Histórico (existe) |
| Medidas | Peso + medidas com gráficos | Medidas (existe) + **% gordura (criar)** |
| Conquistas | Medalhas, sequência atual | **Criar no backend** |
| Nutrição | Diário alimentar + análise por IA | Existe no backend; **telas a desenhar** |
| Perfil | Dados, KPIs, menu, Preferências/Tema | Perfil (existe) |
| Personal | Meus Alunos, Montar Treino | Gestão (existe) |

A especificação visual detalhada de cada tela (medidas, cores, componentes) está no handoff:
`Forja/design_handoff_forja_mobile/README.md` e `Forja Mobile.html` (referência visual definitiva).

---

## 6. Estratégia offline (treino)

- A sessão de treino é gravada primeiro no **cofre local** (`drift`): séries, cargas, reps, tempo.
- O cronômetro de descanso roda **independente de internet** (timer local + notificação local).
- Uma **fila de sincronização** envia os dados ao Supabase quando há conexão; em caso de conflito,
  o registro local mais recente prevalece (a sessão pertence a um único aparelho/usuário por vez).
- O restante do app (listas, gráficos) funciona online; pode exibir o último estado em cache.

---

## 7. Estratégia de notificações

**Locais** (`flutter_local_notifications`):
- Fim do descanso (som + vibração), mesmo com app em background — canal alta prioridade.
- Lembrete do treino do dia (agendado).

**Push do servidor** (Firebase Cloud Messaging):
- Treino novo atribuído (para o aluno).
- Aluno concluiu/atrasou (para o personal).
- Novo recorde (PR).
- Requer permissão do usuário (iOS e Android 13+) e registro do token FCM no backend.

---

## 8. Plano de fases (visão macro)

> O detalhamento tarefa-a-tarefa será produzido pela skill **writing-plans**.

| Fase | Entrega |
|------|---------|
| 0 — Ferramentas | ✅ Instalar Flutter SDK + Android Studio + emulador; `flutter doctor` ok |
| 1 — Fundação | ✅ `flutter create`, tema FORJA, fontes, `go_router`, Riverpod, conexão `supabase_flutter`, git init |
| 2 — Entrada | ✅ Onboarding + Login/Cadastro (Auth real) |
| 3 — Hoje + Semana | ✅ Dashboard do dia, KPIs, mini-semana; lista da semana |
| 4 — Exercícios | Biblioteca + busca/filtros + Detalhe |
| 5 — Treino ⭐ | Execução + Cronômetro + **cofre local offline** + sincronização |
| 6 — Progresso + Medidas | Gráficos `fl_chart`; peso/medidas (+ % gordura no backend) |
| 7 — Perfil | Perfil + Preferências + seletor de tema/acento |
| 8 — Personal | Meus Alunos + Montar Treino (reuso da lógica web) |
| 9 — Conquistas | Tabela + lógica no backend; telas de medalhas/sequência |
| 10 — Nutrição | Desenhar telas (/frontend-design) + diário + IA (Edge Function existente) |
| 11 — Notificações | Locais + Firebase (token, Edge Function de push, permissões) |
| 12 — Publicação | Ícones/splash, polish, build Android, publicar na Play Store (iOS quando houver Mac) |

**Critério geral de cada fase:** o app continua compilando e a entrega da fase é visível/testável.

---

## 9. Pontos de atenção e riscos

- **Escopo grande** — mitigado pela construção faseada; cada fase é independente e testável.
- **iOS** — código pronto desde o início, mas build/publicação exigem Mac ou serviço de nuvem
  (ex.: Codemagic) + conta Apple Developer (US$99/ano). Não bloqueia o Android.
- **Telas de Nutrição** — não existem no handoff; serão criadas mantendo o estilo FORJA.
- **Offline + sincronização** — é a parte mais delicada da engenharia; isolada na Fase 5.
- **Push do servidor** — depende de configurar Firebase e ajustar o backend; isolado na Fase 11.

---

## 10. Fora de escopo (por enquanto)

- Apple Watch / Wear OS, integrações com Saúde/Google Fit, login social (Google/Apple) — podem
  entrar em versões futuras (o design já prevê os botões sociais como placeholder).
- Pagamentos/assinaturas.

---

## 11. Comunicação

Todo o desenvolvimento segue as preferências do usuário: **português brasileiro**, explicações
simples (nível "15 anos"), dizendo o que será feito antes e confirmando depois, e aplicando as
boas práticas de desenvolvimento do Claude Code.
