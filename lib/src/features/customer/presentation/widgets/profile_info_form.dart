import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/widgets/google_auth_bottom_sheet.dart';

/// Modular Profile Personal Information Form widget.
class ProfileInfoForm extends StatelessWidget {
  const ProfileInfoForm({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.isAuthenticated,
    required this.isSaving,
    required this.onSavePressed,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final bool isAuthenticated;
  final bool isSaving;
  final VoidCallback onSavePressed;

  @override
  Widget build(BuildContext context) {
    return Container(
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
        key: formKey,
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

            _buildProfileField(
              label: 'FULL NAME',
              controller: nameController,
              enabled: isAuthenticated,
            ),
            const SizedBox(height: 18),

            _buildProfileField(
              label: 'EMAIL ADDRESS',
              controller: emailController,
              enabled: false,
            ),
            const SizedBox(height: 18),

            _buildProfileField(
              label: 'PHONE NUMBER',
              controller: phoneController,
              enabled: isAuthenticated,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),

            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    if (!isAuthenticated) {
                      GoogleAuthBottomSheet.show(context);
                    } else {
                      onSavePressed();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isSaving
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
}
