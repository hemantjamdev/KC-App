import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/navigation/navigation_extensions.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../domain/models/category_model.dart';
import '../../application/providers/category_providers.dart';

/// Full-screen customer category list page with live search and Riverpod state.
class CustomerCategoryListPage extends ConsumerStatefulWidget {
  const CustomerCategoryListPage({super.key});

  @override
  ConsumerState<CustomerCategoryListPage> createState() =>
      _CustomerCategoryListPageState();
}

class _CustomerCategoryListPageState
    extends ConsumerState<CustomerCategoryListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryListProvider);
    final allCategories = ref.watch(activeCategoryListProvider);
    final isLoading = categoriesAsync.isLoading && allCategories.isEmpty;

    final visible = _searchQuery.isEmpty
        ? allCategories
        : allCategories.where((c) {
            final q = _searchQuery.toLowerCase();
            return c.name.toLowerCase().contains(q) ||
                c.slug.toLowerCase().contains(q) ||
                (c.description != null &&
                    c.description!.toLowerCase().contains(q));
          }).toList();

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (context.mounted) context.popOrGo(AppRoutes.customerHome);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary,
              size: 20,
            ),
            onPressed: () => context.popOrGo(AppRoutes.customerHome),
          ),
          title: Text(
            'Collections & Categories',
            style: GoogleFonts.playfairDisplay(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: isLoading
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppLoadingIndicator(size: 32),
                      SizedBox(height: AppSpacing.md),
                      Text(
                        'Loading collections...',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    ref.invalidate(categoryListProvider);
                    await ref.read(categoryListProvider.future);
                  },
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          AppSpacing.md,
                          AppSpacing.lg,
                          AppSpacing.md,
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                          cursorColor: AppColors.primary,
                          decoration: InputDecoration(
                            hintText: 'Search categories...',
                            hintStyle: const TextStyle(
                              color: AppColors.textHint,
                              fontSize: 14,
                            ),
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: AppColors.textMuted,
                              size: 20,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.clear_rounded,
                                      color: AppColors.textMuted,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _searchQuery = '');
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: AppColors.surface,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            border: const OutlineInputBorder(
                              borderRadius: AppRadius.borderMd,
                              borderSide: BorderSide(
                                color: AppColors.surfaceBorder,
                              ),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderRadius: AppRadius.borderMd,
                              borderSide: BorderSide(
                                color: AppColors.surfaceBorder,
                              ),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius: AppRadius.borderMd,
                              borderSide: BorderSide(
                                color: AppColors.primary,
                                width: 1.5,
                              ),
                            ),
                          ),
                          onChanged: (v) {
                            setState(() => _searchQuery = v.trim());
                          },
                        ),
                      ),
                      Expanded(
                        child: visible.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(AppSpacing.xl),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _searchController.text.isNotEmpty
                                          ? Icons.search_off_rounded
                                          : Icons.category_outlined,
                                      color: AppColors.textMuted,
                                      size: 48,
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    Text(
                                      _searchController.text.isNotEmpty
                                          ? 'No categories match your search.'
                                          : 'Categories are being prepared for this boutique.',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.lg,
                                0,
                                AppSpacing.lg,
                                AppSpacing.xl,
                              ),
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              itemCount: visible.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: AppSpacing.sm),
                              itemBuilder: (context, index) {
                                return _CategoryListCard(
                                  category: visible[index],
                                  onTap: () => context.push(
                                    AppRoutes.customerCategoryDesigns,
                                    extra: visible[index],
                                  ),
                                );
                              },
                            ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _CategoryListCard extends StatelessWidget {
  const _CategoryListCard({required this.category, required this.onTap});

  final CategoryModel category;
  final VoidCallback onTap;

  String get _initials {
    final parts = category.name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return category.name
        .substring(0, category.name.length.clamp(1, 2))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: AppColors.surfaceBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.2),
                borderRadius: AppRadius.borderMd,
              ),
              clipBehavior: Clip.antiAlias,
              child: category.imageUrl != null &&
                      category.imageUrl!.startsWith('http')
                  ? Image.network(
                      category.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildFallback(),
                    )
                  : _buildFallback(),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: GoogleFonts.playfairDisplay(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (category.description != null &&
                      category.description!.trim().isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      category.description!.trim(),
                      style: GoogleFonts.montserrat(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      color: const Color(0xFF2E7D32).withValues(alpha: 0.2),
      child: Center(
        child: Text(
          _initials,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
