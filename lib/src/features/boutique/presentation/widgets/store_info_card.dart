import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/boutique_model.dart';

/// Luxury Deep Green Leather-Finished Kapada Creation Store Info Card.
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF144717)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFC5A880).withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Leather Badge Header ────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.workspace_premium_rounded,
                          size: 16,
                          color: Color(0xFFC5A880),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'KAPADA BOUTIQUE STUDIO',
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFC5A880),
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
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
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFC5A880),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'FLAGSHIP',
                  style: GoogleFonts.montserrat(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          Divider(
            height: 1,
            color: const Color(0xFFC5A880).withValues(alpha: 0.3),
          ),
          const SizedBox(height: 14),

          // ── Studio Address & Phone Info ──────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Address
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 15,
                          color: Color(0xFFC5A880),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            address,
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.95),
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Phone
                    Row(
                      children: [
                        const Icon(
                          Icons.phone_in_talk_rounded,
                          size: 15,
                          color: Color(0xFFC5A880),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          phone,
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Hours
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_filled_rounded,
                          size: 15,
                          color: Color(0xFFC5A880),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          hours,
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Studio Photo Container with Gold Border
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFC5A880).withValues(alpha: 0.6),
                    width: 1.2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: Image.network(
                    photoUrl,
                    width: 76,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(
                      width: 76,
                      height: 90,
                      color: AppColors.brandGreen800,
                      child: const Icon(
                        Icons.storefront_rounded,
                        color: Color(0xFFC5A880),
                        size: 28,
                      ),
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
