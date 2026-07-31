import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../auth/application/providers/auth_providers.dart';
import '../../application/providers/customer_providers.dart';
import '../../domain/models/customer_model.dart';

/// Edit Customer Profile Page for KC-App.
/// Allows updating customer display name and contact phone number. Read-only email.
class CustomerProfileEditPage extends ConsumerStatefulWidget {
  const CustomerProfileEditPage({super.key});

  @override
  ConsumerState<CustomerProfileEditPage> createState() =>
      _CustomerProfileEditPageState();
}

class _CustomerProfileEditPageState
    extends ConsumerState<CustomerProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();

  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final customer = ref.read(customerProfileProvider).valueOrNull;
    final user = ref.read(currentCustomerUserProvider);

    _nameController.text =
        customer?.name ?? user?.displayName ?? 'Valued Customer';
    _phoneController.text = customer?.phone ?? user?.phoneNumber ?? '';

    _nameController.addListener(_markDirty);
    _phoneController.addListener(_markDirty);
  }

  void _markDirty() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _phoneFocusNode.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final customer = ref.read(customerProfileProvider).valueOrNull;
    final user = ref.read(currentCustomerUserProvider);

    if (user == null) return;

    final now = DateTime.now();
    final updated =
        (customer ??
                CustomerModel(
                  id: user.uid,
                  displayName: '',
                  email: user.email ?? '',
                  phone: '',
                  boutiqueIds: const ['default'],
                  branchIds: const [],
                  source: CustomerSource.google,
                  isActive: true,
                  createdAt: now,
                  updatedAt: now,
                ))
            .copyWith(
              displayName: _nameController.text.trim(),
              phone: _phoneController.text.trim(),
              updatedAt: now,
            );

    await ref.read(customerMutationProvider.notifier).update(updated);

    if (!mounted) return;
    AppToast.show(
      context,
      'Profile updated successfully.',
      type: ToastType.success,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentCustomerUserProvider);

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      appBar: AppBar(
        backgroundColor: AppColors.brandGreen900,
        foregroundColor: AppColors.surfaceWhite,
        title: Text(
          'Edit Customer Profile',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.surfaceWhite,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Read-only Email Field
                    Text(
                      'GOOGLE EMAIL (READ-ONLY)',
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.mutedText,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.softCream,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderSoft),
                      ),
                      child: Text(
                        user?.email ?? 'No email address',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: AppColors.mutedText,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Display Name
                    TextFormField(
                      controller: _nameController,
                      focusNode: _nameFocusNode,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_phoneFocusNode),
                      style: GoogleFonts.montserrat(fontSize: 14),
                      decoration: const InputDecoration(
                        labelText: 'Customer Name *',
                        hintText: 'e.g. Priya Sharma',
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Name is required.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Phone Number
                    TextFormField(
                      controller: _phoneController,
                      focusNode: _phoneFocusNode,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                      style: GoogleFonts.montserrat(fontSize: 14),
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Contact Phone Number',
                        hintText: 'e.g. +91 98765 43210',
                      ),
                    ),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ref.watch(customerMutationProvider).isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.brandGreen800,
                                strokeWidth: 2,
                              ),
                            )
                          : ElevatedButton(
                              onPressed: _save,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.brandGreen900,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Save Profile Changes',
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.surfaceWhite,
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
      ),
    );
  }
}
