# Handoff: FORJA — App Mobile (Flutter)

## Visão geral

**FORJA** é um app de controle de treino de academia (musculação / hipertrofia). Este pacote contém o **design de todas as telas mobile** na identidade visual FORJA, pronto para ser implementado em **Flutter**.

O app atende dois perfis:
- **Aluno** — executa seus treinos, registra séries/cargas, acompanha progresso.
- **Personal Trainer** — monta treinos e acompanha seus alunos.

São **15 telas** desenhadas: Onboarding, Login/Cadastro, Hoje (Dashboard), Semana, Biblioteca de Exercícios, Treino em Execução, Detalhe do Exercício, Cronômetro de Descanso, Progresso, Perfil, Meus Alunos (Personal), Montar Treino (Personal), Conquistas, Medidas Corporais e Preferências/Tema.

---

## Sobre os arquivos deste pacote

⚠️ **Os arquivos `.html`/`.jsx`/`.css` deste bundle são REFERÊNCIAS DE DESIGN** — protótipos feitos em HTML/React que mostram a aparência e o comportamento pretendidos. **Não são código de produção para copiar.**

Sua tarefa é **recriar estas telas em um app Flutter**, usando widgets nativos do Flutter e os padrões idiomáticos do framework (Material 3 como base, customizado com o tema FORJA). Onde este documento dá valores exatos (hex, tamanhos, espaçamentos), use-os fielmente.

Se o projeto Flutter ainda não existe, crie um novo (`flutter create forja`) e estruture conforme a seção **Arquitetura sugerida** abaixo.

## Fidelidade

**Alta fidelidade (hi-fi).** Cores, tipografia, espaçamento e hierarquia são finais. Reproduza pixel a pixel usando os tokens desta documentação. As imagens de exercício estão como *placeholders* (hachura diagonal com "IMG") — substitua por imagens/vídeos reais ou por um widget de placeholder equivalente.

---

## Fontes

Três famílias, todas no Google Fonts:

| Papel | Família | Uso |
|---|---|---|
| **Display** | **Bebas Neue** (400) | Títulos, números grandes, eyebrows, valores de KPI. Condensada, atlética. SEMPRE em CAIXA ALTA. |
| **Corpo / UI** | **Space Grotesk** (400/500/600/700) | Texto de interface, labels, botões, descrições, navegação. |
| **Mono** | **JetBrains Mono** (500/600) | Apenas números tabulares: cargas, reps, volume, cronômetro. Garante alinhamento de colunas. |

### Setup no Flutter

