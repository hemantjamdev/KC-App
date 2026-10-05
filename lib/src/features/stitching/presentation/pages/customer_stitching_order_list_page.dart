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
import '../widgets/stitching_order_card.dart';
import '../widgets/stitching_request_bottom_sheet.dart';

/// Customer "My Stitching" Tab Page.
/// Protected action: Requires Google Auth.
/// Displays customer's real stitching requests streamed from Firestore `stitchingOrders` collection.
class CustomerStitchingOrderListPage extends ConsumerWidget {
  const CustomerStitchingOrderListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    final orders = customerOrdersAsync.valueOrNull ?? [];
    final isLoading = customerOrdersAsync.isLoading;

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
              // ── Header ─────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
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

              if (isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.brandGreen800,
                      strokeWidth: 2,
                    ),
                  ),
                )
              else if (orders.isEmpty)
                const SliverFillRemaining(
                  child: AppEmptyState(
                    icon: Icons.design_services_outlined,
                    title: 'No stitching requests yet',
                    message:
                        'Tap + New Request below to submit a custom tailoring or alteration request.',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, idx) => StitchingOrderCard(order: orders[idx]),
                      childCount: orders.length,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }
}
