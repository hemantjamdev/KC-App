import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_colors.dart';

/// SliverPersistentHeaderDelegate providing parity with KC-Admin's home header.
/// Features smooth collapsing typography, time-based greeting, notification bell,
/// and profile avatar with user photo.
class CustomerHomeHeaderDelegate extends SliverPersistentHeaderDelegate {
  CustomerHomeHeaderDelegate({
    required this.customerName,
    required this.photoUrl,
    required this.unreadNotificationCount,
    required this.isAuthenticated,
  });

  final String customerName;
  final String? photoUrl;
  final int unreadNotificationCount;
  final bool isAuthenticated;

  @override
  double get minExtent => 72.0;

  @override
  double get maxExtent => 125.0;

  static String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final timeGreeting = _greeting();
    final rawName = customerName.trim().isNotEmpty ? customerName.trim() : 'Guest';
    final firstName = rawName.split(' ').first;
    final formattedName = firstName.isNotEmpty
        ? '${firstName[0].toUpperCase()}${firstName.substring(1)}'
        : 'Guest';

    final progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final isPinned = shrinkOffset > 10;

    final initialChar = formattedName.isNotEmpty
        ? formattedName[0].toUpperCase()
        : 'C';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.warmIvory,
        border: isPinned
            ? Border(
                bottom: BorderSide(
                  color: AppColors.borderSoft.withValues(alpha: progress),
                ),
              )
            : null,
        boxShadow: isPinned
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04 * progress),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Align(
        alignment: Alignment.center,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left Column: Greeting & Customer Name
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (progress < 0.5)
                    Opacity(
                      opacity: (1.0 - progress * 2.0).clamp(0.0, 1.0),
                      child: Text(
                        'Welcome back',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  if (progress < 0.5) const SizedBox(height: 2),

                  Text(
                    progress < 0.7
                        ? '$timeGreeting,'
                        : '$timeGreeting, $formattedName',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22 - (4 * progress),
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  if (progress < 0.7) ...[
                    const SizedBox(height: 2),
                    Opacity(
                      opacity: progress < 0.5
                          ? 1.0
                          : (1.0 - ((progress - 0.5) / 0.2)).clamp(0.0, 1.0),
                      child: Text(
                        formattedName,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 24 - (4 * progress),
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Right Actions: Notification Bell
            GestureDetector(
              onTap: () => context.push(AppRoutes.customerNotificationList),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.borderSoft),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.notifications_none_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    if (unreadNotificationCount > 0)
                      Positioned(
                        top: 9,
                        right: 9,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 10),

            // Profile Avatar with Image
            GestureDetector(
              onTap: () => context.push(AppRoutes.customerProfile),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  backgroundImage: photoUrl != null && photoUrl!.startsWith('http')
                      ? NetworkImage(photoUrl!)
                      : null,
                  child: photoUrl == null || !photoUrl!.startsWith('http')
                      ? Text(
                          initialChar,
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant CustomerHomeHeaderDelegate oldDelegate) {
    return oldDelegate.customerName != customerName ||
        oldDelegate.photoUrl != photoUrl ||
        oldDelegate.unreadNotificationCount != unreadNotificationCount ||
        oldDelegate.isAuthenticated != isAuthenticated;
  }
}
