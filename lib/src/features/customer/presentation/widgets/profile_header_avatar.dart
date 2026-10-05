import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/leather_stitched_container.dart';
import '../../../auth/presentation/widgets/google_auth_bottom_sheet.dart';

/// Luxury Executive Customer Profile Header Card Widget.
/// Layout:
/// - Left: Rounded rectangle profile image (30% of screen width).
/// - Right: Column containing [Name, Phone Number, Email, Member Details, Edit Action].
class ProfileHeaderAvatar extends StatelessWidget {
  const ProfileHeaderAvatar({
    super.key,
    required this.displayName,
    required this.photoUrl,
    this.phone,
    this.email,
    this.createdAt,
    required this.isAuthenticated,
    required this.onEditPressed,
  });

  final String displayName;
  final String? photoUrl;
  final String? phone;
  final String? email;
  final DateTime? createdAt;
  final bool isAuthenticated;
  final VoidCallback onEditPressed;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageWidth = screenWidth * 0.30;
    final imageHeight = imageWidth * 1.15; // Slightly taller luxury portrait ratio

    final initials = displayName.trim().isNotEmpty
        ? displayName.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join()
        : 'KC';

    final memberSinceYear = createdAt != null ? DateFormat('yyyy').format(createdAt!) : '2024';

    return LeatherStitchedContainer(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── LEFT: Rounded Rectangle Image (30% of Screen Width) ──
          Container(
            width: imageWidth,
            height: imageHeight,
            decoration: BoxDecoration(
              color: AppColors.brandGreen800,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.goldAccent,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: (photoUrl != null && photoUrl!.startsWith('http'))
                  ? CachedNetworkImage(
                      imageUrl: photoUrl!,
                      fit: BoxFit.cover,
                      placeholder: (ctx, url) => Container(
                        color: AppColors.brandGreen800,
                        child: const Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (ctx, url, err) => _buildInitialsFallback(initials),
                    )
                  : _buildInitialsFallback(initials),
            ),
          ),

          const SizedBox(width: 14),

          // ── RIGHT: Column [Name, Phone Number, Other Details] ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Customer Name
                Text(
                  displayName,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 6),

                // 2. Phone Number (If available)
                if (phone != null && phone!.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        size: 13,
                        color: AppColors.goldAccent,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          phone!,
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.95),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],

                // 3. Email Address (If available)
                if (email != null && email!.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.email_outlined,
                        size: 13,
                        color: AppColors.goldAccent,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          email!,
                          style: GoogleFonts.montserrat(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],

                // 4. Member Status / Registered Tag
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.goldAccent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppColors.goldAccent.withValues(alpha: 0.6),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        isAuthenticated ? 'MEMBER SINCE $memberSinceYear' : 'GUEST VISITOR',
                        style: GoogleFonts.montserrat(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.goldAccent,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // 5. Profile Action (Edit Profile or Sign In)
                if (isAuthenticated)
                  InkWell(
                    onTap: onEditPressed,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            PhosphorIcons.pencilSimple(),
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Edit Profile',
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  InkWell(
                    onTap: () => GoogleAuthBottomSheet.show(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.goldAccent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Sign In with Google',
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF162D20),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 12,
                            color: Color(0xFF162D20),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialsFallback(String initials) {
    return Container(
      color: AppColors.brandGreen800,
      child: Center(
        child: Text(
          initials.toUpperCase(),
          style: GoogleFonts.playfairDisplay(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
