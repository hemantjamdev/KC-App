import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../category/domain/models/category_model.dart';

/// Ultra-luxury horizontal category story capsules for quick category browsing.
class HomeCategoryCapsules extends StatelessWidget {
  const HomeCategoryCapsules({super.key, required this.categories});

  final List<CategoryModel> categories;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 98,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length + 1,
        separatorBuilder: (ctx, idx) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          if (index == categories.length) {
            // "View All" pill at the end
            return _CategoryItem(
              title: 'View All',
              isViewAll: true,
              onTap: () => context.push(AppRoutes.customerCategoryList),
            );
          }

          final cat = categories[index];
          return _CategoryItem(
            title: cat.name,
            imageUrl: cat.imageUrl,
            onTap: () => context.push(
              AppRoutes.customerCategoryDesigns,
              extra: cat,
            ),
          );
        },
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
    required this.title,
    this.imageUrl,
    this.isViewAll = false,
    required this.onTap,
  });

  final String title;
  final String? imageUrl;
  final bool isViewAll;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasImg = imageUrl != null && imageUrl!.startsWith('http');

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 66,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.goldAccent,
                    AppColors.goldBronze.withValues(alpha: 0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceWhite,
                ),
                clipBehavior: Clip.antiAlias,
                child: isViewAll
                    ? const Center(
                        child: Icon(
                          Icons.grid_view_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      )
                    : (hasImg
                        ? CachedNetworkImage(
                            imageUrl: imageUrl!,
                            fit: BoxFit.cover,
                            errorWidget: (context, error, stackTrace) =>
                                _fallbackIcon(),
                          )
                        : _fallbackIcon()),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: GoogleFonts.montserrat(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: AppColors.charcoal,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackIcon() {
    return Container(
      color: AppColors.brandGreen50,
      child: const Center(
        child: Icon(
          Icons.checkroom_rounded,
          color: AppColors.primary,
          size: 24,
        ),
      ),
    );
  }
}
