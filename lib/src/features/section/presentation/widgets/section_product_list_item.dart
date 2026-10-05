import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/widgets/google_auth_bottom_sheet.dart';
import '../../../design/application/providers/favorite_providers.dart';
import '../../../design/domain/models/design_model.dart';

/// Modular Section Product List Item Card widget.
class SectionProductListItem extends ConsumerWidget {
  const SectionProductListItem({super.key, required this.design});

  final DesignModel design;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = ref.watch(isDesignFavoritedProvider(design.id));
    final hasImg = design.imageUrls.isNotEmpty ||
        (design.thumbnailUrl != null && design.thumbnailUrl!.isNotEmpty);
    final imgUrl = design.imageUrls.isNotEmpty
        ? design.imageUrls.first
        : (design.thumbnailUrl ?? '');

    return GestureDetector(
      onTap: () => context.push(AppRoutes.customerDesignDetails, extra: design),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSoft),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: hasImg && imgUrl.startsWith('http')
                  ? CachedNetworkImage(
                      imageUrl: imgUrl,
                      fit: BoxFit.cover,
                      errorWidget: (ctx, err, stack) => const Center(
                        child: Icon(
                          Icons.checkroom_rounded,
                          color: AppColors.mutedText,
                          size: 28,
                        ),
                      ),
                    )
                  : const Center(
                      child: Icon(
                        Icons.checkroom_rounded,
                        color: AppColors.mutedText,
                        size: 28,
                      ),
                    ),
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    design.name,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.charcoal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (design.tags.isNotEmpty)
                    Text(
                      design.tags.first.toUpperCase(),
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.mutedText,
                      ),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    '₹${design.price.toInt()}',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.charcoal,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            GestureDetector(
              onTap: () async {
                final success = await ref
                    .read(favoriteMutationProvider.notifier)
                    .toggleFavorite(design.id);
                if (!success && context.mounted) {
                  await GoogleAuthBottomSheet.show(context);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.warmIvory,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isFav
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  size: 18,
                  color: isFav ? AppColors.error : AppColors.mutedText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
