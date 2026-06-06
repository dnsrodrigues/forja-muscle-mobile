import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/forja_colors.dart';

/// Campo de texto FORJA: fundo bg2, borda que acende no acento, erro em danger.
class ForjaTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final String? errorText;
  final TextInputType keyboardType;

  const ForjaTextField({
    super.key,
    required this.controller,
    required this.label,
    this.obscure = false,
    this.errorText,
    this.keyboardType = TextInputType.text,
  });

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: color),
      );

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: GoogleFonts.spaceGrotesk(color: ForjaColors.text),
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        filled: true,
        fillColor: ForjaColors.bg2,
        enabledBorder: _border(ForjaColors.border),
        focusedBorder: _border(accent),
        errorBorder: _border(ForjaColors.danger),
        focusedErrorBorder: _border(ForjaColors.danger),
      ),
    );
  }
}
