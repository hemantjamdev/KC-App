import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/leather_stitched_container.dart';
import '../../domain/models/boutique_model.dart';

/// Ultra-Premium Luxury Kapada Creation Store Info Card.
/// Designed with deep green leather texture, gold dashed stitching border, and gold accents.
class StoreInfoCard extends StatelessWidget {
  const StoreInfoCard({super.key, this.boutique});

  final BoutiqueModel? boutique;

  @override
  Widget build(BuildContext context) {
    final name = boutique?.name ?? 'Kapada Creation Studio';
    final subtitle = (boutique?.subtitle != null && boutique!.subtitle.isNotEmpty)
        ? boutique!.subtitle
        : 'Timeless elegance, stitched with love.';
    final address = (boutique?.address != null && boutique!.address!.isNotEmpty)
        ? boutique!.address!
        : 'Kapada Creation Boutique Studio';
    final phone = (boutique?.phone != null && boutique!.phone!.isNotEmpty)
        ? boutique!.phone!
        : '+91 Studio Support';
    final hours = (boutique?.openingHours != null && boutique!.openingHours!.isNotEmpty)
        ? boutique!.openingHours!
        : 'Mon - Sat: 10:00 AM - 8:30 PM';
    final photoUrl = (boutique?.logoUrl != null && boutique!.logoUrl!.isNotEmpty)
        ? boutique!.logoUrl!
        : null;

    return LeatherStitchedContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
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
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.montserrat(
                        fontSize: 11.5,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                child: Text(
                  'Bespoke Studio',
                  style: GoogleFonts.montserrat(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          Divider(
            height: 1,
            color: Colors.white.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 14),

          // Info & Image Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Address
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            address,
                            style: GoogleFonts.montserrat(
                              fontSize: 11.5,
                              color: Colors.white,
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
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          phone,
                          style: GoogleFonts.montserrat(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
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
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          hours,
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: photoUrl != null && photoUrl.startsWith('http')
                      ? Image.network(
                          photoUrl,
                          width: 72,
                          height: 84,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => Container(
                            width: 72,
                            height: 84,
                            color: AppColors.brandGreen800,
                            child: const Icon(
                              Icons.storefront_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        )
                      : Container(
                          width: 72,
                          height: 84,
                          color: AppColors.brandGreen800,
                          child: const Icon(
                            Icons.storefront_rounded,
                            color: Colors.white,
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
