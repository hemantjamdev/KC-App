import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/models/boutique_model.dart';

/// Ultra-Premium Luxury Kapada Creation Store Info Card.
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFC5A880).withValues(alpha: 0.5),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
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
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.montserrat(
                        fontSize: 11.5,
                        color: const Color(0xFF666666),
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
                  color: const Color(0xFFFAF7F2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFEAE5DC)),
                ),
                child: Text(
                  'Bespoke Studio',
                  style: GoogleFonts.montserrat(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFA67C52),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFEAE5DC)),
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
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 15,
                          color: Color(0xFFA67C52),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            address,
                            style: GoogleFonts.montserrat(
                              fontSize: 11.5,
                              color: const Color(0xFF1A1A1A),
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
                          size: 15,
                          color: Color(0xFFA67C52),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          phone,
                          style: GoogleFonts.montserrat(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A1A1A),
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
                          size: 15,
                          color: Color(0xFF888888),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          hours,
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            color: const Color(0xFF888888),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

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
                    color: const Color(0xFFFAF7F2),
                    child: const Icon(
                      Icons.storefront_rounded,
                      color: Color(0xFF1A1A1A),
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
