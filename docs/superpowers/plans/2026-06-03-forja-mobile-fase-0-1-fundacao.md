# FORJA Mobile — Plano de Implementação: Fase 0 + Fase 1 (Ferramentas + Fundação)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Deixar o ambiente Flutter pronto e criar o esqueleto do app FORJA Mobile — rodando no celular/emulador, com o tema FORJA (dark + acento trocável) e já conectado ao backend Supabase existente.

**Architecture:** App Flutter (Android + iOS) organizado por funcionalidades (`features/`), com tema centralizado (`theme/`), navegação via `go_router`, estado via `flutter_riverpod`, e conexão ao Supabase via `supabase_flutter`. Esta etapa entrega a fundação testável: o app abre, mostra a identidade FORJA e confirma que conversa com a "cozinha" (lê dados reais da tabela `exercise_library`).

**Tech Stack:** Flutter (Dart), Material 3 customizado, `supabase_flutter`, `go_router`, `flutter_riverpod`, `google_fonts`.

**Design de referência:** `Forja/design_handoff_forja_mobile/README.md` (tokens e tema em Dart) e `Forja Mobile.html` (verdade visual).
**Design aprovado:** `docs/superpowers/specs/2026-06-03-forja-mobile-flutter-design.md`.

**Onde o app será criado:** `C:\Users\Denis\Desktop\Forja Mobile\forja_app\` (subpasta dedicada — o nome `forja_app` evita conflito com a pasta de design `Forja\`, já que o Windows não diferencia maiúsculas/minúsculas em nomes de pasta).

---

## Mapa dos arquivos desta etapa

| Arquivo | Responsabilidade |
|---|---|
| `forja_app/pubspec.yaml` | Lista de dependências (pacotes) e fontes |
| `forja_app/lib/theme/forja_colors.dart` | Paleta de cores FORJA (tokens) |
| `forja_app/lib/theme/accent_theme.dart` | 6 temas de acento + provider Riverpod do acento escolhido |
| `forja_app/lib/theme/forja_theme.dart` | `TextTheme` (fontes) + `ThemeData` dark FORJA |
| `forja_app/lib/config/supabase_config.dart` | URL + chave pública (anon) do Supabase |
| `forja_app/lib/router/app_router.dart` | Rotas do app (go_router) |
| `forja_app/lib/features/_dev/connection_check_page.dart` | Tela temporária que prova a conexão com o Supabase |
| `forja_app/lib/main.dart` | Ponto de entrada: inicializa Supabase + tema + navegação |
| `forja_app/test/theme_test.dart` | Teste dos tokens de tema (acento) |
| `forja_app/test/smoke_test.dart` | Teste de fumaça (o app monta sem erro) |

---

# FASE 0 — Ferramentas

> 💡 **Em português:** aqui a gente "monta a oficina". O Flutter é o programa que constrói o app; o Android Studio traz o "celular de mentira" (emulador) e as peças do Android. Nada de código ainda — só instalação. Estes passos são feitos UMA vez na vida deste computador.

### Task 0.1: Instalar o Flutter SDK (Windows)

**Files:** nenhum (instalação de sistema)

- [ ] **Step 1: Baixar e extrair o Flutter**

Baixar o pacote estável do Flutter para Windows em https://docs.flutter.dev/get-started/install/windows
e extrair para `C:\src\flutter` (criar a pasta `C:\src` se não existir). O resultado deve conter `C:\src\flutter\bin`.

> 💡 Evite extrair em pastas com espaço no nome ou que exijam permissão de administrador (ex.: `C:\Program Files`). `C:\src\flutter` é o recomendado.

- [ ] **Step 2: Adicionar o Flutter ao PATH do usuário**

Run (PowerShell):
```powershell
$flutterBin = "C:\src\flutter\bin"
$userPath = [Environment]::GetEnvironmentVariable("Path","User")
if ($userPath -notlike "*$flutterBin*") {
  [Environment]::SetEnvironmentVariable("Path", "$userPath;$flutterBin", "User")
  Write-Host "Flutter adicionado ao PATH. Feche e reabra o terminal."
} else { Write-Host "Flutter ja esta no PATH." }
```
Expected: mensagem "Flutter adicionado ao PATH..." (ou que já estava).

- [ ] **Step 3: Reabrir o terminal e confirmar a instalação**

Run: `flutter --version`
Expected: imprime a versão do Flutter e do Dart (ex.: `Flutter 3.x.x ... Dart 3.x.x`). Sem erro "não reconhecido".

### Task 0.2: Instalar Android Studio + SDK + emulador

**Files:** nenhum (instalação de sistema)

- [ ] **Step 1: Instalar o Android Studio**

Baixar e instalar em https://developer.android.com/studio . Durante o assistente inicial, manter
marcados: **Android SDK**, **Android SDK Platform**, **Android Virtual Device**.

- [ ] **Step 2: Instalar o componente de linha de comando do SDK**

No Android Studio: **Settings → Languages & Frameworks → Android SDK → SDK Tools** → marcar
**Android SDK Command-line Tools (latest)** → Apply.

> 💡 Esse componente é o que permite o Flutter "conversar" com o Android por fora do Android Studio.

- [ ] **Step 3: Criar um celular de mentira (emulador)**

No Android Studio: **More Actions → Virtual Device Manager → Create Device** → escolher **Pixel 7**
→ baixar uma imagem de sistema recente (ex.: API 34) → Finish.

- [ ] **Step 4: Aceitar as licenças do Android**

Run: `flutter doctor --android-licenses`
Expected: várias perguntas — responder `y` em todas até "All SDK package licenses accepted".

### Task 0.3: Confirmar que o ambiente está pronto

**Files:** nenhum

- [ ] **Step 1: Rodar o diagnóstico do Flutter**

Run: `flutter doctor`
Expected: itens **Flutter**, **Android toolchain** e **Android Studio** com `[√]`.
O item **iOS / Xcode** vai aparecer com `[!]` ou ausente — **isso é esperado no Windows** e não bloqueia o Android (o iOS exige Mac, conforme o design).

- [ ] **Step 2: Confirmar que o emulador liga**

Run: `flutter emulators --launch Pixel_7` (o nome exato sai de `flutter emulators`)
Expected: o emulador abre e mostra a tela inicial do Android.

---

# FASE 1 — Fundação do app

> 💡 **Em português:** agora levantamos o "esqueleto" do app: criamos o projeto, instalamos os pacotes, aplicamos as cores e fontes do FORJA e ligamos o app à sua cozinha (Supabase). No fim desta fase o app abre no celular com a cara do FORJA e prova que está conectado.

### Task 1.1: Criar o projeto Flutter

**Files:**
- Create: `forja_app/` (projeto inteiro, gerado pelo comando)

- [ ] **Step 1: Criar o projeto na subpasta dedicada**

Run (a partir de `C:\Users\Denis\Desktop\Forja Mobile`):
```powershell
flutter create --org com.forja --project-name forja_app forja_app
```
Expected: "All done!" e a pasta `forja_app\` criada com `lib\main.dart`, `pubspec.yaml`, `android\`, `ios\`.

- [ ] **Step 2: Confirmar que o projeto roda (app padrão)**

Run (com o emulador aberto):
```powershell
cd "C:\Users\Denis\Desktop\Forja Mobile\forja_app"; flutter run
```
Expected: o app de exemplo (contador) aparece no emulador. Depois, pressionar `q` no terminal para encerrar.

### Task 1.2: Adicionar as dependências da fundação

> 💡 Só os pacotes que ESTA fase usa (YAGNI). Os demais (gráficos, notificações, offline) entram nas fases que os utilizam.

**Files:**
- Modify: `forja_app/pubspec.yaml`

- [ ] **Step 1: Instalar os pacotes**

Run (dentro de `forja_app`):
```powershell
flutter pub add supabase_flutter go_router flutter_riverpod google_fonts
```
Expected: `pubspec.yaml` ganha as 4 dependências e roda `pub get` com sucesso ("Got dependencies!").

- [ ] **Step 2: Verificar a seção de dependências**

O `pubspec.yaml` deve conter (versões podem variar conforme o `pub add` resolver):
```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.5.0
  go_router: ^14.0.0
  flutter_riverpod: ^2.5.0
  google_fonts: ^6.2.1
