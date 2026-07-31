import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/application/providers/auth_providers.dart';
import '../../application/providers/stitching_providers.dart';
import '../../domain/models/stitching_submission_state.dart';

/// Refined bottom sheet for requesting new custom stitching service.
/// Prompts for category selection (Blouse, Suit, Lehenga, etc.) and contact number.
class StitchingRequestBottomSheet extends ConsumerStatefulWidget {
  const StitchingRequestBottomSheet({super.key});

  static Future<bool> show(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.surfaceWhite,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => const StitchingRequestBottomSheet(),
    );
    return result ?? false;
  }

  @override
  ConsumerState<StitchingRequestBottomSheet> createState() =>
      _StitchingRequestBottomSheetState();
}

class _StitchingRequestBottomSheetState
    extends ConsumerState<StitchingRequestBottomSheet> {
  final _titleController = TextEditingController();
  final _phoneController = TextEditingController();
  final _titleFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  String? _selectedCategory;

  static const _categories = [
    'Blouse Stitching',
    'Salwar Suit & Kurti',
    'Lehenga Choli',
    'Anarkali Dress',
    'Saree Draping & Pico',
    'Custom Alterations & Fitting',
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(stitchingSubmissionProvider.notifier).reset();
      final customer = ref.read(customerProfileProvider).valueOrNull;
      final phone = customer?.phone;
      if (phone != null && phone.isNotEmpty) {
        _phoneController.text = phone;
      }
    });
  }

  @override
  void dispose() {
    _titleFocusNode.dispose();
    _phoneFocusNode.dispose();
    _titleController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final success = await ref
        .read(stitchingSubmissionProvider.notifier)
        .submitRequest(
          title: _titleController.text,
          category: _selectedCategory,
          phone: _phoneController.text,
        );

    if (success && mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final customer = ref.watch(customerProfileProvider).valueOrNull;
    final user = ref.watch(currentCustomerUserProvider);
    final submissionState = ref.watch(stitchingSubmissionProvider);
    final isSubmitting = submissionState is StitchingSubmissionSubmitting;
    final failure = submissionState.mapOrNull(failure: (f) => f.failure);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderSoft,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'Request Stitching Service',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.charcoal,
              ),
            ),
            Text(
              'Enter a title and select apparel category for your request.',
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: AppColors.mutedText,
              ),
            ),

            const SizedBox(height: 20),

            if (failure != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.error),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: AppColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        failure.message ?? 'An error occurred.',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            TextFormField(
              controller: _titleController,
              focusNode: _titleFocusNode,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_phoneFocusNode),
              enabled: !isSubmitting,
              style: GoogleFonts.montserrat(fontSize: 14),
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Request Title / Garment Name *',
                hintText: 'e.g. Silk Designer Blouse',
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'SELECT APPAREL CATEGORY *',
              style: GoogleFonts.montserrat(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.mutedText,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  selectedColor: AppColors.brandGreen900,
                  labelStyle: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? AppColors.surfaceWhite
                        : AppColors.charcoal,
                  ),
                  onSelected: isSubmitting
                      ? null
                      : (selected) {
                          setState(() {
                            _selectedCategory = selected ? cat : null;
                          });
                        },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            TextFormField(
              controller: _phoneController,
              focusNode: _phoneFocusNode,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
              enabled: !isSubmitting,
              style: GoogleFonts.montserrat(fontSize: 14),
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Contact Phone Number *',
                hintText: 'e.g. +91 98765 43210',
              ),
            ),

          const SizedBox(height: 12),
          Text(
            'Customer: ${customer?.name ?? user?.displayName ?? 'Valued Customer'} (${user?.email ?? ''})',
            style: GoogleFonts.montserrat(
              fontSize: 11,
              color: AppColors.mutedText,
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandGreen900,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: AppColors.surfaceWhite,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Submit Stitching Request',
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
  );
}
}
