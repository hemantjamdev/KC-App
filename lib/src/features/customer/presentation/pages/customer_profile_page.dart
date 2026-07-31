import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/application/providers/auth_providers.dart';
import '../../../auth/presentation/widgets/google_auth_bottom_sheet.dart';
import '../../../boutique/application/providers/boutique_providers.dart';
import '../../../boutique/presentation/widgets/store_info_card.dart';

/// Customer Profile Tab Page.
/// Displays guest overview & login CTA when unauthenticated,
/// or full customer profile details, studio location info, app version, and sign out when authenticated.
class CustomerProfilePage extends ConsumerWidget {
  const CustomerProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentCustomerUserProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final customerProfile = ref.watch(customerProfileProvider).valueOrNull;
    final boutique =
        ref.watch(selectedBoutiqueProvider) ??
        ref.watch(autoSelectedBoutiqueProvider);

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
      backgroundColor: AppColors.warmIvory,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: AppColors.charcoal,
                      ),
                    ),
                    Text(
                      'Kapada Creation Studio & Account',
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

            // ── Guest Card OR Logged-in Profile Card ──────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: !isAuthenticated
                    ? _GuestProfileCard()
                    : _LoggedInProfileCard(
                        displayName: displayName,
                        email: email,
                        phone: phone,
                        photoUrl: photoUrl,
                        onEdit: () =>
                            context.push(AppRoutes.customerProfileEdit),
                      ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // ── Studio Information Card ────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: StoreInfoCard(boutique: boutique),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── Sign Out & Clean Version Footer ───────────────
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
                                title: Text(
                                  'Sign Out',
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                content: Text(
                                  'Are you sure you want to sign out of Kapada Creation?',
                                  style: GoogleFonts.montserrat(fontSize: 13),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.error,
                                    ),
                                    child: const Text('Sign Out'),
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
                          icon: const Icon(
                            Icons.logout_rounded,
                            color: AppColors.error,
                            size: 18,
                          ),
                          label: Text(
                            'Sign Out',
                            style: GoogleFonts.montserrat(
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.error),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Clean App Version Footer text
                    FutureBuilder<PackageInfo>(
                      future: PackageInfo.fromPlatform(),
                      builder: (context, snapshot) {
                        final version = snapshot.hasData
                            ? 'v${snapshot.data!.version} (${snapshot.data!.buildNumber})'
                            : 'v1.0.0';
                        return Text(
                          'Kapada Creation App  •  $version',
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            color: AppColors.mutedText,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
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

class _GuestProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.brandGreen50,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_circle_outlined,
              size: 36,
              color: AppColors.brandGreen800,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Welcome to Kapada Creation',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.charcoal,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Sign in with Google to bookmark styles, request tailoring, and receive order updates.',
            style: GoogleFonts.montserrat(
              fontSize: 12,
              color: AppColors.mutedText,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: () => GoogleAuthBottomSheet.show(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandGreen900,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Continue with Google',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.surfaceWhite,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoggedInProfileCard extends StatelessWidget {
  const _LoggedInProfileCard({
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.brandGreen100,
            backgroundImage: photoUrl != null && photoUrl!.isNotEmpty
                ? NetworkImage(photoUrl!)
                : null,
            child: photoUrl == null || photoUrl!.isEmpty
                ? Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : 'C',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brandGreen900,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.charcoal,
                  ),
                ),
                Text(
                  email,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: AppColors.mutedText,
                  ),
                ),
                if (phone.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    phone,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: AppColors.mutedText,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              color: AppColors.brandGreen800,
              size: 20,
            ),
            onPressed: onEdit,
            tooltip: 'Edit Profile',
          ),
        ],
      ),
    );
  }
}


