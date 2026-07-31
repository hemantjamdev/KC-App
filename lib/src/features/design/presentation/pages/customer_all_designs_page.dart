import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
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
  final CategoryFirestoreRepository _categoryRepository =
      CategoryFirestoreRepository();
  List<CategoryModel> _categories = [];
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _controller = DesignController(
      boutiqueId: 'boutique_01',
      branchId: '',
      activeCategoryIds: [],
    );
    _controller.addListener(_onUpdate);

    _initData('boutique_01');
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
                  const SizedBox(height: AppSpacing.sm),
                  Expanded(
                    child: visible.isEmpty
                        ? _buildEmptyState()
                        : ListView.separated(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            physics: const BouncingScrollPhysics(),
                            itemCount: visible.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: AppSpacing.md),
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
    final hasImg = design.thumbnailUrl != null || design.imageUrls.isNotEmpty;
    final imgUrl = design.thumbnailUrl ?? (design.imageUrls.isNotEmpty ? design.imageUrls.first : '');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.2),
                borderRadius: AppRadius.borderMd,
              ),
              clipBehavior: Clip.antiAlias,
              child: hasImg && imgUrl.startsWith('http')
                  ? Image.network(
                      imgUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _fallbackImage(),
                    )
                  : _fallbackImage(),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoryName.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
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
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${design.price.toInt()}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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

  Widget _fallbackImage() {
    return Container(
      color: const Color(0xFF2E7D32).withValues(alpha: 0.2),
      child: const Center(
        child: Icon(
          Icons.checkroom_rounded,
          color: AppColors.textMuted,
          size: 24,
        ),
      ),
    );
  }
}
