import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// Reusable status badge for stitching request rows matching KC-Admin color logic.
class StitchingStatusBadge extends StatelessWidget {
  const StitchingStatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    final label = _statusLabel(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.montserrat(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Color _statusColor(String s) {
    return switch (s.toLowerCase()) {
      'received' || 'requested' => AppColors.mutedGold,
      'measurements' || 'accepted' => AppColors.brandGreen600,
      'cutting' => AppColors.brandGreen700,
      'stitching' || 'in_progress' || 'inprogress' => AppColors.brandGreen800,
      'qualitycheck' || 'quality_check' => AppColors.brandGreen600,
      'ready' || 'ready_for_pickup' => AppColors.success,
      'completed' => AppColors.mutedText,
      'cancelled' => AppColors.error,
      _ => AppColors.mutedText,
    };
  }

  String _statusLabel(String s) {
    return switch (s.toLowerCase()) {
      'received' || 'requested' => 'Requested',
      'measurements' => 'Measurements',
      'cutting' => 'Cutting',
      'stitching' || 'in_progress' => 'In Progress',
      'qualitycheck' => 'Quality Check',
      'ready' => 'Ready for Pickup',
      'completed' => 'Completed',
      'cancelled' => 'Cancelled',
      _ => s,
    };
  }
}
