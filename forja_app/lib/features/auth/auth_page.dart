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
