import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/boutique_model.dart';

/// Clean, modern, and appealing Kapada Creation Store Info Card.
class StoreInfoCard extends StatelessWidget {
  const StoreInfoCard({super.key, this.boutique});

  final BoutiqueModel? boutique;

  @override
  Widget build(BuildContext context) {
    final name = boutique?.name ?? 'Kapada Creation';
    final subtitle = (boutique?.subtitle != null && boutique!.subtitle.isNotEmpty)
        ? boutique!.subtitle
        : 'Timeless elegance, stitched with love.';
    final address = (boutique?.address != null && boutique!.address!.isNotEmpty)
        ? boutique!.address!
        : 'F-21, Green Park Extension, New Delhi - 110016';
    final phone = (boutique?.phone != null && boutique!.phone!.isNotEmpty)
        ? boutique!.phone!
        : '+91 98765 43210';
    final hours = (boutique?.openingHours != null && boutique!.openingHours!.isNotEmpty)
        ? boutique!.openingHours!
        : 'Mon - Sat: 10:00 AM - 8:30 PM';
    final photoUrl = (boutique?.logoUrl != null && boutique!.logoUrl!.isNotEmpty)
        ? boutique!.logoUrl!
        : 'https://images.unsplash.com/photo-1558769132-cb1aea458c5e?q=80&w=600&auto=format&fit=crop';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSoft),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: Title & Studio Badge ─────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.charcoal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        color: AppColors.mutedText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warmIvory,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderSoft),
                ),
                child: Text(
                  'Bespoke Studio',
                  style: GoogleFonts.montserrat(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: AppColors.charcoal,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.borderSoft),
          const SizedBox(height: 12),

          // ── Info Details & Compact Studio Photo ────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left Column: Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Address
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppColors.charcoal,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            address,
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              color: AppColors.charcoal,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Phone
                    Row(
                      children: [
                        const Icon(
                          Icons.phone_outlined,
                          size: 14,
                          color: AppColors.charcoal,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          phone,
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.charcoal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Hours
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: AppColors.mutedText,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          hours,
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            color: AppColors.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Right Photo: Compact & Clean
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  photoUrl,
                  width: 72,
                  height: 84,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Container(
                    width: 72,
                    height: 84,
                    color: AppColors.warmIvory,
                    child: const Icon(
                      Icons.storefront_rounded,
                      color: AppColors.charcoal,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
