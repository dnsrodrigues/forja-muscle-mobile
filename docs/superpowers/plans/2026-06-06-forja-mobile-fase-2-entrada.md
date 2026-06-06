# FORJA Mobile — Fase 2 (Entrada): Plano de Implementação

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Entregar Onboarding (3 passos com shader) + Login/Cadastro (Supabase Auth) + o "porteiro" de navegação que decide a tela inicial, com sessão persistente e logout.

**Architecture:** Navegação reativa central (Opção A): `GoRouter` com `redirect` puro + `refreshListenable` ligado ao stream de auth do Supabase. Estado via Riverpod (providers de auth + flag de onboarding). Lógica pura (validação, redirect, mensagens de erro) isolada em funções testáveis por TDD; o "encanamento" com Supabase é verificado por compilação + teste manual no Chrome.

**Tech Stack:** Flutter 3.44 · Dart 3.x · flutter_riverpod 3.x · go_router 17.x · supabase_flutter 2.x · shared_preferences · google_fonts · FragmentProgram (shaders).

**Spec:** `docs/superpowers/specs/2026-06-06-forja-mobile-fase-2-entrada-design.md`

**Diretório de trabalho:** todos os caminhos são relativos a `forja_app/`. Rodar comandos `flutter` dentro de `forja_app/`.

---

## Mapa de arquivos (responsabilidade de cada um)

```
forja_app/
├── pubspec.yaml                                  [MOD] + shared_preferences + seção shaders
├── shaders/
│   └── forja_wave.frag                           [NEW] shader GLSL das ondas
├── lib/
│   ├── main.dart                                 [MOD] carrega prefs, override, router via provider
│   ├── services/
│   │   └── onboarding_prefs.dart                 [NEW] le/grava flag onboarding_visto
│   ├── router/
│   │   ├── redirect_logic.dart                   [NEW] resolveRedirect() — função pura
│   │   ├── go_router_refresh_stream.dart         [NEW] ponte Stream→Listenable
│   │   ├── auth_providers.dart                   [NEW] providers de auth + onboarding + router
│   │   └── app_router.dart                       [DEL] (substituído por auth_providers.dart)
│   ├── features/
│   │   ├── _dev/connection_check_page.dart       [DEL] cumpriu o papel
│   │   ├── auth/
│   │   │   ├── auth_validators.dart              [NEW] validateEmail/validatePassword
│   │   │   ├── auth_messages.dart                [NEW] mapAuthErrorToMessage
│   │   │   ├── auth_controller.dart              [NEW] AsyncNotifier signIn/signUp/signOut
│   │   │   └── auth_page.dart                    [NEW] UI login/cadastro
│   │   ├── onboarding/
│   │   │   ├── onboarding_data.dart              [NEW] conteúdo dos 3 slides
│   │   │   └── onboarding_page.dart              [NEW] PageView + rodapé
│   │   ├── home/
│   │   │   └── home_placeholder_page.dart        [NEW] tela inicial provisória
│   │   └── splash/
│   │       └── splash_page.dart                  [NEW] tela-gate instantânea ("/")
│   └── core/widgets/
│       ├── forja_primary_button.dart             [NEW] botão primário (com loading)
│       ├── forja_text_field.dart                 [NEW] campo de texto FORJA
│       ├── forja_segmented.dart                  [NEW] segmented control 2 opções
│       └── forja_shader_art.dart                 [NEW] widget da arte animada (+ fallback)
└── test/
    ├── services/onboarding_prefs_test.dart       [NEW]
    ├── router/redirect_logic_test.dart           [NEW]
    ├── features/auth/auth_validators_test.dart   [NEW]
    ├── features/auth/auth_messages_test.dart     [NEW]
    ├── router/onboarding_provider_test.dart      [NEW]
    ├── core/widgets/forja_segmented_test.dart    [NEW]
    ├── features/onboarding/onboarding_page_test.dart [NEW]
    ├── features/auth/auth_page_test.dart         [NEW]
    └── features/home/home_placeholder_test.dart  [NEW]
```

**Rotas finais:** `/` (splash-gate) · `/onboarding` · `/auth` · `/home`.

---

## Task 1: Dependência shared_preferences + serviço OnboardingPrefs

**Files:**
- Modify: `pubspec.yaml` (dependencies)
- Create: `lib/services/onboarding_prefs.dart`
- Test: `test/services/onboarding_prefs_test.dart`

- [ ] **Step 1: Adicionar a dependência**

Editar `pubspec.yaml`, na seção `dependencies:`, logo abaixo de `google_fonts: ^8.1.0`, adicionar:

```yaml
  shared_preferences: ^2.3.2
```

- [ ] **Step 2: Instalar**

Run: `flutter pub get`
Expected: "Got dependencies!" e `shared_preferences` resolvido.

- [ ] **Step 3: Escrever o teste que falha**

Criar `test/services/onboarding_prefs_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:forja_app/services/onboarding_prefs.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('isSeen é false quando nada foi gravado', () async {
    SharedPreferences.setMockInitialValues({});
    expect(await OnboardingPrefs.isSeen(), false);
  });

  test('markSeen grava e isSeen passa a ser true', () async {
    SharedPreferences.setMockInitialValues({});
    await OnboardingPrefs.markSeen();
    expect(await OnboardingPrefs.isSeen(), true);
  });
}
```

- [ ] **Step 4: Rodar e ver falhar**

Run: `flutter test test/services/onboarding_prefs_test.dart`
Expected: FAIL — "Target of URI doesn't exist: 'package:forja_app/services/onboarding_prefs.dart'".

- [ ] **Step 5: Implementar o serviço**

Criar `lib/services/onboarding_prefs.dart`:

```dart
import 'package:shared_preferences/shared_preferences.dart';

/// Lembra se o usuário já viu o onboarding (persiste no aparelho).
class OnboardingPrefs {
  static const _key = 'onboarding_visto';

  static Future<bool> isSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  static Future<void> markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}
```

