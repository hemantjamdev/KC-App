import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../boutique/presentation/controllers/boutique_selection_controller.dart';
import '../../../category/presentation/controllers/category_controller.dart';
import '../../../category/presentation/widgets/home_category_section.dart';
import '../../../design/presentation/controllers/design_controller.dart';
import '../../../design/presentation/widgets/customer_design_card.dart';
import '../../../section/presentation/controllers/section_controller.dart';
import '../../../section/presentation/widgets/customer_design_section.dart';

/// Customer Home Page — Editorial boutique discovery experience.
class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  late CategoryController _categoryController;
  late DesignController _designController;
  late SectionController _sectionController;

  @override
  void initState() {
    super.initState();
    final scope = BoutiqueSelectionScope.of(context);
    final boutiqueId = scope.selectedBoutique?.id ?? '';
    final branchId = scope.selectedBranch?.id ?? '';

    _categoryController = CategoryController(boutiqueId: boutiqueId);
    _categoryController.addListener(_onUpdate);
    _categoryController.loadCategories();

    _designController = DesignController(
      boutiqueId: boutiqueId,
      branchId: branchId,
      activeCategoryIds: [],
    );
    _designController.addListener(_onUpdate);

    _sectionController = SectionController(
      boutiqueId: boutiqueId,
      branchId: branchId,
      designController: _designController,
    );
    _sectionController.addListener(_onUpdate);

    _loadData(boutiqueId, branchId);
  }

  Future<void> _loadData(String boutiqueId, String branchId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;

    final activeCategories = _categoryController.visibleCategories;
    final activeCatIds = activeCategories.map((c) => c.id).toList();

    _designController = DesignController(
      boutiqueId: boutiqueId,
      branchId: branchId,
      activeCategoryIds: activeCatIds,
    );
    _designController.addListener(_onUpdate);

    _sectionController = SectionController(
      boutiqueId: boutiqueId,
      branchId: branchId,
      designController: _designController,
    );
    _sectionController.addListener(_onUpdate);

    await _designController.loadDesigns();
    if (mounted) {
      await _sectionController.loadSections();
    }
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _categoryController.removeListener(_onUpdate);
    _categoryController.dispose();
    _designController.removeListener(_onUpdate);
    _designController.dispose();
    _sectionController.removeListener(_onUpdate);
    _sectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectionController = BoutiqueSelectionScope.of(context);
    final boutique = selectionController.selectedBoutique;
    final branch = selectionController.selectedBranch;
    final curatingSections = _sectionController.visibleSections;
    final allDesigns = _designController.visibleDesigns;

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // App Header & Boutique Context
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.brandGreen100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'KAPADA CREATION',
                                  style: TextStyle(
                                    color: AppColors.brandGreen900,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                boutique?.name ?? 'Kapada Boutique',
                                style: AppTypography.pageTitle,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (branch != null)
                                Text(
                                  branch.name,
                                  style: AppTypography.caption,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),

                        // Change location action
                        IconButton(
                          icon: const Icon(Icons.pin_drop_outlined, color: AppColors.brandGreen800, size: 22),
                          tooltip: 'Change location',
                          onPressed: () {
                            selectionController.clearAll();
                            context.go(AppRoutes.customerSelectBoutique);
                          },
                        ),
                        // Notification bell action
                        IconButton(
                          icon: const Icon(
                            Icons.notifications_outlined,
                            color: AppColors.brandGreen800,
                            size: 22,
                          ),
                          onPressed: () => context.push(AppRoutes.customerNotificationList),
                        ),
                        // Profile Entry action
                        IconButton(
                          icon: const Icon(
                            Icons.person_outline_rounded,
                            color: AppColors.brandGreen800,
                            size: 22,
                          ),
                          onPressed: () => context.push(AppRoutes.customerProfile),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Hero Banner / Welcome Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.brandGreen900,
                            AppColors.brandGreen800,
                          ],
                        ),
                        borderRadius: AppRadius.borderLg,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Exquisite Boutique\nCollections',
                            style: TextStyle(
                              color: AppColors.surfaceWhite,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Crafted with tradition, designed for elegance.',
                            style: TextStyle(
                              color: AppColors.brandGreen100,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),

            // Category Section
            SliverToBoxAdapter(
              child: _categoryController.isLoading
                  ? const AppLoadingState(message: 'Loading categories...')
                  : HomeCategorySection(
                      categories: _categoryController.visibleCategories,
                      onViewAll: () => context.go(AppRoutes.customerCategoryList),
                      onCategoryTap: (category) => context.push(
                        AppRoutes.customerCategoryDesigns,
                        extra: category,
                      ),
                    ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

            // Featured Design Banner if designs exist
            if (allDesigns.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Featured Highlight', style: AppTypography.sectionTitle),
                      const SizedBox(height: AppSpacing.sm),
                      CustomerDesignCard(
                        design: allDesigns.first,
                        variant: DesignCardVariant.featured,
                        onTap: () => context.push(
                          AppRoutes.customerDesignDetails,
                          extra: allDesigns.first,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),

            // Dynamic Curated Sections
            if (_sectionController.isLoading || _designController.isLoading)
              const SliverToBoxAdapter(
                child: AppLoadingState(message: 'Curating sections...'),
              )
            else if (curatingSections.isEmpty && allDesigns.isEmpty)
              const SliverToBoxAdapter(
                child: AppEmptyState(
                  title: 'No Designs Available',
                  description: 'Check back soon for new boutique releases.',
                  icon: Icons.style_outlined,
                ),
              )
            else
              SliverList.separated(
                itemCount: curatingSections.length,
                separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xl),
                itemBuilder: (context, index) {
                  final sec = curatingSections[index];
                  final designs = _sectionController.getDesignsForSection(
                    sec,
                    limit: 6,
                  );
                  return CustomerDesignSection(
                    section: sec,
                    designs: designs,
                    onViewAllTap: () => context.push(
                      AppRoutes.customerSectionDetails,
                      extra: sec,
                    ),
                  );
                },
              ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
          ],
        ),
      ),
    );
  }
}
