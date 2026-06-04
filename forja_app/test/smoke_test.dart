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
