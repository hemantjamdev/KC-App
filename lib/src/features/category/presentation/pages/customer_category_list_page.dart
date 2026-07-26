import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../boutique/presentation/controllers/boutique_selection_controller.dart';
import '../../domain/models/category_model.dart';
import '../controllers/category_controller.dart';

/// Full-screen customer category list page with search.
class CustomerCategoryListPage extends StatefulWidget {
  const CustomerCategoryListPage({super.key});

  @override
  State<CustomerCategoryListPage> createState() =>
      _CustomerCategoryListPageState();
}

class _CustomerCategoryListPageState extends State<CustomerCategoryListPage> {
  late CategoryController _controller;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final boutiqueId =
        BoutiqueSelectionScope.of(context).selectedBoutique?.id ?? '';
    _controller = CategoryController(boutiqueId: boutiqueId);
    _controller.addListener(_onUpdate);
    _controller.loadCategories();
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
    final visible = _controller.visibleCategories;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'All Categories',
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
          onPressed: () => context.go(AppRoutes.customerHome),
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
                      'Loading collections...',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            : Column(
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
                      onChanged: (v) {
                        _controller.searchCategories(v);
                        setState(() {});
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
                        : GridView.builder(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.lg,
                              0,
                              AppSpacing.lg,
                              AppSpacing.xl,
                            ),
                            physics: const BouncingScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: AppSpacing.md,
                                  mainAxisSpacing: AppSpacing.md,
                                  childAspectRatio: 0.85,
                                ),
                            itemCount: visible.length,
                            itemBuilder: (context, index) {
                              return _CategoryGridCard(
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
    );
  }
}

class _CategoryGridCard extends StatelessWidget {
  const _CategoryGridCard({required this.category, required this.onTap});

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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.borderXl,
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: AppRadius.borderXl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: category.imageUrl != null
                    ? Image.network(
                        category.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _buildFallback(),
                      )
                    : _buildFallback(),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.sm + 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (category.description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        category.description!,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      color: AppColors.surfaceLight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _initials,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          const Icon(
            Icons.auto_awesome_rounded,
            color: AppColors.primary,
            size: 16,
          ),
        ],
      ),
    );
  }
}
