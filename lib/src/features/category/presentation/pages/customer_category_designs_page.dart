import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/navigation/navigation_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../design/application/providers/design_providers.dart';
import '../../../section/presentation/widgets/section_product_list_item.dart';
import '../../domain/models/category_model.dart';

/// Customer Category Designs Page — displays real Firestore products for a specific category.
class CustomerCategoryDesignsPage extends ConsumerWidget {
  const CustomerCategoryDesignsPage({super.key, required this.category});

  final CategoryModel category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final designsAsync = ref.watch(designListProvider);
    final allDesigns = designsAsync.valueOrNull ?? [];
    final isLoading = designsAsync.isLoading;

    final catId = category.id.toLowerCase().trim();
    final catName = category.name.toLowerCase().trim();
    final catSlug = category.slug.toLowerCase().trim();

    final categoryDesigns = allDesigns.where((d) {
      if (!d.isActive) return false;

      final dCatId = d.categoryId.toLowerCase().trim();
      if (catId.isNotEmpty && dCatId == catId) return true;
      if (catSlug.isNotEmpty && dCatId == catSlug) return true;

      final dCatIds = d.categoryIds.map((id) => id.toLowerCase().trim()).toList();
      if (catId.isNotEmpty && dCatIds.contains(catId)) return true;
      if (catSlug.isNotEmpty && dCatIds.contains(catSlug)) return true;

      if (catName.isNotEmpty &&
          d.tags.any((t) => t.toLowerCase().contains(catName))) {
        return true;
      }
      if (catSlug.isNotEmpty &&
          d.tags.any((t) => t.toLowerCase().contains(catSlug))) {
        return true;
      }
      if (catName.isNotEmpty &&
          d.name.toLowerCase().contains(catName)) {
        return true;
      }
      if (catSlug.isNotEmpty &&
          d.searchKeywords.any((k) => k.toLowerCase().contains(catSlug))) {
        return true;
      }

      return false;
    }).toList();

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (context.mounted) context.popOrGo(AppRoutes.customerHome);
      },
      child: Scaffold(
        backgroundColor: AppColors.warmIvory,
        appBar: AppBar(
          backgroundColor: AppColors.surfaceWhite,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.charcoal,
              size: 20,
            ),
            onPressed: () => context.popOrGo(AppRoutes.customerHome),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                category.name,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: AppColors.charcoal,
                ),
              ),
              if (!isLoading)
                Text(
                  '${categoryDesigns.length} ${categoryDesigns.length == 1 ? "design" : "designs"} available',
                  style: GoogleFonts.montserrat(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.mutedText,
                  ),
                ),
            ],
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.surfaceWhite,
            onRefresh: () async {
              ref.invalidate(designListProvider);
              await ref.read(designListProvider.future);
            },
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  )
                : categoryDesigns.isEmpty
                    ? AppEmptyState(
                        icon: Icons.checkroom_rounded,
                        title: 'No products in ${category.name}',
                        message:
                            'New boutique designs will be added to this collection soon.',
                        actionLabel: 'Browse All Categories',
                        onAction: () =>
                            context.push(AppRoutes.customerCategoryList),
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                        itemCount: categoryDesigns.length,
                        separatorBuilder: (ctx, idx) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          return SectionProductListItem(
                            design: categoryDesigns[index],
                          );
                        },
                      ),
          ),
        ),
      ),
    );
  }
}
