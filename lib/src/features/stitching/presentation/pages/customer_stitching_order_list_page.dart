import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/customer_empty_state.dart';
import '../../../auth/application/providers/auth_providers.dart';
import '../../../auth/presentation/widgets/google_auth_bottom_sheet.dart';
import '../../application/providers/stitching_providers.dart';
import '../../domain/models/stitching_order_model.dart';
import '../widgets/stitching_order_card.dart';
import '../widgets/stitching_request_bottom_sheet.dart';

/// Customer "My Stitching" Tab Page.
/// Protected action: Requires Google Auth.
/// Displays customer's real stitching requests streamed from Firestore `stitchingOrders` collection.
class CustomerStitchingOrderListPage extends ConsumerStatefulWidget {
  const CustomerStitchingOrderListPage({super.key});

  @override
  ConsumerState<CustomerStitchingOrderListPage> createState() =>
      _CustomerStitchingOrderListPageState();
}

class _CustomerStitchingOrderListPageState
    extends ConsumerState<CustomerStitchingOrderListPage> {
  StitchingOrderStatus? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final user = ref.watch(currentCustomerUserProvider);

    if (!isAuthenticated || user == null) {
      return Scaffold(
        backgroundColor: AppColors.warmIvory,
        body: SafeArea(
          child: CustomerEmptyState(
            icon: Icons.design_services_outlined,
            title: 'Track Your Custom Tailoring',
            subtitle:
                'Sign in with Google to request custom stitching, view order progress, and get pickup notifications.',
            actionLabel: 'Continue with Google',
            action: () => GoogleAuthBottomSheet.show(context),
          ),
        ),
      );
    }

    final customerOrdersAsync = ref.watch(customerOrderListProvider(user.uid));
    final allOrders = customerOrdersAsync.valueOrNull ?? [];
    final isLoading = customerOrdersAsync.isLoading;

    final filteredOrders = _selectedStatus == null
        ? allOrders
        : allOrders.where((o) => o.status == _selectedStatus).toList();

    final totalCount = allOrders.length;
    final requestedCount =
        allOrders.where((o) => o.status == StitchingOrderStatus.requested).length;
    final acceptedCount =
        allOrders.where((o) => o.status == StitchingOrderStatus.accepted).length;
    final completedCount =
        allOrders.where((o) => o.status == StitchingOrderStatus.completed).length;

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final submitted = await StitchingRequestBottomSheet.show(context);
          if (submitted == true && context.mounted) {
            AppToast.show(
              context,
              'Stitching request submitted successfully!',
              type: ToastType.success,
            );
          }
        },
        backgroundColor: AppColors.brandGreen900,
        foregroundColor: AppColors.surfaceWhite,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, size: 20),
        label: Text(
          'New Request',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.brandGreen,
          backgroundColor: AppColors.surfaceWhite,
          onRefresh: () async {
            ref.invalidate(customerOrderListProvider(user.uid));
            await ref.read(customerOrderListProvider(user.uid).future);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // ── Header Title Section ─────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Stitching',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: AppColors.charcoal,
                        ),
                      ),
                      Text(
                        'Custom tailoring & status updates',
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: AppColors.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Executive Summary KPI Banner Card ───────────────────
              if (allOrders.isNotEmpty)
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(20, 4, 20, 14),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.brandGreen900,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.brandGreen900.withValues(alpha: 0.25),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFFD54F),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'MY STITCHING SUMMARY',
                                  style: GoogleFonts.montserrat(
                                    color: const Color(0xFFFFD54F),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: () => setState(() => _selectedStatus = null),
                              child: Text(
                                '$totalCount Total',
                                style: GoogleFonts.montserrat(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        InkWell(
                          onTap: () => setState(() => _selectedStatus = null),
                          child: Text(
                            '$totalCount Tailoring Requests',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Clean 3-Metric Row
                        Row(
                          children: [
                            Expanded(
                              child: _kpiStatColumn(
                                'Requested',
                                '$requestedCount',
                                () => setState(
                                  () => _selectedStatus = StitchingOrderStatus.requested,
                                ),
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 28,
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                            Expanded(
                              child: _kpiStatColumn(
                                'Accepted',
                                '$acceptedCount',
                                () => setState(
                                  () => _selectedStatus = StitchingOrderStatus.accepted,
                                ),
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 28,
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                            Expanded(
                              child: _kpiStatColumn(
                                'Completed',
                                '$completedCount',
                                () => setState(
                                  () => _selectedStatus = StitchingOrderStatus.completed,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              // ── Status Filter Chips ──────────────────────────────
              if (allOrders.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _statusFilterChip(null, 'All Requests'),
                          const SizedBox(width: 8),
                          _statusFilterChip(
                            StitchingOrderStatus.requested,
                            'Requested ($requestedCount)',
                          ),
                          const SizedBox(width: 8),
                          _statusFilterChip(
                            StitchingOrderStatus.accepted,
                            'Accepted ($acceptedCount)',
                          ),
                          const SizedBox(width: 8),
                          _statusFilterChip(
                            StitchingOrderStatus.completed,
                            'Completed ($completedCount)',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // ── Orders List / State Views ────────────────────────
              if (isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.brandGreen800,
                      strokeWidth: 2,
                    ),
                  ),
                )
              else if (allOrders.isEmpty)
                const SliverFillRemaining(
                  child: AppEmptyState(
                    icon: Icons.design_services_outlined,
                    title: 'No stitching requests yet',
                    message:
                        'Tap + New Request below to submit a custom tailoring or alteration request.',
                  ),
                )
              else if (filteredOrders.isEmpty)
                SliverFillRemaining(
                  child: AppEmptyState(
                    icon: Icons.filter_alt_off_rounded,
                    title: 'No matching requests',
                    message:
                        'No requests found for the selected status filter.',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, idx) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: StitchingOrderCard(order: filteredOrders[idx]),
                      ),
                      childCount: filteredOrders.length,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _kpiStatColumn(String label, String count, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              count,
              style: GoogleFonts.montserrat(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusFilterChip(StitchingOrderStatus? status, String label) {
    final selected = _selectedStatus == status;
    return GestureDetector(
      onTap: () => setState(() => _selectedStatus = status),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.brandGreen900 : AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.brandGreen900 : AppColors.borderSoft,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.montserrat(
            color: selected ? AppColors.surfaceWhite : AppColors.mutedText,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
