import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../auth/application/providers/auth_providers.dart';
import '../../../auth/presentation/widgets/google_auth_bottom_sheet.dart';
import '../../../boutique/application/providers/boutique_providers.dart';
import '../../../boutique/presentation/widgets/store_info_card.dart';
import '../../../stitching/application/providers/stitching_providers.dart';
import '../../../stitching/domain/models/stitching_order_model.dart';
import '../../application/providers/customer_providers.dart';
import '../../domain/models/customer_model.dart';

/// Kapada Creation Customer Profile Page — High-Fashion Redesign.
class CustomerProfilePage extends ConsumerStatefulWidget {
  const CustomerProfilePage({super.key});

  @override
  ConsumerState<CustomerProfilePage> createState() => _CustomerProfilePageState();
}

class _CustomerProfilePageState extends ConsumerState<CustomerProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;

  bool _isSaving = false;
  bool _isInitializedFromProfile = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Priya Sharma');
    _emailController = TextEditingController(text: 'priya.sharma@example.com');
    _phoneController = TextEditingController(text: '+91 98765 43210');
    _locationController = TextEditingController(text: 'Mumbai, Maharashtra');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _syncProfileData(CustomerModel? profile, dynamic user) {
    if (_isInitializedFromProfile) return;

    if (profile != null || user != null) {
      final name = profile?.displayName ?? user?.displayName ?? 'Priya Sharma';
      final email = profile?.email ?? user?.email ?? 'priya.sharma@example.com';
      final phone = profile?.phone ?? user?.phoneNumber ?? '+91 98765 43210';
      final location = 'Mumbai, Maharashtra';

      _nameController.text = name.isNotEmpty ? name : 'Priya Sharma';
      _emailController.text = email.isNotEmpty ? email : 'priya.sharma@example.com';
      _phoneController.text = phone.isNotEmpty ? phone : '+91 98765 43210';
      _locationController.text = location;

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
            : 'Priya Sharma');
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
            // ── 1. Top App Bar (Intact Header) ───────────────────
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

            // ── 2. Profile Avatar & Header Section ──────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    // Avatar Image with Edit Badge
                    Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.surfaceWhite,
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 58,
                            backgroundColor: AppColors.brandGreen100,
                            backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                                ? NetworkImage(photoUrl)
                                : const NetworkImage(
                                    'https://lh3.googleusercontent.com/aida-public/AB6AXuCIJvw8iRs2JRbZLndlu06YG6XImBqKw0HsTR_Tzfd5K7AAJbE_IZeh1dVOTKv55uz6bk7I2oyXCGJgw9s87Xk7j-1Q_wGkTKIL0Cq63LkvuT4WZbQfn5JuN5Kuk2zdvPN4q_8wFk8Z9C6olM_Qdl0O-B1d5_ISd7PdUm_NiQ0bZgrzu6xfXhGJxUtcVvC9bJkx0Z85HTnwgCrTC6Ya90JwO0RjGSQyZwpIqIe63P6PFNn502RUaN45R_noII4CEp1Q1H925CQTr2Kk',
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: GestureDetector(
                            onTap: () {
                              if (isAuthenticated) {
                                context.push(AppRoutes.customerProfileEdit);
                              } else {
                                GoogleAuthBottomSheet.show(context);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.edit_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Full Name
                    Text(
                      displayName,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),

                    // Subtitle / Membership
                    Text(
                      'Premium Member • Since 2022',
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),

                    // Interest Tag Chips
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildTagChip('Pure Silk Enthusiast'),
                        const SizedBox(width: 8),
                        _buildTagChip('Bespoke Fitting'),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── 3. Personal Information Card ─────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderSoft),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.person_outline_rounded,
                              size: 22,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Personal Information',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Full Name
                        _buildProfileField(
                          label: 'FULL NAME',
                          controller: _nameController,
                          enabled: isAuthenticated,
                        ),
                        const SizedBox(height: 18),

                        // Email Address (Readonly)
                        _buildProfileField(
                          label: 'EMAIL ADDRESS',
                          controller: _emailController,
                          enabled: false,
                        ),
                        const SizedBox(height: 18),

                        // Phone Number
                        _buildProfileField(
                          label: 'PHONE NUMBER',
                          controller: _phoneController,
                          enabled: isAuthenticated,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 18),

                        // Default Location
                        _buildProfileField(
                          label: 'DEFAULT LOCATION',
                          controller: _locationController,
                          enabled: isAuthenticated,
                        ),
                        const SizedBox(height: 24),

                        // Save Button
                        Align(
                          alignment: Alignment.centerRight,
                          child: SizedBox(
                            height: 44,
                            child: ElevatedButton(
                              onPressed: () {
                                if (!isAuthenticated) {
                                  GoogleAuthBottomSheet.show(context);
                                } else {
                                  _saveProfileChanges(customerProfile, user!.uid);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: _isSaving
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Save Profile Changes',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.surfaceWhite,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── 4. Active Stitching Shortcut Card ────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 16,
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
                              const Icon(
                                Icons.architecture_rounded,
                                size: 22,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Active Stitching',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => context.push(
                              AppRoutes.customerStitchingList,
                            ),
                            child: Text(
                              'View All History',
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                fontStyle: FontStyle.italic,
                                color: AppColors.primary,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.primary.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      if (activeOrder != null) ...[
                        _buildActiveOrderCard(context, activeOrder)
                      ] else ...[
                        // Sample / Demo Active Stitching Showcase
                        _buildSampleActiveOrderCard(context),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── 5. Studio Details Card (Same as Admin) ────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: StoreInfoCard(boutique: boutique),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── 6. App Version & Sign Out Footer ─────────────
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
                            'Logout Account',
                            style: GoogleFonts.montserrat(
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.error),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
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

  Widget _buildTagChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.brandGreen50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildProfileField({
    required String label,
    required TextEditingController controller,
    required bool enabled,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.textMuted,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: enabled ? AppColors.charcoal : AppColors.textMuted,
          ),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.borderSoft, width: 1.5),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            disabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.borderSoft.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveOrderCard(
    BuildContext context,
    StitchingOrderModel order,
  ) {
    final title = order.displayRequestName;
    final statusText = order.status.customerLabel;
    final orderNum = order.orderNumber;
    final expectedDate = order.expectedReadyAt != null
        ? DateFormat('MMM d, yyyy').format(order.expectedReadyAt!)
        : 'Oct 12, 2023';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image Thumbnail
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 90,
            height: 110,
            color: AppColors.brandGreen50,
            child: Image.network(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuByajukfefW6OmoK8iW5Dsx8tOTyxIjJNVz2zom7JKQ9E4g3EzYK70BlIF6tGsrrV57E4greJ0wAPylvEk6tPZPWAKLEEngNUGeectPWEkm7CNr5lLPjnH6DBGY9BIktWaQv3CqHTG-ulhYaT-zshxjK3iU6-LLryIm61zmRTKMfHvrocNLD_GRO4IXmomMgChrCrHCL-TXwGDf_TUYl9y9Poc1S1UTCPPwr2VoTsAecbadE9CaawAjdZsjPeRKv9Wl6qus14QJoRMA',
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) => const Icon(
                Icons.design_services_rounded,
                color: AppColors.primary,
                size: 32,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),

        // Order Information
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.brandGreen50,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      'IN PROGRESS',
                      style: GoogleFonts.montserrat(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '#$orderNum',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              Text(
                title,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 2),

              Text(
                'Delivery expected by $expectedDate',
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 10),

              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: order.status.progressFraction,
                  minHeight: 6,
                  backgroundColor: AppColors.brandGreen50,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),

              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Tailoring Stage: $statusText',
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSampleActiveOrderCard(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 90,
            height: 110,
            color: AppColors.brandGreen50,
            child: Image.network(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuByajukfefW6OmoK8iW5Dsx8tOTyxIjJNVz2zom7JKQ9E4g3EzYK70BlIF6tGsrrV57E4greJ0wAPylvEk6tPZPWAKLEEngNUGeectPWEkm7CNr5lLPjnH6DBGY9BIktWaQv3CqHTG-ulhYaT-zshxjK3iU6-LLryIm61zmRTKMfHvrocNLD_GRO4IXmomMgChrCrHCL-TXwGDf_TUYl9y9Poc1S1UTCPPwr2VoTsAecbadE9CaawAjdZsjPeRKv9Wl6qus14QJoRMA',
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) => const Icon(
                Icons.design_services_rounded,
                color: AppColors.primary,
                size: 32,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.brandGreen50,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      'IN PROGRESS',
                      style: GoogleFonts.montserrat(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '#ST-9942',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Emerald Velvet Anarkali',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Delivery expected by Oct 12, 2023',
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: const LinearProgressIndicator(
                  value: 0.65,
                  minHeight: 6,
                  backgroundColor: AppColors.brandGreen50,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Tailoring Stage: Final Finishing',
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
