import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/kc_app_bar.dart';
import '../../../design/domain/models/design_model.dart';
import '../../application/providers/section_providers.dart';
import '../../domain/models/section_model.dart';

/// Customer Section Details Page — displays all resolved designs for a specific section in a responsive grid with search.
class CustomerSectionDetailsPage extends ConsumerStatefulWidget {
  const CustomerSectionDetailsPage({super.key, required this.section});
  final SectionModel section;

  @override
  ConsumerState<CustomerSectionDetailsPage> createState() =>
      _CustomerSectionDetailsPageState();
}

class _CustomerSectionDetailsPageState
    extends ConsumerState<CustomerSectionDetailsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allResolved = ref.watch(
      sectionResolvedDesignsProvider(widget.section),
    );
    final visible = allResolved.where((d) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      final inName = d.name.toLowerCase().contains(q);
      final inTags = d.tags.any((t) => t.toLowerCase().contains(q));
      return inName || inTags;
    }).toList();

    return PopScope(
      canPop: context.canPop(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: KCAppBar(title: widget.section.title),
        body: SafeArea(
          child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                        if (widget.section.subtitle != null) ...[
                          Text(
                            widget.section.subtitle!,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 13,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                        TextField(
                          controller: _searchController,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                          cursorColor: AppColors.primary,
                          decoration: InputDecoration(
                            hintText: 'Search collection…',
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
                          onChanged: (val) =>
                              setState(() => _searchQuery = val.trim()),
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
                              return _SectionDetailsCard(
                                design: design,
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
    ),
  );
}

  Widget _buildEmptyState() {
    final isSearching = _searchQuery.isNotEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSearching
                  ? Icons.search_off_rounded
                  : Icons.collections_bookmark_outlined,
              color: AppColors.textMuted,
              size: 48,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              isSearching
                  ? 'No designs match your search.'
                  : 'No designs are currently available in this collection.',
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

class _SectionDetailsCard extends StatelessWidget {
  const _SectionDetailsCard({required this.design, required this.onTap});

  final DesignModel design;
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
                    design.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
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
