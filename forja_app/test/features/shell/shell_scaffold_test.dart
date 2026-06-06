import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/features/shell/shell_scaffold.dart';

void main() {
  testWidgets('ShellScaffold exibe os 4 labels das abas', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: ShellScaffold(
            tabIndex: 0,
            child: const Text('conteúdo'),
          ),
        ),
      ),
    );
    expect(find.text('Hoje'), findsOneWidget);
    expect(find.text('Semana'), findsOneWidget);
    expect(find.text('Exercícios'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);
  });

  testWidgets('ShellScaffold exibe o filho (child)', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: ShellScaffold(
            tabIndex: 1,
            child: const Text('aba semana'),
          ),
        ),
      ),
    );
    expect(find.text('aba semana'), findsOneWidget);
  });
}
