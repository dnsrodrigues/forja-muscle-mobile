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
    await tester.pump(); // build
    await tester.pump(const Duration(milliseconds: 400)); // advance past transitions
    expect(find.text('ENTRAR →'), findsOneWidget);
  });

  testWidgets('alternar para "Criar conta" muda o botão', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pump(); // build
    await tester.pump(const Duration(milliseconds: 400)); // advance past transitions
    await tester.tap(find.text('CRIAR CONTA'));
    await tester.pump(); // build
    await tester.pump(const Duration(milliseconds: 400)); // advance past transitions
    expect(find.text('CRIAR CONTA →'), findsOneWidget);
  });

  testWidgets('submeter vazio mostra erros de validação', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pump(); // build
    await tester.pump(const Duration(milliseconds: 400)); // advance past transitions
    await tester.tap(find.text('ENTRAR →'));
    await tester.pump();
    expect(find.text('Informe seu e-mail'), findsOneWidget);
    expect(find.text('Informe sua senha'), findsOneWidget);
  });
}
