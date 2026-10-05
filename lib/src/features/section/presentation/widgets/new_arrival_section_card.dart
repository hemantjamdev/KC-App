import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/widgets/google_auth_bottom_sheet.dart';
import '../../../design/application/providers/favorite_providers.dart';
import '../../../design/domain/models/design_model.dart';

class NewArrivalSectionCard extends ConsumerWidget {
  const NewArrivalSectionCard({super.key, required this.design});

  final DesignModel design;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = design.name;
    final subtitle = design.shortDescription?.isNotEmpty == true
        ? design.shortDescription!
        : 'Soft florals, timeless you.';
    final price = '₹${design.price.toInt()}';
    final hasImg = design.imageUrls.isNotEmpty;
    final imgUrl = hasImg ? design.imageUrls.first : (design.thumbnailUrl ?? '');
    final isSaved = ref.watch(isDesignFavoritedProvider(design.id));

    return Container(
      height: 520,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: AppColors.surfaceWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Background Image
            if (hasImg && imgUrl.startsWith('http'))
              Image.network(
                imgUrl,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => Container(
                  color: AppColors.brandGreen900,
                ),
              )
            else
              Container(color: AppColors.brandGreen900),

            // 2. Dark Gradient Overlay for text contrast
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      const Color(0xFF092819).withValues(alpha: 0.7),
                      const Color(0xFF092819).withValues(alpha: 0.95),
                    ],
                    stops: const [0.0, 0.45, 0.75, 1.0],
                  ),
                ),
              ),
            ),

            // 3. Top-Left Badge (Kapada Creation Logo Patch)
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF133221).withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFC5A880), width: 1),
                ),
                child: Text(
                  'KAPADA CREATION',
                  style: GoogleFonts.montserrat(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFC5A880),
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ),

            // 4. Top-Right Bookmark Button
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () async {
                  final success = await ref
                      .read(favoriteMutationProvider.notifier)
                      .toggleFavorite(design.id);
                  if (!success && context.mounted) {
                    await GoogleAuthBottomSheet.show(context);
                  }
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF133221),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFC5A880),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),

            // 5. Bottom Content
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title and Leaf
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            height: 1.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      PhosphorIcon(
                        PhosphorIcons.leaf(PhosphorIconsStyle.light),
                        color: const Color(0xFFC5A880),
                        size: 24,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Subtitle
                  Text(
                    subtitle,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 12),

                  // Price
                  Text(
                    price,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFC5A880),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // View Details Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PhosphorIcon(
                        PhosphorIcons.scissors(PhosphorIconsStyle.light),
                        color: const Color(0xFFC5A880),
                        size: 20,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View Details',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFFC5A880),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: Color(0xFFC5A880),
                            size: 16,
                          ),
                        ],
                      ),
                      PhosphorIcon(
                        PhosphorIcons.leaf(PhosphorIconsStyle.light),
                        color: const Color(0xFFC5A880),
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
