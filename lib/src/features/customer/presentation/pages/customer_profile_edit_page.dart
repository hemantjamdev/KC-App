import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import 'package:kc_app/src/features/auth/presentation/controllers/customer_auth_controller.dart';

/// Edit Customer Profile Page for KC-App — allows editing display name and phone number.
class CustomerProfileEditPage extends StatefulWidget {
  const CustomerProfileEditPage({super.key});

  @override
  State<CustomerProfileEditPage> createState() =>
      _CustomerProfileEditPageState();
}

class _CustomerProfileEditPageState extends State<CustomerProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _phoneController = TextEditingController();

  late final CustomerAuthController _authController;
  bool _isSaving = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _authController = CustomerAuthController();
    _authController.addListener(_onUpdate);

    final customer = _authController.currentCustomer;
    final user = _authController.currentFirebaseUser;

    _displayNameController.text =
        customer?.displayName ?? user?.displayName ?? '';
    _phoneController.text = customer?.phone ?? user?.phoneNumber ?? '';

    _displayNameController.addListener(_markDirty);
    _phoneController.addListener(_markDirty);
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  void _markDirty() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _phoneController.dispose();
    _authController.removeListener(_onUpdate);
    _authController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
        title: const Text(
          'Discard Changes?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Unsaved profile changes will be lost.',
          style: TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Keep Editing',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Discard',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  Future<void> _save() async {
    if (_isSaving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);

    final success = await _authController.updateProfile(
      displayName: _displayNameController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated.'),
          backgroundColor: AppColors.surfaceLight,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_authController.authError ?? 'Could not save profile.'),
          backgroundColor: AppColors.surfaceLight,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final customer = _authController.currentCustomer;
    final user = _authController.currentFirebaseUser;
    final email = customer?.email ?? user?.email ?? 'No email provided';

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final router = GoRouter.of(context);
        final canLeave = await _onWillPop();
        if (canLeave) router.pop();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'Edit Profile',
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
            onPressed: () async {
              final router = GoRouter.of(context);
              final canLeave = await _onWillPop();
              if (canLeave) router.pop();
            },
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Read-only Email Field
                      _field(
                        'Email Address (Read-only)',
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: AppRadius.borderMd,
                            border: Border.all(color: AppColors.surfaceBorder),
                          ),
                          child: Text(
                            email,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Display Name Input
                      _field(
                        'Display Name *',
                        TextFormField(
                          controller: _displayNameController,
                          style: _fieldStyle,
                          cursorColor: AppColors.primary,
                          decoration: _dec('Enter your name'),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Display name is required.';
                            }
                            if (v.trim().length < 2) {
                              return 'Name must be at least 2 characters.';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Phone Input
                      _field(
                        'Phone Number (Optional)',
                        TextFormField(
                          controller: _phoneController,
                          style: _fieldStyle,
                          cursorColor: AppColors.primary,
                          keyboardType: TextInputType.phone,
                          decoration: _dec('e.g. +91 9876543210'),
                          validator: (v) {
                            if (v != null && v.trim().isNotEmpty) {
                              if (v.trim().length < 7) {
                                return 'Please enter a valid phone number.';
                              }
                            }
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      _isSaving
                          ? const Center(child: AppLoadingIndicator(size: 36))
                          : AppButton(text: 'Save Changes', onPressed: _save),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(String label, Widget child) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: AppSpacing.xs),
      child,
    ],
  );

  static const TextStyle _fieldStyle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 14,
  );

  InputDecoration _dec(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.md,
    ),
    border: const OutlineInputBorder(
      borderRadius: AppRadius.borderMd,
      borderSide: BorderSide(color: AppColors.surfaceBorder),
    ),
    enabledBorder: const OutlineInputBorder(
      borderRadius: AppRadius.borderMd,
      borderSide: BorderSide(color: AppColors.surfaceBorder),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: AppRadius.borderMd,
      borderSide: BorderSide(color: AppColors.primary, width: 1.5),
    ),
    errorBorder: const OutlineInputBorder(
      borderRadius: AppRadius.borderMd,
      borderSide: BorderSide(color: AppColors.error),
    ),
    focusedErrorBorder: const OutlineInputBorder(
      borderRadius: AppRadius.borderMd,
      borderSide: BorderSide(color: AppColors.error, width: 1.5),
    ),
    errorStyle: const TextStyle(color: AppColors.error, fontSize: 12),
  );
}
