import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/core/widgets/forja_card.dart';
import 'package:forja_app/theme/forja_colors.dart';

void main() {
  testWidgets('ForjaCard renderiza o filho e aplica bg1', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ForjaCard(child: Text('conteúdo')),
        ),
      ),
    );
    expect(find.text('conteúdo'), findsOneWidget);

    final container = tester.widget<Container>(
      find
          .ancestor(of: find.text('conteúdo'), matching: find.byType(Container))
          .first,
    );
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, ForjaColors.bg1);
    expect((decoration.borderRadius as BorderRadius).topLeft.x, 14);
  });

  testWidgets('ForjaCard aceita borderColor customizada', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ForjaCard(
            borderColor: ForjaColors.danger,
            child: Text('ok'),
          ),
        ),
      ),
    );
    final container = tester.widget<Container>(
      find.ancestor(of: find.text('ok'), matching: find.byType(Container)).first,
    );
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.border, isNotNull);
  });
}
