import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Editorial dashed divider with optional center icon — mimics needle stitch motif.
class StitchLineDivider extends StatelessWidget {
  const StitchLineDivider({super.key, this.icon, this.margin});

  final IconData? icon;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (ctx, constraints) {
                const dashWidth = 6.0;
                const dashSpace = 4.0;
                final count = (constraints.maxWidth / (dashWidth + dashSpace))
                    .floor();
                return Row(
                  children: List.generate(
                    count,
                    (_) => Container(
                      width: dashWidth,
                      height: 1,
                      margin: const EdgeInsets.only(right: dashSpace),
                      color: AppColors.borderSoft,
                    ),
                  ),
                );
              },
            ),
          ),
          if (icon != null) ...[
            const SizedBox(width: 8),
            Icon(icon, size: 12, color: AppColors.borderSoft),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}