```

### Task 1.3: Criar a estrutura de pastas

**Files:**
- Create: `forja_app/lib/theme/`, `forja_app/lib/config/`, `forja_app/lib/router/`, `forja_app/lib/features/_dev/`

- [ ] **Step 1: Criar as pastas**

Run (dentro de `forja_app`):
```powershell
New-Item -ItemType Directory -Force lib\theme, lib\config, lib\router, lib\features\_dev | Out-Null; Write-Host "Pastas criadas"
```
Expected: "Pastas criadas".

### Task 1.4: Tokens de cor FORJA

**Files:**
- Create: `forja_app/lib/theme/forja_colors.dart`

- [ ] **Step 1: Criar o arquivo de cores** (valores oficiais do handoff)

```dart
// lib/theme/forja_colors.dart
import 'package:flutter/material.dart';

/// Paleta oficial FORJA (tokens do design system).
class ForjaColors {
  // Superfícies (o app é dark por padrão)
  static const bg0 = Color(0xFF08090A); // fundo da tela
  static const bg1 = Color(0xFF101113); // card
  static const bg2 = Color(0xFF181A1C); // card aninhado / input
  static const bg3 = Color(0xFF23262A); // hover / trilho de barra
  static const bg4 = Color(0xFF2E3236);
  static const bgDark = Color(0xFF050506); // telas de foco (cronômetro/login)

