import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../app/app_routes.dart';
import '../../../auth/application/providers/auth_providers.dart';
import '../../../auth/presentation/widgets/google_auth_bottom_sheet.dart';
import '../../../boutique/application/providers/boutique_providers.dart';
import '../../../boutique/presentation/widgets/store_info_card.dart';
import '../../../design/application/providers/favorite_providers.dart';
import '../../../stitching/application/providers/stitching_providers.dart';
import '../../../stitching/domain/models/stitching_order_model.dart';

/// Kapada Creation Customer App — Ultra-Premium Luxury Profile Page.
class CustomerProfilePage extends ConsumerWidget {
  const CustomerProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentCustomerUserProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final customerProfile = ref.watch(customerProfileProvider).valueOrNull;
    final boutique = ref.watch(selectedBoutiqueProvider) ??
        ref.watch(autoSelectedBoutiqueProvider);

    final favoriteIds = ref.watch(customerFavoriteIdsProvider).valueOrNull ?? [];
    final stitchingOrders = ref.watch(customerOrderListProvider(user?.uid ?? '')).valueOrNull ?? [];
    final activeOrdersCount = stitchingOrders.where((o) => o.status != StitchingOrderStatus.completed).length;

    final cName = customerProfile?.displayName;
    final displayName = (cName != null && cName.isNotEmpty)
        ? cName
        : (user?.displayName ?? 'Valued Customer');
    final email = user?.email ?? customerProfile?.email ?? 'No email address';
    final cPhone = customerProfile?.phone;
    final phone = (cPhone != null && cPhone.isNotEmpty)
        ? cPhone
        : (user?.phoneNumber ?? 'No phone number');
    final photoUrl = customerProfile?.photoUrl ?? user?.photoURL;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── 1. Header ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Profile & Studio',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Kapada Creation Boutique & Personal Account',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: const Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── 2. Profile Card ───────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: !isAuthenticated
                    ? _GuestProfileCard()
                    : _UserProfileCard(
                        displayName: displayName,
                        email: email,
                        phone: phone,
                        photoUrl: photoUrl,
                        onEdit: () => context.push(AppRoutes.customerProfileEdit),
                      ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // ── 3. Activity Hub (Orders & Favorites) ──────────────
            if (isAuthenticated)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MY ACTIVITY & SAVED',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF888888),
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _QuickActionCard(
                              icon: PhosphorIcons.scissors(PhosphorIconsStyle.bold),
                              title: 'Stitching Orders',
                              badgeText: activeOrdersCount > 0 ? '$activeOrdersCount Active' : null,
                              badgeColor: const Color(0xFF10B981),
                              onTap: () => context.push(AppRoutes.customerStitchingList),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _QuickActionCard(
                              icon: PhosphorIcons.heart(PhosphorIconsStyle.bold),
                              title: 'Favorites',
                              badgeText: favoriteIds.isNotEmpty ? '${favoriteIds.length} Saved' : null,
                              badgeColor: const Color(0xFFC5A880),
                              onTap: () => context.push(AppRoutes.customerFavorites),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // ── 4. Studio Information Card ────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: StoreInfoCard(boutique: boutique),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── 5. Sign Out & Footer ──────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    if (isAuthenticated) ...[
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: Colors.white,
                                title: Text(
                                  'Sign Out',
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1A1A1A),
                                  ),
                                ),
                                content: Text(
                                  'Are you sure you want to sign out of Kapada Creation?',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 14,
                                    color: const Color(0xFF1A1A1A),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: Text(
                                      'Cancel',
                                      style: GoogleFonts.montserrat(
                                        color: const Color(0xFF666666),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFDC2626),
                                    ),
                                    child: Text(
                                      'Sign Out',
                                      style: GoogleFonts.montserrat(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await ref
                                  .read(googleAuthNotifierProvider.notifier)
                                  .signOut();
                              if (context.mounted) {
                                context.go(AppRoutes.customerHome);
                              }
                            }
                          },
                          icon: PhosphorIcon(
                            PhosphorIcons.signOut(PhosphorIconsStyle.bold),
                            color: const Color(0xFFDC2626),
                            size: 18,
                          ),
                          label: Text(
                            'Sign Out',
                            style: GoogleFonts.montserrat(
                              color: const Color(0xFFDC2626),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFDC2626)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    FutureBuilder<PackageInfo>(
                      future: PackageInfo.fromPlatform(),
                      builder: (context, snapshot) {
                        final version = snapshot.hasData
                            ? 'v${snapshot.data!.version} (${snapshot.data!.buildNumber})'
                            : 'v1.0.0';
                        return Column(
                          children: [
                            Text(
                              'Kapada Creation Customer App',
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF666666),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              version,
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
                                color: const Color(0xFF888888),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

class _UserProfileCard extends StatelessWidget {
  const _UserProfileCard({
    required this.displayName,
    required this.email,
    required this.phone,
    required this.photoUrl,
    required this.onEdit,
  });

  final String displayName;
  final String email;
  final String phone;
  final String? photoUrl;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFC5A880).withValues(alpha: 0.5),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF7F2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFC5A880),
                        width: 1.5,
                      ),
                      image: photoUrl != null && photoUrl!.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(photoUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: photoUrl == null || photoUrl!.isEmpty
                        ? Center(
                            child: Text(
                              displayName.isNotEmpty
                                  ? displayName[0].toUpperCase()
                                  : 'C',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1A1A1A),
                              ),
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: onEdit,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: PhosphorIcon(
                          PhosphorIcons.pencilSimple(PhosphorIconsStyle.bold),
                          color: Colors.white,
                          size: 11,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A1A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: GoogleFonts.montserrat(
                        fontSize: 12.5,
                        color: const Color(0xFF666666),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (phone != 'No phone number') ...[
                      const SizedBox(height: 2),
                      Text(
                        phone,
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: const Color(0xFFA67C52),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFEAE5DC)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.verified_rounded,
                    size: 15,
                    color: Color(0xFFC5A880),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'GOOGLE VERIFIED MEMBER',
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFA67C52),
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onEdit,
                child: Text(
                  'Edit Profile →',
                  style: GoogleFonts.montserrat(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GuestProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFC5A880).withValues(alpha: 0.5),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFFAF7F2),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFC5A880), width: 1.2),
            ),
            child: Center(
              child: PhosphorIcon(
                PhosphorIcons.user(PhosphorIconsStyle.bold),
                size: 26,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Welcome to Kapada Creation',
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Sign in to save favorite designs and request custom boutique stitching.',
            style: GoogleFonts.montserrat(
              fontSize: 12,
              color: const Color(0xFF666666),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => GoogleAuthBottomSheet.show(context),
              icon: PhosphorIcon(
                PhosphorIcons.googleLogo(PhosphorIconsStyle.bold),
                size: 18,
                color: Colors.white,
              ),
              label: Text(
                'Sign In with Google',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A1A),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    this.badgeText,
    this.badgeColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? badgeText;
  final Color? badgeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEAE5DC)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF7F2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: PhosphorIcon(
                    icon,
                    size: 20,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                if (badgeText != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: (badgeColor ?? const Color(0xFF1A1A1A)).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badgeText!,
                      style: GoogleFonts.montserrat(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: badgeColor ?? const Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.montserrat(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
