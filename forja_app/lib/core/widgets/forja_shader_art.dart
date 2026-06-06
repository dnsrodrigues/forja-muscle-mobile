import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../theme/forja_colors.dart';

/// Arte animada do topo do Onboarding e da banda do Login.
/// Usa um fragment shader; se ele não carregar, cai num gradiente estático.
class ForjaShaderArt extends StatefulWidget {
  final Color accent;
  const ForjaShaderArt({super.key, required this.accent});

  @override
  State<ForjaShaderArt> createState() => _ForjaShaderArtState();
}

class _ForjaShaderArtState extends State<ForjaShaderArt>
    with SingleTickerProviderStateMixin {
  ui.FragmentProgram? _program;
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _load();
  }

  Future<void> _load() async {
    try {
      final program =
          await ui.FragmentProgram.fromAsset('shaders/forja_wave.frag');
      if (mounted) setState(() => _program = program);
    } catch (_) {
      // Mantém o fallback (gradiente). App não quebra.
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final program = _program;
    if (program == null) {
      return DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              widget.accent.withValues(alpha: 0.5),
              ForjaColors.bgDark,
            ],
          ),
        ),
      );
    }
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) => CustomPaint(
        size: Size.infinite,
        painter: _ShaderPainter(
          program: program,
          time: _ctrl.value * 10.0,
          accent: widget.accent,
        ),
      ),
    );
  }
}

class _ShaderPainter extends CustomPainter {
  final ui.FragmentProgram program;
  final double time;
  final Color accent;

  _ShaderPainter({
    required this.program,
    required this.time,
    required this.accent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final shader = program.fragmentShader();
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
    shader.setFloat(2, time);
    shader.setFloat(3, accent.r);
    shader.setFloat(4, accent.g);
    shader.setFloat(5, accent.b);
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(covariant _ShaderPainter old) =>
      old.time != time || old.accent != accent;
}
