import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../boutique/presentation/controllers/boutique_selection_controller.dart';
import '../../../category/data/repositories/category_firestore_repository.dart';
import '../../../category/domain/models/category_model.dart';
import '../../domain/models/design_model.dart';
import '../controllers/design_controller.dart';

/// All Designs Page for KC-App — displays all customer-eligible designs across categories with search and category filtering.
class CustomerAllDesignsPage extends StatefulWidget {
  const CustomerAllDesignsPage({super.key});

  @override
  State<CustomerAllDesignsPage> createState() => _CustomerAllDesignsPageState();
}

class _CustomerAllDesignsPageState extends State<CustomerAllDesignsPage> {
  late DesignController _controller;
  final TextEditingController _searchController = TextEditingController();
  final CategoryFirestoreRepository _categoryRepository = CategoryFirestoreRepository();
  List<CategoryModel> _categories = [];
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    final scope = BoutiqueSelectionScope.of(context);
    final boutiqueId = scope.selectedBoutique?.id ?? '';
    final branchId = scope.selectedBranch?.id ?? '';

    _controller = DesignController(
      boutiqueId: boutiqueId,
      branchId: branchId,
      activeCategoryIds: [],
    );
    _controller.addListener(_onUpdate);

    _initData(boutiqueId);
  }

  Future<void> _initData(String boutiqueId) async {
    try {
      final list = await _categoryRepository.watchCategories(boutiqueId).first;
      _categories = list.where((c) => c.isActive).toList();
    } catch (_) {
      _categories = [];
    }
    if (!mounted) return;
    await _controller.loadDesigns();
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

  String _getCategoryName(String categoryId) {
    try {
      return _categories.firstWhere((c) => c.id == categoryId).name;
    } catch (_) {
      return 'Design';
    }
  }

  Widget _categoryChip(String? id, String label) {
    final selected = _selectedCategoryId == id;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategoryId = id;
          _controller.filterByCategory(id);
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: AppRadius.borderPill,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.surfaceBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.background : AppColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = _controller.visibleDesigns;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'All Designs',
          style: TextStyle(
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
                      'Loading catalogue...',
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      AppSpacing.xs,
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                      cursorColor: AppColors.primary,
                      decoration: InputDecoration(
                        hintText: 'Search all designs, tags...',
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
                  ),
                  // Category filter chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        _categoryChip(null, 'All'),
                        ..._categories.map(
                          (c) => Padding(
                            padding: const EdgeInsets.only(left: AppSpacing.sm),
                            child: _categoryChip(c.id, c.name),
                          ),
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
                              return _AllDesignsCard(
                                design: design,
                                categoryName: _getCategoryName(
                                  design.categoryId,
                                ),
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
    final hasFilter =
        _searchController.text.isNotEmpty || _selectedCategoryId != null;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasFilter ? Icons.search_off_rounded : Icons.inventory_2_outlined,
              color: AppColors.textMuted,
              size: 48,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              hasFilter
                  ? 'No designs match your search.'
                  : 'Designs are being prepared for this branch.',
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

class _AllDesignsCard extends StatelessWidget {
  const _AllDesignsCard({
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
                            AppColors.background.withValues(alpha: 0.6),
                          ],
                          stops: const [0.5, 1.0],
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
