import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../boutique/presentation/controllers/boutique_selection_controller.dart';
import '../../domain/models/design_model.dart';

/// Customer Design Details Page for KC-App — high-end editorial display of design details.
class CustomerDesignDetailsPage extends StatefulWidget {
  const CustomerDesignDetailsPage({super.key, required this.design});
  final DesignModel design;

  @override
  State<CustomerDesignDetailsPage> createState() =>
      _CustomerDesignDetailsPageState();
}

class _CustomerDesignDetailsPageState extends State<CustomerDesignDetailsPage> {
  int _activeImageIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<String> get _allImages {
    final list = <String>[];
    if (widget.design.thumbnailUrl != null) {
      list.add(widget.design.thumbnailUrl!);
    }
    list.addAll(widget.design.imageUrls);
    if (list.isEmpty) return ['https://via.placeholder.com/600x800'];
    return list;
  }

  String _getCategoryName() {
    return 'Collection';
  }

  void _onSaveToFavourites() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Favourites will be connected in a later slice.'),
        backgroundColor: AppColors.surfaceLight,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onAskBoutique() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Boutique enquiry will be connected later.'),
        backgroundColor: AppColors.surfaceLight,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scope = BoutiqueSelectionScope.of(context);
    final boutique = scope.selectedBoutique;
    final branch = scope.selectedBranch;
    final images = _allImages;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Hero Image Gallery Header
              SliverAppBar(
                expandedHeight: 420,
                pinned: true,
                backgroundColor: AppColors.background,
                leading: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  child: CircleAvatar(
                    backgroundColor: AppColors.background.withValues(
                      alpha: 0.7,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.textPrimary,
                      ),
                      onPressed: () => context.pop(),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      images.isNotEmpty
                          ? PageView.builder(
                              controller: _pageController,
                              itemCount: images.length,
                              onPageChanged: (i) =>
                                  setState(() => _activeImageIndex = i),
                              itemBuilder: (context, i) {
                                return Image.network(
                                  images[i],
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => _fallbackImage(),
                                );
                              },
                            )
                          : _fallbackImage(),
                      // Bottom gradient overlay
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                AppColors.background.withValues(alpha: 0.95),
                              ],
                              stops: const [0.7, 1.0],
                            ),
                          ),
                        ),
                      ),
                      // Carousel Indicator dots
                      if (images.length > 1)
                        Positioned(
                          bottom: AppSpacing.md,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              images.length,
                              (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                width: _activeImageIndex == index ? 20 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: _activeImageIndex == index
                                      ? AppColors.primary
                                      : AppColors.textMuted.withValues(
                                          alpha: 0.5,
                                        ),
                                  borderRadius: AppRadius.borderPill,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Design Content Body
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    120, // Space for bottom fixed action buttons
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Tag
                      Text(
                        _getCategoryName().toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      // Design Name
                      Text(
                        widget.design.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // Boutique & Branch Context Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs + 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: AppRadius.borderPill,
                          border: Border.all(color: AppColors.surfaceBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.storefront_rounded,
                              color: AppColors.primary,
                              size: 16,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              '${boutique?.name ?? ''} • ${branch?.name ?? ''}',
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.design.shortDescription != null) ...[
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          widget.design.shortDescription!,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                            height: 1.4,
                          ),
                        ),
                      ],
                      if (widget.design.description != null) ...[
                        const SizedBox(height: AppSpacing.lg),
                        const Text(
                          'Design Overview',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          widget.design.description!,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 14,
                            height: 1.6,
                          ),
                        ),
                      ],
                      if (widget.design.tags.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xl),
                        const Text(
                          'Style Tags',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.xs,
                          children: widget.design.tags
                              .map(
                                (t) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: AppSpacing.xs,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceLight,
                                    borderRadius: AppRadius.borderPill,
                                    border: Border.all(
                                      color: AppColors.surfaceBorder,
                                    ),
                                  ),
                                  child: Text(
                                    '#$t',
                                    style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom Fixed Action Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: const Border(
                  top: BorderSide(color: AppColors.surfaceBorder),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: AppButton(
                        text: 'Save to Favourites',
                        icon: Icons.favorite_border_rounded,
                        onPressed: _onSaveToFavourites,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      flex: 1,
                      child: AppButton(
                        text: 'Ask Boutique',
                        variant: AppButtonVariant.secondary,
                        onPressed: _onAskBoutique,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallbackImage() {
    return Container(
      color: AppColors.surfaceLight,
      child: const Center(
        child: Icon(Icons.style_outlined, color: AppColors.textMuted, size: 64),
      ),
    );
  }
}