- [ ] **Step 6: Rodar e ver passar**

Run: `flutter test test/services/onboarding_prefs_test.dart`
Expected: PASS (2 testes).

- [ ] **Step 7: Commit**

```bash
git add pubspec.yaml pubspec.lock lib/services/onboarding_prefs.dart test/services/onboarding_prefs_test.dart
git commit -m "feat(fase2): serviço de persistência do onboarding (shared_preferences)"
```

---

## Task 2: Lógica de redirecionamento (função pura `resolveRedirect`)

**Files:**
- Create: `lib/router/redirect_logic.dart`
- Test: `test/router/redirect_logic_test.dart`

- [ ] **Step 1: Escrever o teste que falha**

Criar `test/router/redirect_logic_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/router/redirect_logic.dart';

void main() {
  group('resolveRedirect', () {
    test('logado em "/" vai para /home', () {
      expect(
        resolveRedirect(loggedIn: true, onboardingSeen: true, location: '/'),
        '/home',
      );
    });

    test('logado já em /home permanece (null)', () {
      expect(
        resolveRedirect(loggedIn: true, onboardingSeen: true, location: '/home'),
        isNull,
      );
    });

    test('logado em /auth é mandado para /home', () {
      expect(
        resolveRedirect(loggedIn: true, onboardingSeen: true, location: '/auth'),
        '/home',
      );
    });

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

    test('deslogado tentando /auth sem ter visto onboarding volta para /onboarding', () {
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

    test('deslogado tentando /home é mandado para /auth', () {
      expect(
        resolveRedirect(loggedIn: false, onboardingSeen: true, location: '/home'),
        '/auth',
      );
    });
  });
}
```

- [ ] **Step 2: Rodar e ver falhar**

Run: `flutter test test/router/redirect_logic_test.dart`
Expected: FAIL — arquivo `redirect_logic.dart` não existe.

- [ ] **Step 3: Implementar a função**

Criar `lib/router/redirect_logic.dart`:

```dart
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
  final inAuth = location == '/auth';

  if (loggedIn) {
    // Usuário logado não deve ver splash, onboarding nem login.
    if (location == '/' || inOnboarding || inAuth) return '/home';
    return null;
  }

  // A partir daqui: NÃO está logado.
  if (!onboardingSeen) {
    return inOnboarding ? null : '/onboarding';
  }

  // Onboarding já visto e não logado → tela de login.
  return inAuth ? null : '/auth';
}
```

- [ ] **Step 4: Rodar e ver passar**

Run: `flutter test test/router/redirect_logic_test.dart`
Expected: PASS (9 testes).

- [ ] **Step 5: Commit**

```bash
git add lib/router/redirect_logic.dart test/router/redirect_logic_test.dart
git commit -m "feat(fase2): lógica pura de redirecionamento do porteiro"
```

---

## Task 3: Validação de e-mail e senha (funções puras)

**Files:**
- Create: `lib/features/auth/auth_validators.dart`
- Test: `test/features/auth/auth_validators_test.dart`

- [ ] **Step 1: Escrever o teste que falha**

Criar `test/features/auth/auth_validators_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/features/auth/auth_validators.dart';

void main() {
  group('validateEmail', () {
    test('vazio retorna mensagem', () {
      expect(validateEmail(''), isNotNull);
    });
    test('sem @ é inválido', () {
      expect(validateEmail('joao.com'), isNotNull);
    });
    test('válido retorna null', () {
      expect(validateEmail('joao@forja.com'), isNull);
    });
    test('ignora espaços nas pontas', () {
      expect(validateEmail('  joao@forja.com  '), isNull);
    });
  });

  group('validatePassword', () {
    test('vazia retorna mensagem', () {
      expect(validatePassword(''), isNotNull);
    });
    test('curta (<6) retorna mensagem', () {
      expect(validatePassword('123'), isNotNull);
    });
    test('com 6+ caracteres retorna null', () {
      expect(validatePassword('123456'), isNull);
    });
  });
}
```

- [ ] **Step 2: Rodar e ver falhar**

Run: `flutter test test/features/auth/auth_validators_test.dart`
Expected: FAIL — arquivo não existe.

- [ ] **Step 3: Implementar**

Criar `lib/features/auth/auth_validators.dart`:

```dart
/// Valida o e-mail. Retorna mensagem de erro ou `null` se válido.
String? validateEmail(String value) {
  final v = value.trim();
  if (v.isEmpty) return 'Informe seu e-mail';
  final re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  if (!re.hasMatch(v)) return 'E-mail inválido';
  return null;
}

/// Valida a senha. Retorna mensagem de erro ou `null` se válida.
String? validatePassword(String value) {
  if (value.isEmpty) return 'Informe sua senha';
  if (value.length < 6) return 'A senha precisa de ao menos 6 caracteres';
  return null;
}
```

- [ ] **Step 4: Rodar e ver passar**

Run: `flutter test test/features/auth/auth_validators_test.dart`
Expected: PASS (7 testes).

- [ ] **Step 5: Commit**

```bash
git add lib/features/auth/auth_validators.dart test/features/auth/auth_validators_test.dart
git commit -m "feat(fase2): validação de e-mail e senha"
```

---

## Task 4: Tradução de erros de auth para mensagens amigáveis

**Files:**
- Create: `lib/features/auth/auth_messages.dart`
- Test: `test/features/auth/auth_messages_test.dart`

- [ ] **Step 1: Escrever o teste que falha**

