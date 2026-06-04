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
