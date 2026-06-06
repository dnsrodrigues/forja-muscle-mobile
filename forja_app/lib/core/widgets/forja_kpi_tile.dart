import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/forja_colors.dart';

/// Tile de KPI: label pequeno + valor grande Bebas Neue + unidade opcional.
class ForjaKpiTile extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;

  const ForjaKpiTile({
    super.key,
    required this.label,
    required this.value,
    this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ForjaColors.bg1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ForjaColors.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.15,
              color: ForjaColors.textDim,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: GoogleFonts.bebasNeue(
                  fontSize: 38,
                  height: 0.95,
                  color: ForjaColors.text,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Text(
                  unit!,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    color: ForjaColors.textDim,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
