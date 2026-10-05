import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/leather_stitched_container.dart';
import '../../../auth/presentation/widgets/google_auth_bottom_sheet.dart';

/// Modular Luxury User Profile Card widget for Customer Profile screen.
/// Designed with deep green leather texture, gold dashed stitching border, and gold accents.
class ProfileHeaderAvatar extends StatelessWidget {
  const ProfileHeaderAvatar({
    super.key,
    required this.displayName,
    required this.photoUrl,
    required this.isAuthenticated,
    required this.onEditPressed,
  });

  final String displayName;
  final String? photoUrl;
  final bool isAuthenticated;
  final VoidCallback onEditPressed;

  @override
  Widget build(BuildContext context) {
    final initials = displayName.trim().isNotEmpty
        ? displayName.trim().split(' ').map((e) => e[0]).take(2).join()
        : 'KC';

    return LeatherStitchedContainer(
      child: Column(
        children: [
          // Member Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.workspace_premium_rounded,
                      size: 13,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isAuthenticated ? 'VIP MEMBER' : 'STUDIO GUEST',
                      style: GoogleFonts.montserrat(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                onPressed: () {
                  if (isAuthenticated) {
                    onEditPressed();
                  } else {
                    GoogleAuthBottomSheet.show(context);
                  }
                },
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    size: 14,
                    color: AppColors.charcoal,
                  ),
                ),
                tooltip: 'Edit Profile',
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Avatar Image with White Accent Ring
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.brandGreen800,
                  backgroundImage: photoUrl != null && photoUrl!.startsWith('http')
                      ? NetworkImage(photoUrl!)
                      : null,
                  child: photoUrl == null || !photoUrl!.startsWith('http')
                      ? Text(
                          initials.toUpperCase(),
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Full Name
          Text(
            displayName,
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),

          // Status Subtitle
          Text(
            isAuthenticated
                ? 'Kapada Creation VIP Atelier Account'
                : 'Sign in to access custom stitching & wishlist',
            style: GoogleFonts.montserrat(
              fontSize: 11.5,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
