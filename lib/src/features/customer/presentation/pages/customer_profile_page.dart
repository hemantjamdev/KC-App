import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/stitch_divider.dart';
import '../../../auth/application/providers/auth_providers.dart';
import '../../../boutique/application/providers/boutique_providers.dart';
import '../../../boutique/presentation/widgets/store_info_card.dart';
import '../../../notification/application/providers/notification_providers.dart';
import '../../../stitching/application/providers/stitching_providers.dart';
import '../../application/providers/customer_providers.dart';
import '../widgets/active_stitching_preview_card.dart';
import '../widgets/customer_profile_edit_sheet.dart';
import '../widgets/profile_header_avatar.dart';

/// Ultra-Luxury Kapada Creation Customer Profile Page.
/// Styled matching executive stitched ivory menu cards:
/// - Stitched Ivory Menu Item Cards with clean rounded icon container box & Playfair serif typography.
/// - Active Stitching Card integrated in My Stitching section.
/// - Stitched Push Notification Toggle Switch for instant notification settings.
/// - Tab redirects for Favorites & My Stitching.
/// - Dynamic Kapada Creation Store Info card permanently displayed.
class CustomerProfilePage extends ConsumerStatefulWidget {
  const CustomerProfilePage({super.key});

  @override
  ConsumerState<CustomerProfilePage> createState() => _CustomerProfilePageState();
}

