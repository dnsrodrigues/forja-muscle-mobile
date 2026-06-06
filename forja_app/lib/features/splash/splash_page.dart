import 'package:flutter/material.dart';
import '../../theme/forja_colors.dart';

/// Tela-gate em "/": aparece por um instante enquanto o porteiro decide o destino.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: ForjaColors.bg0,
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
