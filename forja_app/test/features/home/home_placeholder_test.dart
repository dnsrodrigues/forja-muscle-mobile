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