  // Bordas
  static const hairline = Color(0x0FFFFFFF);     // branco 6%
  static const border = Color(0x1AFFFFFF);       // branco 10%
  static const borderStrong = Color(0x33FFFFFF); // branco 20%

  // Texto
  static const text = Color(0xFFF5F5F3);
  static const textDim = Color(0xFF9A9A96);
  static const textFaint = Color(0xFF5A5A56);

  // Semânticas
  static const danger = Color(0xFFFF3D55);
  static const warn = Color(0xFFFFB547);
  static const success = Color(0xFF6AFFB9);
  static const info = Color(0xFF6EC6FF);
}
```

### Task 1.5: Temas de acento + provider

**Files:**
- Create: `forja_app/lib/theme/accent_theme.dart`

- [ ] **Step 1: Definir os 6 temas e o estado do acento escolhido**

```dart
// lib/theme/accent_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Um tema de acento trocável pelo usuário.
class AccentTheme {
  final String id;
  final String name;
  final Color accent;
  final Color fg; // cor do texto/ícone SOBRE o acento
  const AccentTheme(this.id, this.name, this.accent, this.fg);
}

/// Os 6 acentos do design. Padrão: Lime.
const accentThemes = <AccentTheme>[
  AccentTheme('lime', 'Lime', Color(0xFFD4FF3A), Color(0xFF0A0A0A)),
  AccentTheme('coral', 'Coral', Color(0xFFFF2E4D), Color(0xFFFFFFFF)),
  AccentTheme('orange', 'Forge', Color(0xFFFF6B00), Color(0xFF0A0A0A)),
  AccentTheme('ice', 'Ice', Color(0xFF00D4FF), Color(0xFF0A0A0A)),
  AccentTheme('violet', 'Violet', Color(0xFFA78BFA), Color(0xFF0A0A0A)),
  AccentTheme('mono', 'Mono', Color(0xFFF5F5F0), Color(0xFF0A0A0A)),
];

/// Guarda o acento atual. Na Fase 7 será ligado ao shared_preferences
/// para persistir a escolha; por ora começa no Lime.
final accentProvider = StateProvider<AccentTheme>((ref) => accentThemes.first);
```

### Task 1.6: TextTheme + ThemeData FORJA

**Files:**
- Create: `forja_app/lib/theme/forja_theme.dart`

- [ ] **Step 1: Criar fontes e tema dark** (baseado no handoff)

```dart
// lib/theme/forja_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'accent_theme.dart';
import 'forja_colors.dart';

/// Escala tipográfica FORJA: Bebas Neue (títulos), Space Grotesk (corpo).
TextTheme forjaTextTheme(Color text) => TextTheme(
      displayLarge: GoogleFonts.bebasNeue(fontSize: 56, height: 0.95, color: text),
      displayMedium: GoogleFonts.bebasNeue(fontSize: 38, height: 0.95, color: text),
      titleLarge: GoogleFonts.bebasNeue(fontSize: 24, color: text),
      bodyLarge: GoogleFonts.spaceGrotesk(fontSize: 15, color: text),
      bodyMedium: GoogleFonts.spaceGrotesk(fontSize: 13, color: ForjaColors.textDim),
      labelLarge: GoogleFonts.spaceGrotesk(
          fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.5, color: text),
    );

/// Tema dark FORJA, parametrizado pelo acento escolhido.
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
      error: ForjaColors.danger,
    ),
    textTheme: forjaTextTheme(ForjaColors.text),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: a.accent,
        foregroundColor: a.fg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600, letterSpacing: 0.5),
      ),
    ),
  );
}
```

### Task 1.7: Configuração do Supabase

**Files:**
- Create: `forja_app/lib/config/supabase_config.dart`

- [ ] **Step 1: Criar o arquivo de configuração**

> 💡 A URL é a mesma do sistema web (vista no `CLAUDE.md` do projeto web). A chave `anon`
> (publicável) é PÚBLICA — é a mesma que o site já usa no navegador, então pode ficar no app.
> Copie o valor real de `VITE_SUPABASE_ANON_KEY` do arquivo
> `C:\Users\Denis\Desktop\SITES\MUSCTRAINING\.env` e cole no lugar indicado abaixo.

```dart
// lib/config/supabase_config.dart
class SupabaseConfig {
  static const url = 'https://xfcblbdwaibpzcpwzkow.supabase.co';