Criar `test/features/auth/auth_messages_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:forja_app/features/auth/auth_messages.dart';

void main() {
  test('credenciais inválidas → mensagem amigável', () {
    final msg = mapAuthErrorToMessage(
      const AuthException('Invalid login credentials'),
    );
    expect(msg, 'E-mail ou senha incorretos');
  });

  test('e-mail já registrado → mensagem amigável', () {
    final msg = mapAuthErrorToMessage(
      const AuthException('User already registered'),
    );
    expect(msg, 'Este e-mail já está em uso');
  });

  test('erro genérico (não-AuthException) → mensagem de conexão', () {
    final msg = mapAuthErrorToMessage(Exception('socket'));
    expect(msg, contains('conexão'));
  });
}
```

- [ ] **Step 2: Rodar e ver falhar**

Run: `flutter test test/features/auth/auth_messages_test.dart`
Expected: FAIL — arquivo não existe.

- [ ] **Step 3: Implementar**

Criar `lib/features/auth/auth_messages.dart`:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

/// Converte um erro de autenticação em uma mensagem clara em PT-BR.
String mapAuthErrorToMessage(Object error) {
  if (error is AuthException) {
    final msg = error.message.toLowerCase();
    if (msg.contains('invalid login credentials')) {
      return 'E-mail ou senha incorretos';
    }
    if (msg.contains('already registered') ||
        msg.contains('already been registered') ||
        msg.contains('user already')) {
      return 'Este e-mail já está em uso';
    }
    if (msg.contains('password')) {
      return 'Senha inválida (mínimo 6 caracteres)';
    }
    return 'Não foi possível concluir. Tente novamente.';
  }
  return 'Algo deu errado. Verifique sua conexão e tente de novo.';
}
```

- [ ] **Step 4: Rodar e ver passar**

Run: `flutter test test/features/auth/auth_messages_test.dart`
Expected: PASS (3 testes).

- [ ] **Step 5: Commit**

```bash
git add lib/features/auth/auth_messages.dart test/features/auth/auth_messages_test.dart
git commit -m "feat(fase2): mensagens de erro de auth amigáveis em PT-BR"
```

---

## Task 5: Providers de onboarding (Riverpod) + teste de estado

**Files:**
- Create: `lib/router/auth_providers.dart` (parte 1: onboarding; auth entra na Task 6)
- Test: `test/router/onboarding_provider_test.dart`

- [ ] **Step 1: Escrever o teste que falha**

Criar `test/router/onboarding_provider_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:forja_app/router/auth_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('valor inicial vem do override', () {
    final container = ProviderContainer(
      overrides: [initialOnboardingSeenProvider.overrideWithValue(true)],
    );
    addTearDown(container.dispose);
    expect(container.read(onboardingSeenProvider), true);
  });

  test('markSeen muda o estado para true', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer(
      overrides: [initialOnboardingSeenProvider.overrideWithValue(false)],
    );
    addTearDown(container.dispose);
    expect(container.read(onboardingSeenProvider), false);
    await container.read(onboardingSeenProvider.notifier).markSeen();
    expect(container.read(onboardingSeenProvider), true);
  });
}
```

- [ ] **Step 2: Rodar e ver falhar**

Run: `flutter test test/router/onboarding_provider_test.dart`
Expected: FAIL — `auth_providers.dart` não existe.

- [ ] **Step 3: Implementar (somente a parte de onboarding por enquanto)**

Criar `lib/router/auth_providers.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/onboarding_prefs.dart';

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
```

- [ ] **Step 4: Rodar e ver passar**

Run: `flutter test test/router/onboarding_provider_test.dart`
Expected: PASS (2 testes).

- [ ] **Step 5: Commit**

```bash
git add lib/router/auth_providers.dart test/router/onboarding_provider_test.dart
git commit -m "feat(fase2): provider reativo da flag de onboarding"
```

---

## Task 6: Providers de auth + controller + ponte de refresh

**Files:**
- Create: `lib/router/go_router_refresh_stream.dart`
- Modify: `lib/router/auth_providers.dart` (adicionar providers de auth)
- Create: `lib/features/auth/auth_controller.dart`

> Esta task é "encanamento" acoplado ao Supabase. Não tem teste unitário (exigiria mock do SDK);
> é verificada por compilação aqui e pelo teste manual na Task 12. A lógica testável
> (validação, mensagens, redirect) já está coberta nas Tasks 2–5.

- [ ] **Step 1: Criar a ponte Stream→Listenable**

Criar `lib/router/go_router_refresh_stream.dart`:

```dart
import 'dart:async';
import 'package:flutter/foundation.dart';

/// Faz o GoRouter "ouvir" um Stream (ex.: mudanças de login) e re-avaliar o redirect.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
```

- [ ] **Step 2: Adicionar os providers de auth**

Editar `lib/router/auth_providers.dart`. Adicionar o import do Supabase no topo (logo abaixo do import do riverpod):

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
```

E adicionar, ao final do arquivo:

```dart
/// E-mail do usuário logado (ou null). Pode ser sobrescrito em testes.
final currentUserEmailProvider = Provider<String?>(
  (ref) => Supabase.instance.client.auth.currentUser?.email,
);
```

- [ ] **Step 3: Criar o controller de auth**

Criar `lib/features/auth/auth_controller.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Executa as ações de autenticação e expõe o estado (carregando/erro)
/// para a tela reagir. O resultado de sucesso dispara onAuthStateChange,
/// que faz o porteiro redirecionar sozinho.
class AuthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  SupabaseClient get _client => Supabase.instance.client;

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
    });
  }

  Future<void> signUp({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _client.auth.signUp(
        email: email.trim(),
        password: password,
      );
    });
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _client.auth.signOut());
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);
```

- [ ] **Step 4: Verificar a compilação**

Run: `flutter analyze lib/router/auth_providers.dart lib/router/go_router_refresh_stream.dart lib/features/auth/auth_controller.dart`
Expected: "No issues found!"

- [ ] **Step 5: Commit**

```bash
git add lib/router/go_router_refresh_stream.dart lib/router/auth_providers.dart lib/features/auth/auth_controller.dart
git commit -m "feat(fase2): providers e controller de autenticação (Supabase)"
```

