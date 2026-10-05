import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/stitch_divider.dart';
import '../../../../core/widgets/sticky_note_card.dart';
import '../../../auth/application/providers/auth_providers.dart';
import '../../domain/models/stitching_order_model.dart';

/// Executive Tailor-Stitched Order Card tile for Customer "My Stitching" list.
class StitchingOrderCard extends ConsumerWidget {
  const StitchingOrderCard({super.key, required this.order});

  final StitchingOrderModel order;

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'N/A';
    return DateFormat('d MMM yyyy').format(dt);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentCustomerUserProvider);
    final customerName = (user?.displayName != null && user!.displayName!.isNotEmpty)
        ? user.displayName!
        : 'Customer';
    final photoUrl = user?.photoURL;
    final firstChar = customerName.isNotEmpty ? customerName[0].toUpperCase() : 'C';

    final isCompleted = order.status == StitchingOrderStatus.completed;
    final isAccepted = order.status == StitchingOrderStatus.accepted;

    final statusColor = isCompleted
        ? const Color(0xFF2E7D32)
        : isAccepted
            ? const Color(0xFF1565C0)
            : const Color(0xFFE65100);

    final garmentTitle = order.displayRequestName;

    return GestureDetector(
      onTap: () => context.push(
        AppRoutes.customerStitchingDetails,
        extra: order,
      ),
      child: DashedStitchContainer(
        borderColor: statusColor.withValues(alpha: 0.45),
        minThickness: 0.8,
        maxThickness: 1.4,
        dashWidth: 6.5,
        dashGap: 4.0,
        inset: 4.5,
        borderRadius: 18.0,
        backgroundColor: AppColors.surfaceWhite,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── TOP SECTION: Customer Avatar + Name + Garment + Date ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: statusColor.withValues(alpha: 0.12),
                  backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                      ? NetworkImage(photoUrl)
                      : null,
                  child: (photoUrl == null || photoUrl.isEmpty)
                      ? Text(
                          firstChar,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customerName,
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.charcoal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        garmentTitle,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.brandGreen900,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatDate(order.createdAt),
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.mutedText,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── PROGRESS FRACTION BAR ──
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: order.status.progressFraction,
                backgroundColor: statusColor.withValues(alpha: 0.12),
                color: statusColor,
                minHeight: 6,
              ),
            ),

            if (order.notes != null && order.notes!.isNotEmpty) ...[
              const SizedBox(height: 10),
              StickyNoteCard(note: order.notes!),
            ],

            if (order.expectedReadyAt != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFD97706).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFD97706).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 13,
                      color: Color(0xFFD97706),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'ESTIMATED READY: ${DateFormat('d MMM yyyy').format(order.expectedReadyAt!)}',
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 14),

            // ── BOTTOM SECTION: Order Number Badge + Status Indicator Chip ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.brandGreen900.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.brandGreen900.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Text(
                    '#${order.orderNumber}',
                    style: GoogleFonts.montserrat(
                      color: AppColors.brandGreen900,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            order.status.customerLabel.toUpperCase(),
                            style: GoogleFonts.montserrat(
                              color: statusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: statusColor,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
