import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';

/// Modular Design Color Swatches display widget.
class DesignColorSwatches extends StatelessWidget {
  const DesignColorSwatches({super.key, required this.colors});

  final List<String> colors;

  @override
  Widget build(BuildContext context) {
    if (colors.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AVAILABLE COLORS',
          style: GoogleFonts.montserrat(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.mutedText,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: colors.map((colorStr) {
            Color swatchColor = AppColors.brandGreen800;
            try {
              String clean = colorStr.trim().replaceAll('#', '');
              if (clean.startsWith('0x')) clean = clean.substring(2);
              if (clean.length == 6) clean = 'FF$clean';
              swatchColor = Color(int.parse(clean, radix: 16));
            } catch (_) {}

            return Tooltip(
              message: colorStr,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: swatchColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.borderSoft,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