---

## Task 7: Widgets reutilizáveis — botão, campo e segmented

**Files:**
- Create: `lib/core/widgets/forja_primary_button.dart`
- Create: `lib/core/widgets/forja_text_field.dart`
- Create: `lib/core/widgets/forja_segmented.dart`
- Test: `test/core/widgets/forja_segmented_test.dart`

- [ ] **Step 1: Implementar o botão primário**

Criar `lib/core/widgets/forja_primary_button.dart`:

```dart
import 'package:flutter/material.dart';

/// Botão primário FORJA: largura cheia, CAIXA ALTA, com estado de "carregando".
class ForjaPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  const ForjaPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        child: loading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label.toUpperCase()),
      ),
    );
  }
}
```

- [ ] **Step 2: Implementar o campo de texto**

Criar `lib/core/widgets/forja_text_field.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/forja_colors.dart';

/// Campo de texto FORJA: fundo bg2, borda que acende no acento, erro em danger.
class ForjaTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final String? errorText;
  final TextInputType keyboardType;

  const ForjaTextField({
    super.key,
    required this.controller,
    required this.label,
    this.obscure = false,
    this.errorText,
    this.keyboardType = TextInputType.text,
  });

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: color),
      );

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: GoogleFonts.spaceGrotesk(color: ForjaColors.text),
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        filled: true,
        fillColor: ForjaColors.bg2,
        enabledBorder: _border(ForjaColors.border),
        focusedBorder: _border(accent),
        errorBorder: _border(ForjaColors.danger),
        focusedErrorBorder: _border(ForjaColors.danger),
      ),
    );
  }
}
```

- [ ] **Step 3: Escrever o teste (falha) do segmented**

Criar `test/core/widgets/forja_segmented_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/core/widgets/forja_segmented.dart';
import 'package:forja_app/theme/forja_theme.dart';
import 'package:forja_app/theme/accent_theme.dart';

void main() {
  testWidgets('segmented mostra as opções e dispara onChanged ao tocar', (tester) async {
    int selected = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: forjaTheme(accentThemes.first),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => ForjaSegmented(
              options: const ['Entrar', 'Criar conta'],
              selectedIndex: selected,
              onChanged: (i) => setState(() => selected = i),
            ),
          ),
        ),
      ),
    );

    expect(find.text('ENTRAR'), findsOneWidget);
    expect(find.text('CRIAR CONTA'), findsOneWidget);

    await tester.tap(find.text('CRIAR CONTA'));
    await tester.pump();
    expect(selected, 1);
  });
}
```

- [ ] **Step 4: Rodar e ver falhar**

Run: `flutter test test/core/widgets/forja_segmented_test.dart`
Expected: FAIL — `forja_segmented.dart` não existe.

- [ ] **Step 5: Implementar o segmented**

Criar `lib/core/widgets/forja_segmented.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/forja_colors.dart';

/// Segmented control FORJA: trilho bg2, item ativo na cor de acento.
class ForjaSegmented extends StatelessWidget {
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const ForjaSegmented({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final fg = Theme.of(context).colorScheme.onPrimary;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: ForjaColors.bg2,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          for (int i = 0; i < options.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(i),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: i == selectedIndex ? accent : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    options[i].toUpperCase(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.w600,
                      color: i == selectedIndex ? fg : ForjaColors.textDim,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 6: Rodar e ver passar**

Run: `flutter test test/core/widgets/forja_segmented_test.dart`
Expected: PASS (1 teste).

- [ ] **Step 7: Commit**

```bash
git add lib/core/widgets/ test/core/widgets/forja_segmented_test.dart
git commit -m "feat(fase2): widgets reutilizáveis (botão, campo, segmented)"
```

---

## Task 8: Shader da arte animada + widget ForjaShaderArt

**Files:**
- Create: `shaders/forja_wave.frag`
- Modify: `pubspec.yaml` (seção `flutter:` → `shaders:`)
- Create: `lib/core/widgets/forja_shader_art.dart`

> A aparência exata do shader é refinável (polish). O critério aqui é: compila, anima e tem
> fallback. Verificação visual na Task 12.

- [ ] **Step 1: Criar o shader**

Criar `shaders/forja_wave.frag`:

```glsl
#version 460 core
#include <flutter/runtime_effect.glsl>

precision mediump float;

uniform vec2 uSize;    // tamanho do canvas em pixels
uniform float uTime;   // tempo em segundos
uniform vec3 uAccent;  // cor de acento (componentes 0..1)

out vec4 fragColor;

void main() {
  vec2 uv = FlutterFragCoord().xy / uSize;

  // fase das ondas horizontais
  float phase = uv.x * 6.2831853 * 2.0 + uTime * 1.5;

  // aberração cromática: cada canal com leve defasagem
  float r = 0.5 + 0.5 * sin(phase + 0.12 + uv.y * 3.0);
  float g = 0.5 + 0.5 * sin(phase + uv.y * 3.0);
  float b = 0.5 + 0.5 * sin(phase - 0.12 + uv.y * 3.0);

  vec3 col = uAccent * vec3(r, g, b);

  // brilho ondulado e fade vertical em direção ao escuro na base
  float fade = smoothstep(1.0, 0.15, uv.y);
  col *= fade;

  fragColor = vec4(col, 1.0);
}
```

- [ ] **Step 2: Declarar o shader no pubspec**

Editar `pubspec.yaml`. Dentro da seção `flutter:`, logo abaixo de `uses-material-design: true`, adicionar:

```yaml
  shaders:
    - shaders/forja_wave.frag
```

- [ ] **Step 3: Instalar/recompilar assets**

Run: `flutter pub get`
Expected: "Got dependencies!" (sem erros).

- [ ] **Step 4: Implementar o widget**

Criar `lib/core/widgets/forja_shader_art.dart`:

```dart
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../theme/forja_colors.dart';

