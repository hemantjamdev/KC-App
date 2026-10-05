import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_colors.dart';

/// 2nd/End Card in Home Trending Carousel directing users to the full Trending Listing page.
class BrowseMoreTrendingCard extends StatelessWidget {
  const BrowseMoreTrendingCard({super.key, this.totalCount});

  final int? totalCount;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(AppRoutes.customerTrendingListing);
      },
      child: Container(
        width: 170,
        height: 290,
        margin: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.brandGreen50,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  size: 26,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Explore All\nTrending',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),

              Text(
                totalCount != null ? 'View $totalCount styles' : 'View full list',
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'BROWSE NOW',
                  style: GoogleFonts.montserrat(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.surfaceWhite,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
