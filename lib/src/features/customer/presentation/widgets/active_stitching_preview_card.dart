import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../stitching/domain/models/stitching_order_model.dart';
import '../../../stitching/presentation/widgets/stitching_request_bottom_sheet.dart';

import '../../../../core/widgets/stitch_divider.dart';

/// Modular Active Stitching Order Preview Card for Profile Page.
class ActiveStitchingPreviewCard extends StatelessWidget {
  const ActiveStitchingPreviewCard({super.key, this.activeOrder});

  final StitchingOrderModel? activeOrder;

  @override
  Widget build(BuildContext context) {
    return DashedStitchContainer(
      backgroundColor: const Color(0xFFFAF6EF),
      borderColor: const Color(0xFFC5A880),
      borderRadius: 20,
      inset: 4.0,
      dashWidth: 6.5,
      dashGap: 3.5,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.architecture_rounded,
                    size: 22,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Active Stitching',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => context.push(AppRoutes.customerStitchingList),
                child: Text(
                  'View History',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          if (activeOrder != null)
            _buildActiveOrderCard(context, activeOrder!)
          else
            _buildNoActiveOrderState(context),
        ],
      ),
    );
  }

  Widget _buildActiveOrderCard(
    BuildContext context,
    StitchingOrderModel order,
  ) {
    final title = order.displayRequestName;
    final statusText = order.status.customerLabel;
    final orderNum = order.orderNumber;
    final expectedDate = order.expectedReadyAt != null
        ? DateFormat('MMM d, yyyy').format(order.expectedReadyAt!)
        : 'TBD';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80,
          height: 90,
          decoration: BoxDecoration(
            color: AppColors.brandGreen50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Icon(
              Icons.design_services_rounded,
              color: AppColors.primary,
              size: 32,
            ),
          ),
        ),
        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.brandGreen50,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      'IN PROGRESS',
                      style: GoogleFonts.montserrat(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '#$orderNum',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              Text(
                title,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 2),

              Text(
                'Ready by $expectedDate',
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 10),

              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: order.status.progressFraction,
                  minHeight: 6,
                  backgroundColor: AppColors.brandGreen50,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),

              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Stage: $statusText',
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoActiveOrderState(BuildContext context) {
    return Column(
      children: [
        Text(
          'No active stitching order in progress.',
          style: GoogleFonts.montserrat(
            fontSize: 13,
            color: AppColors.textMuted,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => StitchingRequestBottomSheet.show(context),
          icon: const Icon(Icons.add_rounded, size: 16),
          label: Text(
            'Request Custom Stitching',
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
