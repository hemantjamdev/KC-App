import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../design/application/providers/design_providers.dart';
import '../../../trending/presentation/widgets/instagram_trending_card.dart';
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

    final catId = category.id.toLowerCase();
    final catName = category.name.toLowerCase();

    final categoryDesigns = allDesigns.where((d) {
      if (!d.isActive) return false;
      if (d.categoryId.toLowerCase() == catId) return true;
      if (d.categoryIds.any((id) => id.toLowerCase() == catId)) return true;
      if (d.tags.any((t) => t.toLowerCase().contains(catName))) return true;
      return false;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      appBar: AppBar(
        backgroundColor: AppColors.warmIvory,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.charcoal, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          category.name,
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.charcoal,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.brandGreen,
          onRefresh: () async {
            ref.invalidate(designListProvider);
            await ref.read(designListProvider.future);
          },
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.brandGreen800),
                )
              : categoryDesigns.isEmpty
                  ? AppEmptyState(
                      icon: Icons.checkroom_rounded,
                      title: 'No products in ${category.name}',
                      message: 'New boutique designs will be added to this category soon.',
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: categoryDesigns.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: InstagramTrendingCard(
                            design: categoryDesigns[index],
                            rankIndex: index + 1,
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }
}