class _CustomerProfilePageState extends ConsumerState<CustomerProfilePage> {
  Future<void> _handleSignOut(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFAF6EF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Sign Out',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF162D20),
          ),
        ),
        content: Text(
          'Are you sure you want to sign out from your Kapada Creation account?',
          style: GoogleFonts.montserrat(
            fontSize: 13,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.montserrat(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF162D20),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(customerSessionProvider.notifier).signOut();
      if (context.mounted) {
        AppToast.show(
          context,
          'Successfully signed out',
          type: ToastType.info,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentCustomerUserProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final customerProfile = ref.watch(customerProfileProvider).valueOrNull;
    final boutique = ref.watch(selectedBoutiqueProvider) ??
        ref.watch(autoSelectedBoutiqueProvider);

    final displayName = customerProfile?.displayName ??
        (user?.displayName != null && user!.displayName!.isNotEmpty
            ? user.displayName!
            : (isAuthenticated ? 'Valued Customer' : 'Studio Guest'));
    final photoUrl = customerProfile?.photoUrl ?? user?.photoURL;

    final customerOrdersAsync = user != null
        ? ref.watch(customerOrderListProvider(user.uid))
        : null;
    final customerOrders = customerOrdersAsync?.valueOrNull ?? [];
    final activeOrder = customerOrders.isNotEmpty ? customerOrders.first : null;

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── 1. Top Title Header ────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 20, 12, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF162D20),
                      ),
                    ),
                    Text(
                      'Kapada Creation Studio & Account',
                      style: GoogleFonts.montserrat(
                        fontSize: 12.5,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── 2. Profile Avatar Header Card ────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ProfileHeaderAvatar(
                  displayName: displayName,
                  photoUrl: photoUrl,
                  phone: customerProfile?.phone ?? user?.phoneNumber,
                  email: customerProfile?.email ?? user?.email,
                  createdAt: customerProfile?.createdAt,
                  isAuthenticated: isAuthenticated,
                  onEditPressed: () =>
                      CustomerProfileEditSheet.show(context),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // ── 3. Executive Stitched Menu Items Stack ─────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    // Item 1: My Stitching
                    _ProfileStitchedMenuItem(
                      icon: PhosphorIcons.dress(PhosphorIconsStyle.fill),
                      title: 'My Stitching',
                      subtitle: 'View your orders & measurements',
                      onTap: () => context.go(AppRoutes.customerStitchingList),
                    ),

                    // Active Stitching Order Card (Integrated enlarged details card)
                    if (activeOrder != null) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: ActiveStitchingPreviewCard(activeOrder: activeOrder),
                      ),
                    ],

                    // Item 2: Favorites
                    _ProfileStitchedMenuItem(
                      icon: PhosphorIcons.heart(PhosphorIconsStyle.fill),
                      title: 'Favorites',
                      subtitle: 'Your saved designs & outfits',
                      onTap: () => context.go(AppRoutes.customerFavorites),
                    ),

                    // Item 3: Notifications (with Stitched Push Notification Toggle)
                    _ProfileStitchedMenuItem(
                      icon: PhosphorIcons.bellSimple(PhosphorIconsStyle.fill),
                      title: 'Notifications',
                      subtitle: 'Updates & offers from Kapada Creation',
                      trailing: const _StitchedNotificationToggleSwitch(),
                    ),

                    // Item 4: App Info
                    _ProfileStitchedMenuItem(
                      icon: PhosphorIcons.info(PhosphorIconsStyle.fill),
                      title: 'App Info',
                      subtitle: 'Version, policies & support',
                      onTap: () => _showAppInfoDialog(context),
                    ),

                    // Item 5: Logout (only when authenticated)
                    if (isAuthenticated)
                      _ProfileStitchedMenuItem(
                        icon: PhosphorIcons.signOut(PhosphorIconsStyle.fill),
                        title: 'Logout',
                        subtitle: 'Sign out from your account',
                        onTap: () => _handleSignOut(context),
                      ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // ── 4. Executive Store Details Leather Card (Permanent Section) ────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: StoreInfoCard(boutique: boutique),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── 5. App Version Footer ─────────────────
            SliverToBoxAdapter(
              child: FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) {
                  final version = snapshot.hasData
                      ? 'v${snapshot.data!.version} (${snapshot.data!.buildNumber})'
                      : 'v2.4.1 (Stable)';
                  return Text(
                    'Kapada Creation Studio  •  $version',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  );
                },
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 36)),
          ],
        ),
      ),
    );
  }

  void _showAppInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFAF6EF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: Color(0xFF162D20)),
            const SizedBox(width: 10),
            Text(
              'App Info',
              style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF162D20),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kapada Creation — Executive Customer Portal',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: const Color(0xFF162D20),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Designer women\'s stitching & boutique clothing app.\nVersion: 2.4.1 (Stable)\nAll rights reserved © Kapada Creation.',
              style: GoogleFonts.montserrat(
                fontSize: 12,
                height: 1.4,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Close',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF162D20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Executive Luxury Stitched Ivory Menu Item Card Widget
class _ProfileStitchedMenuItem extends StatelessWidget {
  const _ProfileStitchedMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF6EF), // Soft luxury ivory cloth
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: const Color(0xFFDCD2C0).withValues(alpha: 0.5),
            blurRadius: 1.5,
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: CustomPaint(
          painter: _LinenClothTexturePainter(),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(18),
              child: DashedStitchContainer(
                backgroundColor: Colors.transparent, // Uses woven cloth background
                borderColor: const Color(0xFFE2D8C8),
                borderRadius: 18,
                inset: 3.5,
                dashWidth: 6.0,
                dashGap: 3.5,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    // 1. Left Clean Rounded Icon Container Box (NO stitching border on icon)
                    _ProfileIconBox(icon: icon),

                    const SizedBox(width: 14),

                    // 2. Title & Subtitle Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1D2420),
                              letterSpacing: 0.1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: GoogleFonts.montserrat(
                              fontSize: 11.5,
                              color: const Color(0xFF6F7973),
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    // 3. Trailing Element (Chevron or Stitched Toggle)
                    trailing ??
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                          color: Color(0xFF1D2420),
                        ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Clean Left Rounded Icon Container Box (No Stitching Border on Icon)
class _ProfileIconBox extends StatelessWidget {
  const _ProfileIconBox({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFF3ECE0), // Soft ivory tone
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFDFD6C7),
          width: 1.0,
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          size: 23,
          color: const Color(0xFF162D20), // Deep boutique green
        ),
      ),
    );
  }
}

/// Custom Stitched Push Notification Toggle Switch
class _StitchedNotificationToggleSwitch extends ConsumerStatefulWidget {
  const _StitchedNotificationToggleSwitch();

  @override
  ConsumerState<_StitchedNotificationToggleSwitch> createState() =>
      __StitchedNotificationToggleSwitchState();
}