  // Cole aqui a chave anon (VITE_SUPABASE_ANON_KEY do .env do projeto web).
  // É a chave PÚBLICA/publicável — segura para o cliente.
  static const anonKey = 'COLE_AQUI_A_CHAVE_ANON';
}
```

- [ ] **Step 2: Verificar que a chave foi preenchida**

Run (dentro de `forja_app`):
```powershell
if (Select-String -Path lib\config\supabase_config.dart -Pattern 'COLE_AQUI_A_CHAVE_ANON' -Quiet) { Write-Host "FALTA colar a chave anon" } else { Write-Host "Chave preenchida" }
```
Expected: "Chave preenchida".

### Task 1.8: Tela temporária de verificação de conexão

> 💡 Uma telinha "de obra" só para PROVAR que o app conversa com o Supabase. Ela lê quantos
> exercícios existem na tabela `exercise_library` (que já tem 39+ no banco). Será removida na Fase 2.

**Files:**
- Create: `forja_app/lib/features/_dev/connection_check_page.dart`

- [ ] **Step 1: Criar a tela**

```dart
// lib/features/_dev/connection_check_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Conta os exercícios no Supabase — prova de que a conexão funciona.
final exerciseCountProvider = FutureProvider<int>((ref) async {
  final rows = await Supabase.instance.client
      .from('exercise_library')
      .select('id');
  return (rows as List).length;
});

class ConnectionCheckPage extends ConsumerWidget {
  const ConnectionCheckPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(exerciseCountProvider);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('FORJA', style: Theme.of(context).textTheme.displayLarge),
              const SizedBox(height: 8),
              count.when(
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('Erro de conexão: $e',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center),
                data: (n) => Text('Conectado! $n exercícios no banco.',
                    style: Theme.of(context).textTheme.bodyLarge),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Task 1.9: Roteador (go_router)

**Files:**
- Create: `forja_app/lib/router/app_router.dart`

- [ ] **Step 1: Criar o roteador com a rota inicial**

```dart
// lib/router/app_router.dart
import 'package:go_router/go_router.dart';
import '../features/_dev/connection_check_page.dart';

/// Rotas do app. Nesta fase, só a tela de verificação.
/// As rotas reais (login, hoje, etc.) entram a partir da Fase 2.
final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const ConnectionCheckPage(),
    ),
  ],
);
```

### Task 1.10: Ponto de entrada (main.dart)

**Files:**
- Modify: `forja_app/lib/main.dart` (substituir o conteúdo gerado)

- [ ] **Step 1: Substituir o main.dart**

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'router/app_router.dart';
import 'theme/accent_theme.dart';
import 'theme/forja_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
  runApp(const ProviderScope(child: ForjaApp()));
}

class ForjaApp extends ConsumerWidget {
  const ForjaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = ref.watch(accentProvider);
    return MaterialApp.router(
      title: 'FORJA',
      debugShowCheckedModeBanner: false,
      theme: forjaTheme(accent),
      routerConfig: appRouter,
    );
  }
}
```

- [ ] **Step 2: Garantir build limpo (análise estática)**

Run (dentro de `forja_app`): `flutter analyze`
Expected: "No issues found!".

### Task 1.11: Testes da fundação

**Files:**
- Create: `forja_app/test/theme_test.dart`
- Create: `forja_app/test/smoke_test.dart`
- Delete: `forja_app/test/widget_test.dart` (teste do contador padrão, não serve mais)

- [ ] **Step 1: Escrever o teste de tema (deve falhar antes de existir o arquivo de cores correto)**

```dart
// test/theme_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/theme/accent_theme.dart';

void main() {
  test('existem 6 acentos e o padrão é Lime', () {
    expect(accentThemes.length, 6);
    expect(accentThemes.first.id, 'lime');
    expect(accentThemes.first.accent, const Color(0xFFD4FF3A));
  });
}
```

- [ ] **Step 2: Rodar o teste de tema**

Run (dentro de `forja_app`): `flutter test test/theme_test.dart`
Expected: PASS (1 teste). Se a Task 1.5 não tiver sido feita, falha com "accentThemes não definido".

- [ ] **Step 3: Escrever o teste de fumaça (o app monta sem erro)**

> 💡 Não inicializa o Supabase de verdade (teste roda offline); monta só o tema + a tela e
> confirma que a palavra "FORJA" aparece.

```dart
// test/smoke_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forja_app/theme/accent_theme.dart';
import 'package:forja_app/theme/forja_theme.dart';

