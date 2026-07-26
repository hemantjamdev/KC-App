import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kc_app/src/features/auth/presentation/controllers/customer_auth_controller.dart';
import 'package:kc_app/src/features/boutique/presentation/controllers/boutique_selection_controller.dart';
import 'package:kc_app/src/features/stitching/domain/models/stitching_order_model.dart';
import 'package:kc_app/src/features/stitching/presentation/controllers/stitching_order_controller.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loading_indicator.dart';

/// Customer Stitching Order List Page ("My Stitching").
class CustomerStitchingOrderListPage extends StatefulWidget {
  const CustomerStitchingOrderListPage({super.key});

  @override
  State<CustomerStitchingOrderListPage> createState() =>
      _CustomerStitchingOrderListPageState();
}

class _CustomerStitchingOrderListPageState
    extends State<CustomerStitchingOrderListPage> {
  late final CustomerAuthController _authController;
  StitchingOrderController? _stitchingController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _authController = CustomerAuthController();
    _authController.addListener(_onUpdate);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = BoutiqueSelectionScope.of(context);
    final boutiqueId = scope.selectedBoutique?.id ?? 'boutique_01';
    final branchId = scope.selectedBranch?.id;
    final customerId = _authController.currentCustomer?.id ?? 'cust_01';

    if (_authController.isAuthenticated) {
      _stitchingController?.removeListener(_onUpdate);
      _stitchingController = StitchingOrderController(
        boutiqueId: boutiqueId,
        branchId: branchId,
        customerId: customerId,
      );
      _stitchingController?.addListener(_onUpdate);
    }
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _searchController.dispose();
    _stitchingController?.removeListener(_onUpdate);
    _stitchingController?.dispose();
    _authController.removeListener(_onUpdate);
    _authController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAuth = _authController.isAuthenticated;
    final orders = _stitchingController?.visibleOrders ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'My Stitching',
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
        child: !isAuth
            ? _buildGuestCard()
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      0,
                    ),
                    child: Column(
                      children: [
                        // Search Field
                        TextField(
                          controller: _searchController,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                          cursorColor: AppColors.primary,
                          decoration: InputDecoration(
                            hintText: 'Search order number or design name…',
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
                                      _stitchingController?.searchOrders('');
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
                          onChanged: (q) =>
                              _stitchingController?.searchOrders(q),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        // Status Filter Chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _statusFilterChip(null, 'All Orders'),
                              const SizedBox(width: AppSpacing.xs),
                              ...StitchingOrderStatus.values.map(
                                (status) => Padding(
                                  padding: const EdgeInsets.only(
                                    right: AppSpacing.xs,
                                  ),
                                  child: _statusFilterChip(
                                    status,
                                    status.customerLabel,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _stitchingController?.isLoading == true
                        ? const Center(child: AppLoadingIndicator(size: 32))
                        : orders.isEmpty
                        ? _buildEmptyState()
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.lg,
                              AppSpacing.sm,
                              AppSpacing.lg,
                              AppSpacing.xxl,
                            ),
                            physics: const BouncingScrollPhysics(),
                            itemCount: orders.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: AppSpacing.md),
                            itemBuilder: (context, i) {
                              final order = orders[i];
                              return _CustomerOrderCard(
                                order: order,
                                onTap: () => context.push(
                                  AppRoutes.customerStitchingDetails,
                                  extra: order,
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

  Widget _statusFilterChip(StitchingOrderStatus? status, String label) {
    final selected = _stitchingController?.selectedStatusFilter == status;
    return GestureDetector(
      onTap: () => _stitchingController?.filterByStatus(status),
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

  Widget _buildGuestCard() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.borderXl,
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.content_cut_rounded,
                  size: 56,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'Sign in to view your stitching orders',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'Connect your Google account to track order progress, view measurements, and receive updates.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  text: 'Sign in with Google',
                  icon: Icons.login_rounded,
                  onPressed: () => context.push(AppRoutes.customerProfile),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text(
                    'Continue Browsing',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasFilter =
        _searchController.text.isNotEmpty ||
        _stitchingController?.selectedStatusFilter != null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasFilter
                  ? Icons.search_off_rounded
                  : Icons.content_paste_rounded,
              color: AppColors.textMuted,
              size: 48,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              hasFilter
                  ? 'No stitching orders match your search.'
                  : 'You do not have any stitching orders yet.',
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

class _CustomerOrderCard extends StatelessWidget {
  const _CustomerOrderCard({required this.order, required this.onTap});

  final StitchingOrderModel order;
  final VoidCallback onTap;

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'TBD';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final primaryDesign = order.designReferences.isNotEmpty
        ? order.designReferences.first.designName
        : 'Custom Design';
    final extraCount = order.designReferences.length - 1;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: AppColors.surfaceBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.orderNumber,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: AppRadius.borderPill,
                  ),
                  child: Text(
                    order.status.customerLabel,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              primaryDesign,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (extraCount > 0)
              Text(
                '+ $extraCount additional item${extraCount > 1 ? 's' : ''}',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            const SizedBox(height: AppSpacing.md),

            // Progress bar
            ClipRRect(
              borderRadius: AppRadius.borderPill,
              child: LinearProgressIndicator(
                value: order.status.progressFraction,
                backgroundColor: AppColors.surfaceLight,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Expected: ${_formatDate(order.expectedReadyAt)}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
                const Row(
                  children: [
                    Text(
                      'View Details',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.primary,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
