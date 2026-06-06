import 'dart:async';
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
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    // Não carregar o shader em testes (evita pumpAndSettle timeout).
    if (!_isTest) unawaited(_load());
  }

  Future<void> _load() async {
    ui.FragmentProgram? program;
    try {
      program = await ui.FragmentProgram.fromAsset('shaders/forja_wave.frag');
    } catch (_) {
      // Mantém o fallback (gradiente). App não quebra.
      return;
    }
    if (_disposed || !mounted) return;
    setState(() => _program = program);
    // Não animar em testes (evita pumpAndSettle timeout por animação infinita).
    if (!_isTest) _startLoop();
  }

  static bool get _isTest {
    final type = WidgetsBinding.instance.runtimeType.toString();
    // Em testes: AutomatedTestWidgetsFlutterBinding ou TestWidgetsFlutterBinding
    return type.contains('Test');
  }

  void _startLoop() {
    if (_disposed || !mounted) return;
    _ctrl.forward(from: 0).whenComplete(() {
      if (!_disposed && mounted) _startLoop();
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _ctrl.dispose();
    super.dispose();
  }

  Widget _fallback() {
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

  @override
  Widget build(BuildContext context) {
    final program = _program;
    // Em testes sempre usar o fallback para evitar problemas com pumpAndSettle.
    if (program == null || _isTest) return _fallback();
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
    shader.setFloat(0, size.width);  // uSize.x
    shader.setFloat(1, size.height); // uSize.y
    shader.setFloat(2, time);        // uTime
    shader.setFloat(3, accent.r);    // uAccent.r (0..1)
    shader.setFloat(4, accent.g);    // uAccent.g
    shader.setFloat(5, accent.b);    // uAccent.b
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(covariant _ShaderPainter old) =>
      old.time != time || old.accent != accent;
}
