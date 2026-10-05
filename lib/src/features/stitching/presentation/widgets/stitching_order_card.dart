import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/sticky_note_card.dart';
import '../../../../core/widgets/stitching_status_badge.dart';
import '../../domain/models/stitching_order_model.dart';

/// Modular Stitching Order List Card widget.
class StitchingOrderCard extends StatelessWidget {
  const StitchingOrderCard({super.key, required this.order});

  final StitchingOrderModel order;

  @override
  Widget build(BuildContext context) {
    final titleName = order.designReferences.isNotEmpty
        ? order.designReferences.first.designName
        : 'Custom Stitching Request';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.orderNumber,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brandGreen900,
                  letterSpacing: 0.5,
                ),
              ),
              StitchingStatusBadge(status: order.status.name),
            ],
          ),
          const SizedBox(height: 10),

          Text(
            titleName,
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),

          // Progress Fraction Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: order.status.progressFraction,
              backgroundColor: AppColors.brandGreen50,
              color: AppColors.brandGreen800,
              minHeight: 6,
            ),
          ),
          if (order.notes != null && order.notes!.isNotEmpty) ...[
            StickyNoteCard(note: order.notes!),
            const SizedBox(height: 8),
          ],

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Status: ${order.status.customerLabel}',
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: AppColors.mutedText,
                ),
              ),
              GestureDetector(
                onTap: () => context.push(
                  AppRoutes.customerStitchingDetails,
                  extra: order,
                ),
                child: Row(
                  children: [
                    Text(
                      'Details',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brandGreen800,
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: AppColors.brandGreen800,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
