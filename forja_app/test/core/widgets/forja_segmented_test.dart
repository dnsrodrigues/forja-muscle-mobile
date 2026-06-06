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