Use o pacote [`google_fonts`](https://pub.dev/packages/google_fonts) (mais simples) **ou** empacote os `.ttf` no `pubspec.yaml`.

**Opção A — google_fonts (recomendada):**
```yaml
# pubspec.yaml
dependencies:
  google_fonts: ^6.2.1
```
```dart
import 'package:google_fonts/google_fonts.dart';

// Bebas Neue → GoogleFonts.bebasNeue()
// Space Grotesk → GoogleFonts.spaceGrotesk()
// JetBrains Mono → GoogleFonts.jetBrainsMono()
```

**Opção B — fontes empacotadas** (offline, recomendado para produção):
```yaml
# pubspec.yaml
flutter:
  fonts:
    - family: BebasNeue
      fonts: [{ asset: assets/fonts/BebasNeue-Regular.ttf }]
    - family: SpaceGrotesk
      fonts:
        - { asset: assets/fonts/SpaceGrotesk-Regular.ttf, weight: 400 }
        - { asset: assets/fonts/SpaceGrotesk-Medium.ttf, weight: 500 }
        - { asset: assets/fonts/SpaceGrotesk-SemiBold.ttf, weight: 600 }
        - { asset: assets/fonts/SpaceGrotesk-Bold.ttf, weight: 700 }
    - family: JetBrainsMono
      fonts:
        - { asset: assets/fonts/JetBrainsMono-Medium.ttf, weight: 500 }
        - { asset: assets/fonts/JetBrainsMono-SemiBold.ttf, weight: 600 }
```

---

## Design Tokens

### Cores

```dart
// lib/theme/forja_colors.dart
import 'package:flutter/material.dart';

class ForjaColors {
  // Superfícies (escuro — o app é dark por padrão)
  static const bg0 = Color(0xFF08090A); // fundo da tela / canvas
  static const bg1 = Color(0xFF101113); // card
  static const bg2 = Color(0xFF181A1C); // card aninhado / input
  static const bg3 = Color(0xFF23262A); // hover / trilho de barra
  static const bg4 = Color(0xFF2E3236);
  static const bgDark = Color(0xFF050506); // telas de foco (cronômetro, login art)

  // Bordas (use com Border.all)
  static const hairline = Color(0x0FFFFFFF);     // rgba(255,255,255,0.06)
  static const border = Color(0x1AFFFFFF);       // rgba(255,255,255,0.10)
  static const borderStrong = Color(0x33FFFFFF); // rgba(255,255,255,0.20)

  // Texto
  static const text = Color(0xFFF5F5F3);
  static const textDim = Color(0xFF9A9A96);
  static const textFaint = Color(0xFF5A5A56);

  // Acento (TEMÁVEL — ver "Sistema de temas")
  static const accent = Color(0xFFD4FF3A);   // verde-limão (padrão)
  static const accentFg = Color(0xFF0A0A0A); // texto/ícone sobre acento

  // Semânticas
  static const danger = Color(0xFFFF3D55);
  static const warn = Color(0xFFFFB547);
  static const success = Color(0xFF6AFFB9);
  static const info = Color(0xFF6EC6FF);
}
```

### Sistema de temas (cor de acento trocável)

O acento é **trocável pelo usuário** — é um recurso nativo do app. 6 temas; o padrão é **Lime**. A escolha persiste (use `shared_preferences`).

```dart
// lib/theme/forja_theme_accent.dart
class AccentTheme {
  final String id, name;
  final Color accent, fg;
  const AccentTheme(this.id, this.name, this.accent, this.fg);
}

const accentThemes = [
  AccentTheme('lime',   'Lime',   Color(0xFFD4FF3A), Color(0xFF0A0A0A)),
  AccentTheme('coral',  'Coral',  Color(0xFFFF2E4D), Color(0xFFFFFFFF)),
  AccentTheme('orange', 'Forge',  Color(0xFFFF6B00), Color(0xFF0A0A0A)),
  AccentTheme('ice',    'Ice',    Color(0xFF00D4FF), Color(0xFF0A0A0A)),
  AccentTheme('violet', 'Violet', Color(0xFFA78BFA), Color(0xFF0A0A0A)),
  AccentTheme('mono',   'Mono',   Color(0xFFF5F5F0), Color(0xFF0A0A0A)),
];
```
Exponha o acento via `Provider`/`Riverpod`/`InheritedWidget` para que toda a árvore reaja à troca. Um seletor de swatches (círculos da cor) deve aparecer em **Perfil → Preferências**.

### Escala tipográfica (TextTheme)

| Token | Família | Tamanho | Peso | Espaçamento | Uso |
|---|---|---|---|---|---|
| `displayGiant` | BebasNeue | 110 | 400 | — | Cronômetro grande |
| `displayXL` | BebasNeue | 68 | 400 | — | Título-herói (PUSH no dashboard) |
| `displayL` | BebasNeue | 44–56 | 400 | — | Títulos de tela (h1) |
| `displayM` | BebasNeue | 30–38 | 400 | — | Títulos de card, nomes |
| `displayS` | BebasNeue | 20–24 | 400 | — | Subtítulos, dias |
| `eyebrow` | BebasNeue | 11–13 | 400 | +0.18em | Rótulos acima de títulos (CAIXA ALTA) |
| `body` | SpaceGrotesk | 14–15 | 400/500 | — | Texto corrido, descrições |
| `bodySm` | SpaceGrotesk | 12–13 | 400 | — | Legendas, metadados |
| `button` | SpaceGrotesk | 13–15 | 600 | +0.04em | Botões (CAIXA ALTA) |
| `label` | SpaceGrotesk | 10–11 | 600 | +0.10em–0.15em | Labels de campo (CAIXA ALTA) |
| `mono` | JetBrainsMono | 12–16 | 600 | — | Cargas, reps, cronômetro, volume |

> Em Bebas Neue use `height: 0.95` (NÃO menos) para evitar que glifos da última linha invadam o texto seguinte. Em números grandes (cronômetro) `height: 0.9` é aceitável quando isolado.

```dart
// Exemplo de TextTheme com google_fonts
TextTheme forjaTextTheme(Color text) => TextTheme(
  displayLarge: GoogleFonts.bebasNeue(fontSize: 56, height: 0.95, color: text),
  displayMedium: GoogleFonts.bebasNeue(fontSize: 38, height: 0.95, color: text),
  titleLarge: GoogleFonts.bebasNeue(fontSize: 24, color: text),
  bodyLarge: GoogleFonts.spaceGrotesk(fontSize: 15, color: text),
  bodyMedium: GoogleFonts.spaceGrotesk(fontSize: 13, color: ForjaColors.textDim),
  labelLarge: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.5),
);
```

### Espaçamento

Grade base de **4px**. Valores recorrentes: `4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 28, 32`.
Padding de tela: **16px** horizontal (listas) / **20–28px** (telas de foco). Padding de card: **16–22px**.

### Raios (BorderRadius)

```dart
class ForjaRadius {
  static const r1 = 4.0;   // inputs pequenos de série
  static const r2 = 8.0;   // botões, inputs, chips quadrados
  static const r3 = 14.0;  // cards
  static const r4 = 22.0;  // containers grandes
  static const pill = 999.0; // chips, barras de progresso, FAB
}
```

### Sombras

Discretas. A única sombra notável é a do **FAB central** da tab bar:
`BoxShadow(color: accent.withOpacity(0.5), blurRadius: 24, offset: Offset(0, 8))`.
Cards no dark usam **borda hairline**, não sombra.

---

## Componentes → Widgets Flutter

| Componente (no design) | Widget Flutter | Especificação |
|---|---|---|
| **Tela / Scaffold** | `Scaffold(backgroundColor: bg0)` | Status bar do SO sobreposta; dark. |
| **Botão primário** | `FilledButton` | bg=`accent`, texto=`accentFg`, CAIXA ALTA, peso 600, radius 8, padding V14–18. Largura cheia (`cta`) nas ações principais. |
| **Botão secundário** | `OutlinedButton` | bg=`bg2`, borda=`border`, texto=`text`. |
| **Botão ghost** | `TextButton`/`OutlinedButton` | transparente, borda `border`. |
| **Botão perigo** | `OutlinedButton` | texto=`danger`, borda `danger@30%`. |
| **Card** | `Container` + `BoxDecoration` | bg=`bg1`, `Border.all(color: hairline)`, radius 14, padding 16–22. |
| **Card de acento** (herói) | `Container` | bg=`accent`, texto escuro. Número fantasma gigante atrás (`Positioned` + opacity 0.08). |
| **Chip** | `Container` (pill) | radius 999, bg=`bg2`, borda `border`, texto 11px peso 600 CAIXA ALTA. Variações: `solid`(accent), `muscle`(bg3), `success`, `danger`. |
| **Input** | `TextField` | bg=`bg2`, borda `border`→`accent` no foco, radius 8, padding 12–14. |
| **Segmented control** | `Container` com `Row` de `Expanded` | trilho bg=`bg2` radius 10; item ativo bg=`accent` radius 8. Ver telas Login e Progresso. |
| **Linha de lista** | `Container` + `Border(bottom: hairline)` | `Row` com gap 14, padding V14. |
| **Barra de progresso** | `ClipRRect` + `LinearProgressIndicator` ou `FractionallySizedBox` | altura 6, trilho `bg3`, preenchimento `accent`, radius 999. |
| **Checkbox de série** | `GestureDetector` + `AnimatedContainer` | 22–24px, radius 6, borda `borderStrong`; marcado = bg `accent` + ícone check `accentFg`. |
| **Input de série** | `TextField` (compacto) | mono, centralizado, radius 4, borda `border`. 3 colunas: Kg / Reps / ✓. |
| **KPI** | `Container` (card) | label pequeno + número Bebas grande. |
| **Avatar** | `Container` círculo/`BorderRadius` | gradiente `#1A1B1C→#050506`, iniciais em Bebas cor `accent`. |
| **Placeholder de imagem** | `Container` | hachura diagonal — substituir por `Image`/`CachedNetworkImage` real. |
| **Anel de progresso (cronômetro)** | `CustomPaint` | dois arcos: trilho `bg2` + progresso `accent`, `strokeCap: round`, rotacionado −90°. |
| **Gráfico de linha (Progresso)** | [`fl_chart`](https://pub.dev/packages/fl_chart) `LineChart` | linha `accent` 2.5px + área com gradiente `accent@35%→0`. |
| **Gráfico de barras (dashboard web)** | `fl_chart` `BarChart` | barra atual `accent`, demais `bg3`. |
| **Bottom Tab Bar** | `BottomNavigationBar` custom / `Stack` | 5 slots, centro = FAB. Ver abaixo. |

### Bottom Tab Bar com FAB central (padrão de navegação)

5 posições: **Hoje · Semana · [▶ FAB] · Exercícios · Perfil**.
- O FAB central é um círculo de **64px**, bg=`accent`, ícone *play* `accentFg`, com `margin-top:-28` (sobe sobre a barra) e borda de 4px na cor do fundo (`bg0`) para "recortar" da barra. Sombra de brilho do acento.
- Ação do FAB: **iniciar / continuar o treino de hoje** (vai para *Treino em Execução*).
- Itens inativos: ícone + label em `textFaint`; ativo em `accent`.
- Implemente com `Stack` (barra + FAB sobreposto) ou `BottomAppBar` com `notch` + `FloatingActionButton(shape: CircleBorder())` e `FloatingActionButtonLocation.centerDocked`.

---

## Telas (uma a uma)

> Em todas: fundo `bg0` (ou `bgDark` nas de foco), status bar do SO em modo claro (ícones brancos). Larguras de referência: **390×844** (iPhone base) — use layout responsivo, não fixe pixels de tela.

### 1. Onboarding
- **Topo (≈40% da altura):** área de arte com **shader animado** (ondas horizontais com aberração cromática tingidas na cor de acento). No Flutter: use um `ShaderMask`/`CustomPainter` animado, um vídeo curto, ou um Lottie — ou simplifique para um gradiente animado na cor do acento. Gradiente de fade para `bgDark` na base.
- **Eyebrow** "FORJA · 01 / 03" em `accent`.
- **Título** Bebas 56, `height 0.95`: "REGISTRE CADA **SÉRIE**" (SÉRIE em `accent`).
- **Parágrafo** descritivo `textDim`.
- **Rodapé:** dots de paginação (ativo = pílula alongada `accent` 26px) + "Pular"; botão primário largura cheia "PRÓXIMO →".
- 3 telas de onboarding (carousel via `PageView`).

### 2. Login / Cadastro
- **Banda superior (200px):** shader + wordmark "FORJA." (Bebas 76, ponto em `accent`), fade para `bg0`.
- **Segmented control:** "Entrar" | "Criar conta".
- **Campos:** Email, Senha (com "Esqueceu?" em `accent`). Botão primário "ENTRAR →".
- Divisor "OU" + dois `OutlinedButton` (Google / Apple).
- Rodapé: termos/privacidade.

### 3. Hoje (Dashboard) — *tab Hoje*
- **Header:** eyebrow data "Qui · 21 mai" + título "BOM DIA, LUCAS" + avatar à direita.
- **Card-herói (card de acento):** treino do dia. Número fantasma "04" atrás. "HOJE · DIA 04 / 06", "PUSH" (Bebas 68), grupos, métricas mono (7 exercícios · 62min · 8.4t), botão escuro "COMEÇAR TREINO".
- **2 KPIs:** Streak (17 dias) · Vol. semana (32.8t).
- **Mini-semana:** 7 colunas (S T Q Q S S D), dia de hoje destacado em `accent`, concluídos com ✓, descanso tracejado.
- **Card "Último PR":** ícone troféu + exercício + valor mono em `accent`.

### 4. Semana — *tab Semana*
- Header "SUA SEMANA" + botão `+`.
- Lista de 7 cards de dia: sigla (SEG…), nome do treino (Bebas 30), grupos, e à direita: ✓ se concluído / botão play se é hoje (borda em `accent`) / volume mono se futuro. Dia de descanso com opacidade reduzida.

### 5. Biblioteca de Exercícios — *tab Exercícios*
- Header "EXERCÍCIOS" + contador "124 exercícios".
- Campo de busca (ícone lupa) + linha de chips de filtro com scroll horizontal (Todos, Peito, Costas…).
- Lista de exercícios: thumbnail 56px + nome + chips (grupo/equipamento) + PR mono em `accent` à direita.

### 6. Treino em Execução ⭐ (tela principal do app)
- **Header:** voltar + "EM TREINO" com cronômetro mono em `accent` (24:18) + menu.
- **Bloco do exercício:** eyebrow "Exercício 02 / 07 · Peito", nome em Bebas 42, barra de progresso da sessão.
- **Tabela de séries:** colunas # / Kg / Reps / ✓. Linha concluída com opacidade 0.5; linha **atual** destacada (`bg2`); badge "PR" em série recorde. Inputs editáveis mono.
- **Card "Próximo":** thumbnail + nome + alvo do próximo exercício.
- **Rodapé fixo** (barra `#0A0B0C`, borda topo): botão primário largura cheia "CONCLUIR SÉRIE · DESCANSO 1:30" → dispara o cronômetro.

### 7. Detalhe do Exercício
- **Mídia topo (280px):** imagem/vídeo (placeholder), gradiente de leitura, botões circulares translúcidos (voltar / +), pílula "▶ Ver demonstração".
- **Título** Bebas 44 + chips (músculos, equipamento, nível).
- **3 KPIs:** PR / Última / Sessões.
- **"EXECUÇÃO":** passos numerados (número em `accent` Bebas) + texto.
- Botão primário "+ Adicionar ao treino".

### 8. Cronômetro de Descanso (foco total)
- Fundo `#0A0A0A`. Header: voltar + "DESCANSO" + "PULAR".
- **Anel circular** (`CustomPaint`) 280px: trilho `bg2` + progresso `accent`, com tempo "0:47" (Bebas 110, `accent`), "RESTAM" acima e "DE 1:30" abaixo.
- **Card "PRÓXIMA SÉRIE":** exercício + série + carga/reps alvo.
- **Rodapé:** −15s / +15s / "INICIAR SÉRIE" (primário, flex 2).
- **Comportamento:** countdown regressivo; ao chegar a 0 → notificação local + som/vibração (ver Notificações). Mantém rodando em background.

### 9. Progresso — *acessível via Perfil/aba*
- Header "PROGRESSO" + segmented (7d/30d/90d/1a).
- **4 KPIs** (Treinos, Volume, PRs, Aderência) com delta colorido (success/warn).
- **Card de gráfico:** evolução de carga de um exercício — `fl_chart LineChart` com área degradê + ponto final destacado.
- **Card "Volume por grupo":** barras horizontais com % e tonelagem; grupos de foco em `accent`.

### 10. Perfil — *tab Perfil*
- Banner + avatar quadrado-arredondado grande (iniciais Bebas `accent`), nome Bebas 40, chips (objetivo, personal).
- **3 KPIs:** Treinos / Streak / PRs.
- **Lista de menu:** Dados pessoais, Medidas, Notificações (com badge), Preferências e unidades (← inclui o seletor de tema/acento), Conquistas.
- Botão "Sair da conta" em `danger`.

### 11. Meus Alunos (Personal Trainer)
- Header "MEUS ALUNOS" + eyebrow "Personal · Bruno R." + botão `+`.
- **3 KPIs:** Ativos / Treinaram hoje / Pendências.
- **Lista de alunos:** avatar iniciais + nome + objetivo/treino do dia + status colorido à direita (Concluiu=success, Treinando=accent, Descanso=faint, Pendente=warn) com bolinha.

### 12. Montar Treino (Personal Trainer)
- Header com voltar + "NOVO TREINO · JOÃO P." + ação "SALVAR" em `accent`.
- **Card de info:** nome do treino (input), chips de objetivo (Hipertrofia/Força/…) com scroll horizontal, seletor de dias do ciclo (S T Q Q S S D).
- **Card de sugestão IA:** borda em `accent@25%`, ícone raio, texto de recomendação + botões Aplicar / Ignorar.
- **Lista de exercícios editável:** handle de arrastar (`⋮⋮`), número, nome + séries/reps/carga, menu `⋮`. Botão tracejado "Adicionar exercício".
- **Rodapé fixo:** botão primário largura cheia "PUBLICAR PARA JOÃO".
- No Flutter: `ReorderableListView` para os exercícios; bottom sheet para editar série/reps/carga.

### 13. Conquistas
- Header "CONQUISTAS" + eyebrow "14 desbloqueadas · 8 a caminho".
- **Card de acento (destaque):** sequência atual "17 DIAS" com ícone de chama fantasma atrás.
- **Grade de medalhas (3 colunas):** ícone em círculo (`accent` se desbloqueada, `bg3`+faint se bloqueada), nome, e progresso mono (ex.: "84/100") nas bloqueadas.

### 14. Medidas Corporais
- Header com voltar + "MEDIDAS" + botão `+` (nova avaliação).
- **Card de gráfico:** evolução do peso em 8 semanas (`fl_chart LineChart`), valor grande Bebas + delta.
- **Grade de medidas (2 colunas):** Peso, % Gordura, Massa magra, Peito, Braço, Cintura — cada um com valor, unidade e delta colorido.

### 15. Preferências / Tema
- Header com voltar + "PREFERÊNCIAS".
- **Card "COR DE ACENTO":** 6 swatches circulares clicáveis (o seletor de tema nativo). O selecionado tem anel; mostra o nome do tema atual abaixo. Persiste via `shared_preferences`.
- **Card "UNIDADES":** segmented controls kg/lb e cm/in.
- **Card de toggles:** sons no cronômetro, vibração, notificação de descanso, lembrete diário, resumo semanal.

---

## Navegação & Comportamento

- **Shell com `BottomNavigationBar`** (5 itens, FAB central) para Aluno: Hoje, Semana, [Treino], Exercícios, Perfil. Use `IndexedStack` para preservar estado das abas. `go_router` recomendado para rotas.
- **Personal:** após login, a Home é **Meus Alunos**; tocar num aluno abre o perfil dele e a montagem de treino (a versão web tem a tela de "Cadastro de Treino" — reaproveite a lógica).
- **FAB** → abre *Treino em Execução* do treino de hoje.
- **Treino em Execução → Cronômetro:** "Concluir série" salva a série e empurra o cronômetro (full-screen ou bottom sheet alto). Ao terminar, volta para a próxima série.
- **Transições:** padrão do Material (`MaterialPageRoute`); o cronômetro pode subir como modal. Sem animações decorativas em loop.
- **Estados:** loading (skeleton com `bg2`), vazio ("nenhum treino — criar"), erro de validação nos campos (borda `danger`).

## Estado / Dados (sugestão)

Modelos mínimos: `User(role: aluno|personal)`, `Workout`, `Exercise`, `WorkoutExercise(sets, reps, load, rest)`, `SetLog(weight, reps, rir, done, isPR)`, `Session(startedAt, elapsed, logs)`, `BodyMeasure`, `Student` (para personal).
Gerência de estado: **Riverpod** ou **Provider**. Timer da sessão e do descanso em um controller dedicado que sobrevive à navegação. Persistência local: `shared_preferences` (tema, sessão em andamento) + um banco (`drift`/`isar`/SQLite) para histórico.

## Notificações (requisito do usuário)

Use [`flutter_local_notifications`](https://pub.dev/packages/flutter_local_notifications) (+ `timezone` para agendadas).

Casos de uso:
1. **Fim do descanso** — quando o cronômetro zera, notificação local imediata + som curto + vibração (`HapticFeedback.heavyImpact()`), mesmo com app em background. Canal "rest_timer", alta prioridade.
2. **Lembrete de treino do dia** — notificação agendada (ex.: 1h antes do horário habitual). Canal "daily_workout".
3. **Conquistas / PR** — ao registrar um PR, notificação de parabéns. Canal "achievements".
4. **Personal:** aluno concluiu/atrasou treino (push via backend → exibida localmente).

Lembre de pedir permissão (`requestPermission`) no iOS/Android 13+ e criar os `AndroidNotificationChannel`. Para o som ao fim do descanso mesmo com tela bloqueada, considere `audioplayers`/`just_audio` + manter o timer ativo (foreground service no Android se necessário).

## Pacotes recomendados

```yaml
dependencies:
  google_fonts: ^6.2.1          # fontes (ou empacote os .ttf)
  go_router: ^14.0.0            # navegação
  flutter_riverpod: ^2.5.0      # estado (ou provider)
  fl_chart: ^0.68.0             # gráficos de linha/barra
  flutter_local_notifications: ^17.0.0
  timezone: ^0.9.0              # notificações agendadas
  shared_preferences: ^2.2.0    # tema + prefs
  cached_network_image: ^3.3.0  # thumbnails de exercício
  # opcional: drift OU isar para histórico de treinos
```

## Arquitetura sugerida

```
lib/
  main.dart
  theme/
    forja_colors.dart
    forja_theme.dart        # ThemeData (dark) + TextTheme
    accent_theme.dart       # temas de acento + provider
  core/widgets/             # ForjaCard, Chip, PrimaryButton, KpiTile, SetRow, RestRing, TabScaffold...
  features/
    onboarding/
    auth/
    today/                  # dashboard
    week/
    library/                # biblioteca
    workout/                # execução + detalhe + cronômetro
    progress/
    profile/
    trainer/                # meus alunos + montagem de treino
  models/
```

## Tema base (ponto de partida)

```dart
ThemeData forjaTheme(AccentTheme a) {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: ForjaColors.bg0,
    colorScheme: ColorScheme.fromSeed(
      seedColor: a.accent,
      brightness: Brightness.dark,
    ).copyWith(
      primary: a.accent,
      onPrimary: a.fg,
      surface: ForjaColors.bg1,
      background: ForjaColors.bg0,
      error: ForjaColors.danger,
    ),
    textTheme: forjaTextTheme(ForjaColors.text),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: a.accent, foregroundColor: a.fg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600, letterSpacing: 0.5),
      ),
    ),
  );
}
```

---

## Arquivos de referência neste pacote

| Arquivo | O que é |
|---|---|
| `Forja Mobile.html` | **Canvas com as 15 telas mobile — abra no navegador (a referência visual definitiva).** A fonte condensada Bebas Neue só renderiza fielmente em navegador real; use este arquivo como verdade visual. |
| `mobile/` | Componentes React das telas mobile (referência de layout/estrutura). |
| `styles.css` | Tokens CSS originais (cores, tipografia, componentes) — fonte da verdade dos valores. |
| `mobile/mobile.css` | Tokens específicos do mobile (tab bar, segmented, KPIs). |
| `FORJA.html` + `screens-*.jsx` | Versão **web/desktop** do mesmo sistema (Dashboard, Treino, Semana, Biblioteca, Cadastro de Treino do Personal, Progresso, Perfil, Login) — útil como referência da lógica do Personal e telas largas. |
| `brand/` | Logo FORJA (SVG/PNG), favicon, folha de marca. |
| `primitives.jsx` | Ícones (SVG) usados — replicáveis com `Icon`/`lucide_icons` no Flutter. |

> Ícones: o design usa um set linear (stroke ~1.8). No Flutter use [`lucide_icons`](https://pub.dev/packages/lucide_icons) ou `Icons` do Material — equivalências: home→home, flame→local_fire_department, calendar→calendar_today, dumbbell→fitness_center, chart→bar_chart, timer→timer, search→search, trophy→emoji_events, user→person, bell→notifications.
```
```

Bom desenvolvimento! 🏋️
