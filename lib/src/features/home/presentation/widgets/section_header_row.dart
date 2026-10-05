import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

/// Reusable Section Header with title label and 'View all' action link.
class SectionHeaderRow extends StatelessWidget {
  const SectionHeaderRow({
    super.key,
    required this.title,
    required this.onViewAll,
  });

  final String title;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(
              Icons.local_florist_rounded,
              size: 14,
              color: AppColors.brandGreen900,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.brandGreen900,
                letterSpacing: 1.4,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: onViewAll,
          child: Row(
            children: [
              Text(
                'View all',
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mutedText,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: AppColors.mutedText,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