/// Arte animada do topo do Onboarding e da banda do Login.
/// Usa um fragment shader; se ele não carregar, cai num gradiente estático.
class ForjaShaderArt extends StatefulWidget {
  final Color accent;
  const ForjaShaderArt({super.key, required this.accent});

  @override
  State<ForjaShaderArt> createState() => _ForjaShaderArtState();
}

class _ForjaShaderArtState extends State<ForjaShaderArt>
    with SingleTickerProviderStateMixin {
  ui.FragmentProgram? _program;
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _load();
  }

  Future<void> _load() async {
    try {
      final program =
          await ui.FragmentProgram.fromAsset('shaders/forja_wave.frag');
      if (mounted) setState(() => _program = program);
    } catch (_) {
      // Mantém o fallback (gradiente). App não quebra.
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final program = _program;
    if (program == null) {
      return DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              widget.accent.withValues(alpha: 0.5),
              ForjaColors.bgDark,
            ],
          ),
        ),
      );
    }
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) => CustomPaint(
        size: Size.infinite,
        painter: _ShaderPainter(
          program: program,
          time: _ctrl.value * 10.0,
          accent: widget.accent,
        ),
      ),
    );
  }
}

class _ShaderPainter extends CustomPainter {
  final ui.FragmentProgram program;
  final double time;
  final Color accent;

  _ShaderPainter({
    required this.program,
    required this.time,
    required this.accent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final shader = program.fragmentShader();
    shader.setFloat(0, size.width);  // uSize.x
    shader.setFloat(1, size.height); // uSize.y
    shader.setFloat(2, time);        // uTime
    shader.setFloat(3, accent.r);    // uAccent.r (0..1)
    shader.setFloat(4, accent.g);    // uAccent.g
    shader.setFloat(5, accent.b);    // uAccent.b
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(covariant _ShaderPainter old) =>
      old.time != time || old.accent != accent;
}
```

- [ ] **Step 5: Verificar a compilação**

Run: `flutter analyze lib/core/widgets/forja_shader_art.dart`
Expected: "No issues found!"

- [ ] **Step 6: Commit**

```bash
git add shaders/forja_wave.frag pubspec.yaml lib/core/widgets/forja_shader_art.dart
git commit -m "feat(fase2): arte animada (shader) com fallback de gradiente"
```

---

## Task 9: Onboarding (dados + página)

**Files:**
- Create: `lib/features/onboarding/onboarding_data.dart`
- Create: `lib/features/onboarding/onboarding_page.dart`
- Test: `test/features/onboarding/onboarding_page_test.dart`

- [ ] **Step 1: Criar os dados dos slides**

Criar `lib/features/onboarding/onboarding_data.dart`:

```dart
/// Conteúdo de um slide do onboarding. A palavra em destaque (accent) é
/// separada para receber a cor de acento no título.
class OnboardingSlide {
  final String eyebrow;
  final String titleBefore;
  final String titleAccent;
  final String body;

  const OnboardingSlide({
    required this.eyebrow,
    required this.titleBefore,
    required this.titleAccent,
    required this.body,
  });
}

const onboardingSlides = <OnboardingSlide>[
  OnboardingSlide(
    eyebrow: 'FORJA · 01 / 03',
    titleBefore: 'REGISTRE CADA ',
    titleAccent: 'SÉRIE',
    body: 'Anote cargas, repetições e descanso direto do celular, em segundos.',
  ),
  OnboardingSlide(
    eyebrow: 'FORJA · 02 / 03',
    titleBefore: 'ACOMPANHE SEU ',
    titleAccent: 'PROGRESSO',
    body: 'Veja sua evolução de carga e volume com gráficos claros.',
  ),
  OnboardingSlide(
    eyebrow: 'FORJA · 03 / 03',
    titleBefore: 'TREINE NO SEU ',
    titleAccent: 'RITMO',
    body: 'Cronômetro de descanso e treinos offline, onde você estiver.',
  ),
];
```

- [ ] **Step 2: Escrever o teste (falha) da página**

Criar `test/features/onboarding/onboarding_page_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forja_app/features/onboarding/onboarding_page.dart';
import 'package:forja_app/theme/forja_theme.dart';
import 'package:forja_app/theme/accent_theme.dart';

void main() {
  testWidgets('onboarding mostra o 1º slide e o botão PRÓXIMO', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: forjaTheme(accentThemes.first),
          home: const OnboardingPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('FORJA · 01 / 03'), findsOneWidget);
    expect(find.text('SÉRIE'), findsOneWidget);
    expect(find.text('PRÓXIMO →'), findsOneWidget);
    expect(find.text('Pular'), findsOneWidget);
  });

