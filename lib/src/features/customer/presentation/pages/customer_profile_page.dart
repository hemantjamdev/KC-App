import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../auth/application/providers/auth_providers.dart';
import '../../../boutique/application/providers/boutique_providers.dart';
import '../../../boutique/presentation/widgets/store_info_card.dart';
import '../../../stitching/application/providers/stitching_providers.dart';
import '../../application/providers/customer_providers.dart';
import '../../domain/models/customer_model.dart';
import '../widgets/active_stitching_preview_card.dart';
import '../widgets/profile_header_avatar.dart';
import '../widgets/profile_info_form.dart';
import '../widgets/profile_notification_toggle_tile.dart';
import '../widgets/profile_sign_out_button.dart';

/// Kapada Creation Customer Profile Page.
/// Bound strictly to authentic Firestore CustomerModel data.
class CustomerProfilePage extends ConsumerStatefulWidget {
  const CustomerProfilePage({super.key});

  @override
  ConsumerState<CustomerProfilePage> createState() =>
      _CustomerProfilePageState();
}

class _CustomerProfilePageState extends ConsumerState<CustomerProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  bool _isSaving = false;
  bool _isInitializedFromProfile = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _syncProfileData(CustomerModel? profile, dynamic user) {
    if (_isInitializedFromProfile) return;

    if (profile != null || user != null) {
      final name = profile?.displayName ?? user?.displayName ?? '';
      final email = profile?.email ?? user?.email ?? '';
      final phone = profile?.phone ?? user?.phoneNumber ?? '';

      _nameController.text = name;
      _emailController.text = email;
      _phoneController.text = phone;

      _isInitializedFromProfile = true;
    }
  }

  Future<void> _saveProfileChanges(CustomerModel? profile, String uid) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final updatedName = _nameController.text.trim();
      final updatedPhone = _phoneController.text.trim();

      final repo = ref.read(customerRepositoryProvider);

      final modelToSave = (profile ??
              CustomerModel(
                id: uid,
                firebaseUid: uid,
                displayName: updatedName,
                email: _emailController.text,
                phone: updatedPhone,
                boutiqueIds: const [],
                branchIds: const [],
                source: CustomerSource.google,
                isActive: true,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ))
          .copyWith(
        displayName: updatedName,
        phone: updatedPhone,
        updatedAt: DateTime.now(),
        updatedBy: uid,
      );

      await repo.updateCustomer(modelToSave);

      if (mounted) {
        AppToast.show(
          context,
          'Profile changes saved successfully',
          type: ToastType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(
          context,
          'Could not save changes: $e',
          type: ToastType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
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

    _syncProfileData(customerProfile, user);

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
            // ── 1. Top App Bar Header ────────────────────────────
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
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'Kapada Creation Studio & Account',
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── 2. Profile Avatar Section Widget ────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ProfileHeaderAvatar(
                  displayName: displayName,
                  photoUrl: photoUrl,
                  isAuthenticated: isAuthenticated,
                  onEditPressed: () =>
                      context.push(AppRoutes.customerProfileEdit),
                ),
              ),
            ),

            // ── 3. Personal Information Form Widget ─────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ProfileInfoForm(
                  formKey: _formKey,
                  nameController: _nameController,
                  emailController: _emailController,
                  phoneController: _phoneController,
                  isAuthenticated: isAuthenticated,
                  isSaving: _isSaving,
                  onSavePressed: () =>
                      _saveProfileChanges(customerProfile, user!.uid),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── 4. Push Notification Toggle Tile Widget ─────────
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: ProfileNotificationToggleTile(),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── 4. Active Stitching Order Widget ─────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ActiveStitchingPreviewCard(activeOrder: activeOrder),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── 5. Studio Details Card Widget ───────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: StoreInfoCard(boutique: boutique),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── 6. App Version & Sign Out Footer ─────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    if (isAuthenticated) ...[
                      const ProfileSignOutButton(),
                      const SizedBox(height: 16),
                    ],

                    FutureBuilder<PackageInfo>(
                      future: PackageInfo.fromPlatform(),
                      builder: (context, snapshot) {
                        final version = snapshot.hasData
                            ? 'v${snapshot.data!.version} (${snapshot.data!.buildNumber})'
                            : 'v2.4.1 (Stable)';
                        return Text(
                          'Version  •  $version',
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            color: AppColors.textMuted,
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

            const SliverToBoxAdapter(child: SizedBox(height: 36)),
          ],
        ),
      ),
    );
  }
}