class __StitchedNotificationToggleSwitchState
    extends ConsumerState<_StitchedNotificationToggleSwitch> {
  bool _isToggling = false;

  Future<void> _toggleNotifications(bool value) async {
    if (_isToggling) return;
    setState(() => _isToggling = true);

    try {
      final user = ref.read(currentCustomerUserProvider);
      final profile = ref.read(customerProfileProvider).valueOrNull;

      if (value) {
        await ref
            .read(notificationPermissionProvider.notifier)
            .requestPermission(customerUid: user?.uid);

        if (profile != null) {
          final updated = profile.copyWith(
            notificationsEnabled: true,
            updatedAt: DateTime.now(),
          );
          await ref.read(customerRepositoryProvider).updateCustomer(updated);
        }
      } else {
        if (profile != null) {
          final updated = profile.copyWith(
            notificationsEnabled: false,
            updatedAt: DateTime.now(),
          );
          await ref.read(customerRepositoryProvider).updateCustomer(updated);
        }
      }

      ref.invalidate(customerProfileProvider);
    } catch (_) {
      // Ignore
    } finally {
      if (mounted) {
        setState(() => _isToggling = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final profile = ref.watch(customerProfileProvider).valueOrNull;
    final isEnabled =
        isAuthenticated ? (profile?.notificationsEnabled ?? true) : false;

    return GestureDetector(
      onTap: _isToggling ? null : () => _toggleNotifications(!isEnabled),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeInOut,
        width: 50,
        height: 28,
        padding: const EdgeInsets.all(2.5),
        decoration: BoxDecoration(
          color: isEnabled ? const Color(0xFF162D20) : const Color(0xFFE4DDD0),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isEnabled
                ? const Color(0xFFC5A880)
                : const Color(0xFFC5BBAA),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeInOut,
          alignment: isEnabled ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 21,
            height: 21,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFAF6EF),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
              border: Border.all(
                color: isEnabled
                    ? const Color(0xFFC5A880)
                    : const Color(0xFFB0A595),
                width: 1.0,
              ),
            ),
            child: _isToggling
                ? const Padding(
                    padding: EdgeInsets.all(3),
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF162D20),
                      ),
                    ),
                  )
                : Icon(
                    isEnabled ? Icons.check_rounded : Icons.close_rounded,
                    size: 11,
                    color: const Color(0xFF162D20),
                  ),
          ),
        ),
      ),
    );
  }
}

/// CustomPainter generating natural woven linen / cotton fabric texture.
class _LinenClothTexturePainter extends CustomPainter {
  _LinenClothTexturePainter();

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Horizontal linen weave micro-threads
    final horizDarkPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.025)
      ..strokeWidth = 0.8;

    final horizLightPaint = Paint()
      ..color = const Color(0xFFFFFDF8).withValues(alpha: 0.4)
      ..strokeWidth = 0.8;

    const stepY = 4.5;
    for (double y = 0; y < size.height; y += stepY) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), horizDarkPaint);
      canvas.drawLine(Offset(0, y + 0.5), Offset(size.width, y + 0.5), horizLightPaint);
    }

    // 2. Vertical linen weave micro-threads
    final vertDarkPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.02)
      ..strokeWidth = 0.8;

    final vertLightPaint = Paint()
      ..color = const Color(0xFFFFFDF8).withValues(alpha: 0.35)
      ..strokeWidth = 0.8;

    const stepX = 4.5;
    for (double x = 0; x < size.width; x += stepX) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), vertDarkPaint);
      canvas.drawLine(Offset(x + 0.5, 0), Offset(x + 0.5, size.height), vertLightPaint);
    }

    // 3. Organic fabric slub / cotton fiber texture dots
    final fiberPaint = Paint()
      ..color = const Color(0xFFC8BEAD).withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    for (double x = 4; x < size.width; x += 12) {
      for (double y = 4; y < size.height; y += 12) {
        final seed = (x * 23 + y * 41).toInt();
        if (seed % 3 == 0) {
          final offsetX = (seed % 5) - 2.5;
          final offsetY = ((seed * 11) % 5) - 2.5;
          canvas.drawCircle(Offset(x + offsetX, y + offsetY), 0.7, fiberPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
