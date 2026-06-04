// lib/theme/accent_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Um tema de acento trocável pelo usuário.
class AccentTheme {
  final String id;
  final String name;
  final Color accent;
  final Color fg; // cor do texto/ícone SOBRE o acento
  const AccentTheme(this.id, this.name, this.accent, this.fg);
}

/// Os 6 acentos do design. Padrão: Lime.
const accentThemes = <AccentTheme>[
  AccentTheme('lime', 'Lime', Color(0xFFD4FF3A), Color(0xFF0A0A0A)),
  AccentTheme('coral', 'Coral', Color(0xFFFF2E4D), Color(0xFFFFFFFF)),
  AccentTheme('orange', 'Forge', Color(0xFFFF6B00), Color(0xFF0A0A0A)),
  AccentTheme('ice', 'Ice', Color(0xFF00D4FF), Color(0xFF0A0A0A)),
  AccentTheme('violet', 'Violet', Color(0xFFA78BFA), Color(0xFF0A0A0A)),
  AccentTheme('mono', 'Mono', Color(0xFFF5F5F0), Color(0xFF0A0A0A)),
];

/// Guarda o acento atual e permite trocá-lo.
/// Na Fase 7 será ligado ao shared_preferences para persistir a escolha;
/// por ora começa no Lime.
class AccentNotifier extends Notifier<AccentTheme> {
  @override
  AccentTheme build() => accentThemes.first;

  /// Troca o acento ativo (usado pelo seletor de tema na Fase 7).
  void setAccent(AccentTheme accent) => state = accent;
}

final accentProvider =
    NotifierProvider<AccentNotifier, AccentTheme>(AccentNotifier.new);