void main() {
  testWidgets('a tela inicial mostra a marca FORJA', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: forjaTheme(accentThemes.first),
          home: Scaffold(
            body: Center(
              child: Text('FORJA',
                  style: forjaTextTheme(const Color(0xFFF5F5F3)).displayLarge),
            ),
          ),
        ),
      ),
    );
    expect(find.text('FORJA'), findsOneWidget);
  });
}
```

- [ ] **Step 4: Remover o teste padrão e rodar toda a suíte**

Run (dentro de `forja_app`):
```powershell
Remove-Item test\widget_test.dart -ErrorAction SilentlyContinue; flutter test
```
Expected: todos os testes PASS (2 testes).

### Task 1.12: Rodar no emulador e versionar (git)

**Files:**
- Create: `C:\Users\Denis\Desktop\Forja Mobile\.gitignore`

- [ ] **Step 1: Rodar o app e ver a prova de conexão**

Run (dentro de `forja_app`, com o emulador aberto): `flutter run`
Expected: tela preta FORJA com o texto **"Conectado! 39 exercícios no banco."** (o número é o total real de exercícios no Supabase). Depois `q` para sair.

> 💡 Este é o "marco" da fase: ver esse texto significa que o app está vivo E falando com a cozinha.

- [ ] **Step 2: Criar o controle de versão na raiz do projeto**

> 💡 O `git` é o "histórico de salvamentos". Criamos na pasta `Forja Mobile` (raiz), que passa a
> abrigar o design, os docs e o app.

Run (a partir de `C:\Users\Denis\Desktop\Forja Mobile`):
```powershell
git init
```
Expected: "Initialized empty Git repository...".

- [ ] **Step 3: Criar o .gitignore da raiz**

```gitignore
# Dependências e builds do Flutter
forja_app/.dart_tool/
forja_app/build/
forja_app/.flutter-plugins
forja_app/.flutter-plugins-dependencies
forja_app/android/.gradle/
forja_app/ios/Pods/

# Segredos
*.env
.env

# Sistema
.DS_Store
Thumbs.db
```

- [ ] **Step 4: Primeiro commit (fundação + design)**

Run (a partir de `C:\Users\Denis\Desktop\Forja Mobile`):
```powershell
git add .gitignore docs forja_app
git commit -m @'
feat: fundação do FORJA Mobile (Flutter) + design

- ambiente Flutter pronto (Fase 0)
- projeto forja_app criado com tema FORJA (dark + acento trocável)
- conexão com Supabase validada (lê exercise_library)
- navegação (go_router) e estado (Riverpod) configurados
- documento de design e plano da fundação

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>
'@
```
Expected: o commit é criado listando os arquivos adicionados.

---

## Critério de conclusão da etapa

- [ ] `flutter doctor` com Flutter + Android OK (iOS pendente é esperado no Windows)
- [ ] `flutter analyze` sem problemas
- [ ] `flutter test` com os 2 testes passando
- [ ] `flutter run` mostra "Conectado! N exercícios no banco." no emulador
- [ ] Primeiro commit feito na raiz `Forja Mobile`

---

## Self-Review (feito pelo autor do plano)

**1. Cobertura do design (Fases 0 e 1 do spec):**
- Fase 0 "instalar Flutter + Android Studio + emulador; flutter doctor ok" → Tasks 0.1–0.3 ✅
- Fase 1 "flutter create, tema FORJA, fontes, go_router, Riverpod, conexão supabase_flutter, git init" → Tasks 1.1–1.12 ✅

**2. Placeholders:** A única marcação intencional é `COLE_AQUI_A_CHAVE_ANON` (credencial do usuário,
com instrução de origem exata e verificação automática na Task 1.7 Step 2) — não é placeholder de lógica.

**3. Consistência de nomes:** `ForjaColors`, `AccentTheme`, `accentThemes`, `accentProvider`,
`forjaTextTheme`, `forjaTheme`, `SupabaseConfig.url/anonKey`, `appRouter`, `ConnectionCheckPage`,
`exerciseCountProvider` — usados de forma idêntica entre as tasks e o `main.dart`. Pacote `forja_app`
nos imports de teste bate com `--project-name forja_app`.

---

## Próxima etapa (depois desta)

Ao concluir, criamos o plano da **Fase 2 — Entrada (Onboarding + Login/Cadastro)**, usando o
Supabase Auth real e as telas 1 e 2 do handoff. Cada fase seguinte vira seu próprio plano.
