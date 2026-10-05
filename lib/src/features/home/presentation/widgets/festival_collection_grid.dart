import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/app_routes.dart';
import '../../../category/domain/models/category_model.dart';
import '../../../design/application/providers/design_providers.dart';
import '../../../design/domain/models/design_model.dart';

/// Ultra-Luxury "The Festive Edit" Category Section with Vaulted Arch Product Cards.
/// Uses 100% real product data from Firestore (KC-Admin).
class FestivalCollectionGrid extends ConsumerWidget {
  const FestivalCollectionGrid({super.key, required this.festiveCategory});

  final CategoryModel festiveCategory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final designsAsync = ref.watch(designListProvider);
    final allDesigns = designsAsync.valueOrNull ?? [];

    final catId = festiveCategory.id.toLowerCase();
    final catName = festiveCategory.name.toLowerCase();

    // 1. Filter real category products from Firestore
    List<DesignModel> festiveDesigns = allDesigns.where((d) {
      if (!d.isActive) return false;
      if (d.categoryId.toLowerCase() == catId) return true;
      if (d.categoryIds.any((id) => id.toLowerCase() == catId)) return true;
      if (d.tags.any((t) => t.toLowerCase().contains(catName) || t.toLowerCase().contains('festive'))) return true;
      return false;
    }).toList();

    // Fallback to active designs if category filtering produces no matches
    if (festiveDesigns.isEmpty) {
      festiveDesigns = allDesigns.where((d) => d.isActive).toList();
    }

    // Display up to 4 real Firestore designs
    final displayDesigns = festiveDesigns.take(4).toList();

    if (displayDesigns.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF0EA), // Soft pistachio / sage cream tint
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Top Subtitle Label
          Text(
            'EXCLUSIVE EDITION',
            style: GoogleFonts.montserrat(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B756E),
              letterSpacing: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 4),

          // 2. Main Headline Title
          Text(
            festiveCategory.name.isNotEmpty
                ? 'The ${festiveCategory.name} Edit'
                : 'The Festive Edit',
            style: GoogleFonts.playfairDisplay(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
              color: const Color(0xFF162D20), // Deep boutique green
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 22),

          // 3. 2x2 Vaulted Arch Product Grid with 100% Real Firestore Data
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayDesigns.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.60, // Vaulted arch + title/price height ratio
              crossAxisSpacing: 16,
              mainAxisSpacing: 20,
            ),
            itemBuilder: (context, index) {
              final design = displayDesigns[index];
              return _FestiveArchCard(
                design: design,
                festiveCategory: festiveCategory,
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Individual Vaulted Arch Product Card rendered from real Firestore DesignModel
class _FestiveArchCard extends StatelessWidget {
  const _FestiveArchCard({
    required this.design,
    required this.festiveCategory,
  });

  final DesignModel design;
  final CategoryModel festiveCategory;

  @override
  Widget build(BuildContext context) {
    final imageUrl = (design.thumbnailUrl != null && design.thumbnailUrl!.isNotEmpty)
        ? design.thumbnailUrl!
        : (design.imageUrls.isNotEmpty ? design.imageUrls.first : '');

    return GestureDetector(
      onTap: () {
        context.push(
          AppRoutes.customerDesignDetails,
          extra: design,
        );
      },
      child: Column(
        children: [
          // Vaulted Arch Image Container
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(55),
                  bottom: Radius.circular(55),
                ),
                border: Border.all(
                  color: const Color(0xFFC7D6CB), // Soft mint/sage border outline
                  width: 1.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(53),
                  bottom: Radius.circular(53),
                ),
                child: imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (ctx, err, stack) => Container(
                          color: const Color(0xFFDCD6CB),
                          child: const Center(
                            child: Icon(
                              Icons.checkroom_rounded,
                              color: Color(0xFF162D20),
                              size: 32,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        color: const Color(0xFFDCD6CB),
                        child: const Center(
                          child: Icon(
                            Icons.checkroom_rounded,
                            color: Color(0xFF162D20),
                            size: 32,
                          ),
                        ),
                      ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Real Product Title from Firestore
          Text(
            design.name,
            style: GoogleFonts.playfairDisplay(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF162D20),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 2),

          // Real Product Price from Firestore
          Text(
            '₹${design.price.toStringAsFixed(0)}',
            style: GoogleFonts.montserrat(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF5A665D),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
