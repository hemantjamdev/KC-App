import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../boutique/presentation/controllers/boutique_selection_controller.dart';
import '../../../category/domain/models/category_model.dart';
import '../../domain/models/design_model.dart';
import '../controllers/design_controller.dart';

/// Category Design Listing Page for KC-App — displays customer-eligible designs in a specific category.
class CustomerDesignListPage extends StatefulWidget {
  const CustomerDesignListPage({super.key, required this.category});
  final CategoryModel category;

  @override
  State<CustomerDesignListPage> createState() => _CustomerDesignListPageState();
}

class _CustomerDesignListPageState extends State<CustomerDesignListPage> {
  late DesignController _controller;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final scope = BoutiqueSelectionScope.of(context);
    final boutiqueId = scope.selectedBoutique?.id ?? '';
    final branchId = scope.selectedBranch?.id ?? '';

    _controller = DesignController(
      boutiqueId: boutiqueId,
      branchId: branchId,
      activeCategoryIds: [widget.category.id],
    );
    _controller.filterByCategory(widget.category.id);
    _controller.addListener(_onUpdate);
    _controller.loadDesigns();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onUpdate);
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scope = BoutiqueSelectionScope.of(context);
    final boutique = scope.selectedBoutique;
    final branch = scope.selectedBranch;
    final visible = _controller.visibleDesigns;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.category.name,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: _controller.isLoading
            ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppLoadingIndicator(size: 32),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      'Loading designs...',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Search Bar & Context Row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      AppSpacing.sm,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              boutique?.name ?? '',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (branch != null) ...[
                              const Text(
                                ' • ',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                branch.name,
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextField(
                          controller: _searchController,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                          cursorColor: AppColors.primary,
                          decoration: InputDecoration(
                            hintText: 'Search ${widget.category.name}...',
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
                                      _controller.clearSearch();
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
                          onChanged: (val) {
                            _controller.searchDesigns(val);
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: visible.isEmpty
                        ? _buildEmptyState()
                        : GridView.builder(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            physics: const BouncingScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.72,
                                  crossAxisSpacing: AppSpacing.md,
                                  mainAxisSpacing: AppSpacing.md,
                                ),
                            itemCount: visible.length,
                            itemBuilder: (context, index) {
                              final design = visible[index];
                              return _CustomerDesignCard(
                                design: design,
                                categoryName: widget.category.name,
                                onTap: () => context.push(
                                  AppRoutes.customerDesignDetails,
                                  extra: design,
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isSearching = _searchController.text.isNotEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSearching
                  ? Icons.search_off_rounded
                  : Icons.dry_cleaning_rounded,
              color: AppColors.textMuted,
              size: 48,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              isSearching
                  ? 'No designs match your search.'
                  : 'No designs are currently available in this category.',
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
    );
  }
}

class _CustomerDesignCard extends StatelessWidget {
  const _CustomerDesignCard({
    required this.design,
    required this.categoryName,
    required this.onTap,
  });

  final DesignModel design;
  final String categoryName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  design.thumbnailUrl != null
                      ? Image.network(
                          design.thumbnailUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _fallbackImage(),
                        )
                      : _fallbackImage(),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColors.background.withValues(alpha: 0.7),
                          ],
                          stops: const [0.6, 1.0],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm + 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoryName.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    design.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (design.shortDescription != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      design.shortDescription!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackImage() {
    return Container(
      color: AppColors.surfaceLight,
      child: const Center(
        child: Icon(Icons.style_outlined, color: AppColors.textMuted, size: 36),
      ),
    );
  }
}
