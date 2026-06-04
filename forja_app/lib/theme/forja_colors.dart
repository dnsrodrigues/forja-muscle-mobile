// lib/theme/forja_colors.dart
import 'package:flutter/material.dart';

/// Paleta oficial FORJA (tokens do design system).
class ForjaColors {
  // Superfícies (o app é dark por padrão)
  static const bg0 = Color(0xFF08090A); // fundo da tela
  static const bg1 = Color(0xFF101113); // card
  static const bg2 = Color(0xFF181A1C); // card aninhado / input
  static const bg3 = Color(0xFF23262A); // hover / trilho de barra
  static const bg4 = Color(0xFF2E3236);
  static const bgDark = Color(0xFF050506); // telas de foco (cronômetro/login)

  // Bordas
  static const hairline = Color(0x0FFFFFFF);     // branco 6%
  static const border = Color(0x1AFFFFFF);       // branco 10%
  static const borderStrong = Color(0x33FFFFFF); // branco 20%

  // Texto
  static const text = Color(0xFFF5F5F3);
  static const textDim = Color(0xFF9A9A96);
  static const textFaint = Color(0xFF5A5A56);

  // Semânticas
  static const danger = Color(0xFFFF3D55);
  static const warn = Color(0xFFFFB547);
  static const success = Color(0xFF6AFFB9);
  static const info = Color(0xFF6EC6FF);
}