  testWidgets('avança até o último slide e o botão vira COMEÇAR', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: forjaTheme(accentThemes.first),
          home: const OnboardingPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('PRÓXIMO →'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('PRÓXIMO →'));
    await tester.pumpAndSettle();

    expect(find.text('FORJA · 03 / 03'), findsOneWidget);
    expect(find.text('COMEÇAR →'), findsOneWidget);
  });
}
```

- [ ] **Step 3: Rodar e ver falhar**

Run: `flutter test test/features/onboarding/onboarding_page_test.dart`
Expected: FAIL — `onboarding_page.dart` não existe.

- [ ] **Step 4: Implementar a página**

Criar `lib/features/onboarding/onboarding_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/widgets/forja_primary_button.dart';
import '../../core/widgets/forja_shader_art.dart';
import '../../router/auth_providers.dart';
import '../../theme/forja_colors.dart';
import 'onboarding_data.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _controller = PageController();
  int _index = 0;

  bool get _isLast => _index == onboardingSlides.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(onboardingSeenProvider.notifier).markSeen();
    if (mounted) context.go('/auth');
  }

  void _next() {
    if (_isLast) {
      _finish();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: ForjaColors.bg0,
      body: SafeArea(
        child: Column(
          children: [
            // Arte (shader) — ~40% da altura
            Expanded(
              flex: 4,
              child: ForjaShaderArt(accent: accent),
            ),
            // Conteúdo
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: PageView.builder(
                        controller: _controller,
                        itemCount: onboardingSlides.length,
                        onPageChanged: (i) => setState(() => _index = i),
                        itemBuilder: (context, i) {
                          final slide = onboardingSlides[i];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                slide.eyebrow,
                                style: GoogleFonts.bebasNeue(
                                  fontSize: 13,
                                  letterSpacing: 2.0,
                                  color: accent,
                                ),
                              ),
                              const SizedBox(height: 12),
                              RichText(
                                text: TextSpan(
                                  style: textTheme.displayLarge,
                                  children: [
                                    TextSpan(text: slide.titleBefore),
                                    TextSpan(
                                      text: slide.titleAccent,
                                      style: textTheme.displayLarge
                                          ?.copyWith(color: accent),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                slide.body,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 15,
                                  height: 1.5,
                                  color: ForjaColors.textDim,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Rodapé: dots + Pular
                    Row(
                      children: [
                        for (int i = 0; i < onboardingSlides.length; i++)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 6),
                            height: 6,
                            width: i == _index ? 26 : 6,
                            decoration: BoxDecoration(
                              color: i == _index ? accent : ForjaColors.bg3,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        const Spacer(),
                        TextButton(
                          onPressed: _finish,
                          child: Text(
                            'Pular',
                            style: GoogleFonts.spaceGrotesk(
                              color: ForjaColors.textDim,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ForjaPrimaryButton(
                      label: _isLast ? 'Começar →' : 'Próximo →',
                      onPressed: _next,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: Rodar e ver passar**

Run: `flutter test test/features/onboarding/onboarding_page_test.dart`
Expected: PASS (2 testes).

> Nota: o botão usa `label.toUpperCase()` internamente, então "Próximo →" é exibido como
> "PRÓXIMO →" (o teste procura o texto em CAIXA ALTA).

- [ ] **Step 6: Commit**

```bash
git add lib/features/onboarding/ test/features/onboarding/onboarding_page_test.dart
git commit -m "feat(fase2): tela de onboarding (3 slides com shader)"
```

---

## Task 10: Login / Cadastro (auth_page)

**Files:**
- Create: `lib/features/auth/auth_page.dart`
- Test: `test/features/auth/auth_page_test.dart`

- [ ] **Step 1: Escrever o teste (falha)**

Criar `test/features/auth/auth_page_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forja_app/features/auth/auth_page.dart';
import 'package:forja_app/theme/forja_theme.dart';
import 'package:forja_app/theme/accent_theme.dart';

Widget _wrap() => ProviderScope(
      child: MaterialApp(
        theme: forjaTheme(accentThemes.first),
        home: const AuthPage(),
      ),
    );

void main() {
  testWidgets('inicia em "Entrar" com botão ENTRAR', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();
    expect(find.text('ENTRAR →'), findsOneWidget);
  });

  testWidgets('alternar para "Criar conta" muda o botão', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();
    await tester.tap(find.text('CRIAR CONTA'));
    await tester.pumpAndSettle();
    expect(find.text('CRIAR CONTA →'), findsOneWidget);
  });

  testWidgets('submeter vazio mostra erros de validação', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();
    await tester.tap(find.text('ENTRAR →'));
    await tester.pump();
    expect(find.text('Informe seu e-mail'), findsOneWidget);
    expect(find.text('Informe sua senha'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Rodar e ver falhar**

Run: `flutter test test/features/auth/auth_page_test.dart`
Expected: FAIL — `auth_page.dart` não existe.

- [ ] **Step 3: Implementar a página**

Criar `lib/features/auth/auth_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/widgets/forja_primary_button.dart';
import '../../core/widgets/forja_segmented.dart';
import '../../core/widgets/forja_shader_art.dart';
import '../../core/widgets/forja_text_field.dart';
import '../../theme/forja_colors.dart';
import 'auth_controller.dart';
import 'auth_messages.dart';
import 'auth_validators.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  int _mode = 0; // 0 = Entrar, 1 = Criar conta
  String? _emailError;
  String? _passwordError;

  bool get _isSignUp => _mode == 1;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    final emailErr = validateEmail(_email.text);
    final passErr = validatePassword(_password.text);
    setState(() {
      _emailError = emailErr;
      _passwordError = passErr;
    });
    if (emailErr != null || passErr != null) return;

    final controller = ref.read(authControllerProvider.notifier);
    if (_isSignUp) {
      controller.signUp(email: _email.text, password: _password.text);
    } else {
      controller.signIn(email: _email.text, password: _password.text);
    }
  }

  void _comingSoon(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Login com $provider chega em breve')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final state = ref.watch(authControllerProvider);
    final loading = state.isLoading;

    // Mostra erro de backend quando a chamada falha.
    ref.listen(authControllerProvider, (prev, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: ForjaColors.danger,
            content: Text(mapAuthErrorToMessage(next.error!)),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: ForjaColors.bg0,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banda superior com shader + wordmark
            SizedBox(
              height: 200,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ForjaShaderArt(accent: accent),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.bebasNeue(
                            fontSize: 64,
                            color: ForjaColors.text,
                          ),
                          children: [
                            const TextSpan(text: 'FORJA'),
                            TextSpan(
                              text: '.',
                              style: TextStyle(color: accent),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ForjaSegmented(
                    options: const ['Entrar', 'Criar conta'],
                    selectedIndex: _mode,
                    onChanged: (i) => setState(() {
                      _mode = i;
                      _emailError = null;
                      _passwordError = null;
                    }),
                  ),
                  const SizedBox(height: 24),
                  ForjaTextField(
                    controller: _email,
                    label: 'E-mail',
                    keyboardType: TextInputType.emailAddress,
                    errorText: _emailError,
                  ),
                  const SizedBox(height: 16),
                  ForjaTextField(
                    controller: _password,
                    label: 'Senha',
                    obscure: true,
                    errorText: _passwordError,
                  ),
                  if (!_isSignUp) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => _comingSoon('recuperação de senha'),
                        child: Text(
                          'Esqueceu?',
                          style: GoogleFonts.spaceGrotesk(color: accent),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  ForjaPrimaryButton(
                    label: _isSignUp ? 'Criar conta →' : 'Entrar →',
                    loading: loading,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Expanded(child: Divider(color: ForjaColors.border)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'OU',
                          style: GoogleFonts.spaceGrotesk(
                            color: ForjaColors.textFaint,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(color: ForjaColors.border)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => _comingSoon('Google'),
                    child: const Text('Continuar com Google'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => _comingSoon('Apple'),
                    child: const Text('Continuar com Apple'),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Ao continuar, você concorda com os Termos de Uso e a Política de Privacidade.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      color: ForjaColors.textFaint,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Rodar e ver passar**

Run: `flutter test test/features/auth/auth_page_test.dart`
Expected: PASS (3 testes).

- [ ] **Step 5: Commit**

```bash
git add lib/features/auth/auth_page.dart test/features/auth/auth_page_test.dart
git commit -m "feat(fase2): tela de login/cadastro com validação"
```

---

## Task 11: Tela inicial provisória (home placeholder)

**Files:**
- Create: `lib/features/home/home_placeholder_page.dart`
- Test: `test/features/home/home_placeholder_test.dart`

- [ ] **Step 1: Escrever o teste (falha)**

Criar `test/features/home/home_placeholder_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forja_app/features/home/home_placeholder_page.dart';
import 'package:forja_app/router/auth_providers.dart';
import 'package:forja_app/theme/forja_theme.dart';
import 'package:forja_app/theme/accent_theme.dart';

void main() {
  testWidgets('mostra o e-mail logado e o botão Sair', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserEmailProvider.overrideWithValue('lucas@forja.com'),
        ],
        child: MaterialApp(
          theme: forjaTheme(accentThemes.first),
          home: const HomePlaceholderPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('lucas@forja.com'), findsOneWidget);
    expect(find.text('SAIR DA CONTA'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Rodar e ver falhar**

Run: `flutter test test/features/home/home_placeholder_test.dart`
Expected: FAIL — `home_placeholder_page.dart` não existe.

- [ ] **Step 3: Implementar a página**

Criar `lib/features/home/home_placeholder_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../router/auth_providers.dart';
import '../../theme/forja_colors.dart';
import '../auth/auth_controller.dart';

/// Tela inicial PROVISÓRIA — comprova o login de ponta a ponta.
/// Será substituída pelo Dashboard "Hoje" + navegação na Fase 3.
class HomePlaceholderPage extends ConsumerWidget {
  const HomePlaceholderPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = ref.watch(currentUserEmailProvider) ?? 'sem e-mail';
    final accent = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: ForjaColors.bg0,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.bebasNeue(
                      fontSize: 72,
                      color: ForjaColors.text,
                    ),
                    children: [
                      const TextSpan(text: 'FORJA'),
                      TextSpan(text: '.', style: TextStyle(color: accent)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  email,
                  style: GoogleFonts.spaceGrotesk(color: ForjaColors.textDim),
                ),
                const SizedBox(height: 24),
                Text(
                  'O Dashboard chega na Fase 3.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceGrotesk(
                    color: ForjaColors.textFaint,
                  ),
                ),
                const SizedBox(height: 32),
                OutlinedButton(
                  onPressed: () =>
                      ref.read(authControllerProvider.notifier).signOut(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ForjaColors.danger,
                    side: const BorderSide(color: ForjaColors.danger),
                  ),
                  child: const Text('SAIR DA CONTA'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Rodar e ver passar**

Run: `flutter test test/features/home/home_placeholder_test.dart`
Expected: PASS (1 teste).

- [ ] **Step 5: Commit**

```bash
git add lib/features/home/ test/features/home/home_placeholder_test.dart
git commit -m "feat(fase2): tela inicial provisória pós-login"
```

---

## Task 12: Splash, montagem do router, main.dart e verificação ponta a ponta

**Files:**
- Create: `lib/features/splash/splash_page.dart`
- Modify: `lib/router/auth_providers.dart` (adicionar `goRouterProvider`)
- Modify: `lib/main.dart`
- Delete: `lib/router/app_router.dart`
- Delete: `lib/features/_dev/connection_check_page.dart`

- [ ] **Step 1: Criar a splash-gate**

Criar `lib/features/splash/splash_page.dart`:

```dart
import 'package:flutter/material.dart';
import '../../theme/forja_colors.dart';

/// Tela-gate em "/": aparece por um instante enquanto o porteiro decide o destino.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: ForjaColors.bg0,
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
```

- [ ] **Step 2: Adicionar o goRouterProvider**

Editar `lib/router/auth_providers.dart`. Adicionar os imports no topo (junto aos demais):

```dart
import 'package:go_router/go_router.dart';
import '../features/auth/auth_page.dart';
import '../features/home/home_placeholder_page.dart';
import '../features/onboarding/onboarding_page.dart';
import '../features/splash/splash_page.dart';
import 'go_router_refresh_stream.dart';
import 'redirect_logic.dart';
```

Adicionar ao final do arquivo:

```dart
/// O "porteiro": monta o GoRouter, reage a login/logout e aplica o redirect.
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
        location: state.matchedLocation,
      );
    },
    routes: [
      GoRoute(path: '/', builder: (c, s) => const SplashPage()),
      GoRoute(path: '/onboarding', builder: (c, s) => const OnboardingPage()),
      GoRoute(path: '/auth', builder: (c, s) => const AuthPage()),
      GoRoute(path: '/home', builder: (c, s) => const HomePlaceholderPage()),
    ],
  );
});
```

- [ ] **Step 3: Reescrever o main.dart**

Substituir todo o conteúdo de `lib/main.dart` por:

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'router/auth_providers.dart';
import 'services/onboarding_prefs.dart';
import 'theme/accent_theme.dart';
import 'theme/forja_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
  final onboardingSeen = await OnboardingPrefs.isSeen();
  runApp(
    ProviderScope(
      overrides: [
        initialOnboardingSeenProvider.overrideWithValue(onboardingSeen),
      ],
      child: const ForjaApp(),
    ),
  );
}

class ForjaApp extends ConsumerWidget {
  const ForjaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = ref.watch(accentProvider);
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: 'FORJA',
      debugShowCheckedModeBanner: false,
      theme: forjaTheme(accent),
      routerConfig: router,
    );
  }
}
```

- [ ] **Step 4: Remover os arquivos obsoletos**

Run:
```bash
git rm lib/router/app_router.dart lib/features/_dev/connection_check_page.dart
```
Expected: ambos removidos do versionamento.

- [ ] **Step 5: Analisar o projeto inteiro**

Run: `flutter analyze`
Expected: "No issues found!" (se houver import não usado de `app_router.dart` em algum lugar, corrigir — não deve haver, pois só `main.dart` o usava).

- [ ] **Step 6: Rodar TODOS os testes**

Run: `flutter test`
Expected: PASS em todos (Tasks 1–11 + os testes pré-existentes `theme_test` e `smoke_test`).

- [ ] **Step 7: Verificação manual no Chrome (ponta a ponta)**

Run: `flutter run -d chrome`

Conferir, em ordem:
1. Primeira abertura → aparece o **Onboarding** com a arte animada; dá para deslizar os 3 slides.
2. Tocar **"Pular"** ou avançar até **"COMEÇAR →"** → vai para a tela de **Login**.
3. Aba **"Criar conta"** → criar com um e-mail/senha novos → entra direto na **tela inicial** (mostra o e-mail).
4. Tocar **"Sair da conta"** → volta para o **Login** (e NÃO mostra o onboarding de novo).
5. Fazer **login** com a conta criada → entra na tela inicial.
6. Recarregar a página do Chrome (F5) → continua **logado** (sessão persistente).
7. Campos vazios ou e-mail inválido → mostram **erro**; senha errada → **SnackBar** "E-mail ou senha incorretos".

- [ ] **Step 8: Commit**

```bash
git add lib/main.dart lib/router/auth_providers.dart lib/features/splash/
git commit -m "feat(fase2): porteiro de navegação + main + remoção da tela de dev"
```

---

## Task 13: Fechamento da fase

- [ ] **Step 1: Conferir o status do git**

Run: `git status`
Expected: árvore limpa (tudo commitado).

- [ ] **Step 2: Rodar a suíte completa uma última vez**

Run: `flutter test`
Expected: todos PASS.

- [ ] **Step 3: Atualizar o doc de design geral (marcar Fase 2 concluída)**

Editar `docs/superpowers/specs/2026-06-03-forja-mobile-flutter-design.md`, na tabela da seção
"8. Plano de fases", marcar a linha da Fase 2 como concluída (ex.: prefixar a entrega com
"✅ "). Commit:

```bash
git add docs/superpowers/specs/2026-06-03-forja-mobile-flutter-design.md
git commit -m "docs: marca Fase 2 (Entrada) como concluída no plano macro"
```

- [ ] **Step 4: REQUIRED — finalizar a branch**

Use a skill **superpowers:finishing-a-development-branch** para verificar os testes, apresentar
as opções (merge na `master`, abrir PR, etc.) e executar a escolha do usuário.

---

## Self-Review (cobertura do spec)

- **Onboarding 3 passos + shader** → Tasks 8, 9 ✅
- **Login/Cadastro (Supabase, sem confirmação)** → Tasks 6, 10 ✅
- **Cadastro entra direto** → `signUp` sem fluxo de confirmação (Task 6) + porteiro leva a `/home` (Task 12) ✅
- **"Esqueceu?" decorativo** → Task 10 (`_comingSoon`) ✅
- **Login social decorativo** → Task 10 (botões Google/Apple → SnackBar "em breve") ✅
- **Porteiro reativo (Opção A)** → Tasks 2 (resolveRedirect), 6 (refresh stream), 12 (goRouterProvider) ✅
- **Sessão persistente** → comportamento padrão do supabase_flutter; verificado na Task 12 Step 7.6 ✅
- **Logout** → Tasks 6 (signOut), 11 (botão) ✅
- **shared_preferences (onboarding visto)** → Tasks 1, 5 ✅
- **Tela inicial provisória + remoção da _dev** → Tasks 11, 12 ✅
- **Validação + erros amigáveis + loading** → Tasks 3, 4, 10 ✅
- **Estados de UI** → Task 10 (loading no botão, erros inline, SnackBar) ✅
- **Testes (widget + regressão)** → cada task tem teste; Task 12 roda a suíte completa ✅
- **Critério de conclusão** → Task 12 Step 7 (verificação manual) + Task 13 ✅

**Consistência de tipos/nomes:** `onboardingSeenProvider`/`initialOnboardingSeenProvider`,
`authControllerProvider`, `currentUserEmailProvider`, `resolveRedirect(...)`,
`ForjaPrimaryButton`/`ForjaTextField`/`ForjaSegmented`/`ForjaShaderArt`,
`OnboardingPrefs.isSeen/markSeen` — usados de forma idêntica em todas as tasks. Rotas
`/`,`/onboarding`,`/auth`,`/home` consistentes entre `resolveRedirect` e `goRouterProvider`.

**Placeholders:** nenhum "TBD/implementar depois". Textos dos slides são conteúdo final
(ajustáveis como polish, isolados em `onboarding_data.dart`).
