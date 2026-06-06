import 'package:flutter/material.dart';
import '../../theme/forja_colors.dart';

/// Card padrão FORJA: fundo bg1, borda hairline, raio 14.
class ForjaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? borderColor;

  const ForjaCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: ForjaColors.bg1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor ?? ForjaColors.hairline),
      ),
      child: child,
    );
  }
}
