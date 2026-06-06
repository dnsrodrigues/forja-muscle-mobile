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
    await tester.pump(); // build
    await tester.pump(const Duration(milliseconds: 400)); // advance past transitions

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
    await tester.pump(); // build
    await tester.pump(const Duration(milliseconds: 400)); // advance past transitions

    await tester.tap(find.text('PRÓXIMO →'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('PRÓXIMO →'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('FORJA · 03 / 03'), findsOneWidget);
    expect(find.text('COMEÇAR →'), findsOneWidget);
  });
}
