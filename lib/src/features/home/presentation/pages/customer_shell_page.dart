import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/double_back_to_exit_wrapper.dart';
import '../../../../core/widgets/network_listener_wrapper.dart';
import '../../../auth/application/providers/auth_providers.dart';
import '../../../auth/presentation/widgets/google_auth_bottom_sheet.dart';
import '../../../notification/application/providers/notification_providers.dart';
import '../../../notification/domain/models/notification_permission_state.dart';

/// Persistent 4-tab bottom navigation shell for Kapada Creation Customer App.
/// Primary destinations: Home, Favorites, My Stitching, Profile.
class CustomerShellPage extends ConsumerStatefulWidget {
  const CustomerShellPage({super.key, required this.child});

  final Widget child;

  static int _tabIndex(String location) {
    if (location.startsWith('/customer/favorites')) return 1;
    if (location.startsWith('/customer/stitching')) return 2;
    if (location.startsWith('/customer/profile')) return 3;
    return 0; // home is default
  }

  static const _tabPaths = [
    AppRoutes.customerHome,
    AppRoutes.customerFavorites,
    AppRoutes.customerStitchingList,
    AppRoutes.customerProfile,
  ];

  @override
  ConsumerState<CustomerShellPage> createState() => _CustomerShellPageState();
}

class _CustomerShellPageState extends ConsumerState<CustomerShellPage> {
  bool _hasPromptedNotification = false;
  String? _initializedFcmUserId;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final activeIndex = CustomerShellPage._tabIndex(location);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final permState = ref.watch(notificationPermissionProvider);
    final user = ref.watch(currentCustomerUserProvider);
    final currentUserId =
        (user != null && user.uid.isNotEmpty) ? user.uid : 'guest_device';

    // Ensure FCM service is initialized on shell load for guest and authenticated users
    if (_initializedFcmUserId != currentUserId) {
      _initializedFcmUserId = currentUserId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(firebaseMessagingServiceProvider).initialize(
              customerId: currentUserId,
              firebaseUid: user?.uid,
            );
      });
    }

    // Direct system notification permission request on first load (no custom dialog)
    if (permState is NotificationPermissionNotRequested &&
        !_hasPromptedNotification) {
      _hasPromptedNotification = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await ref
            .read(notificationPermissionProvider.notifier)
            .requestPermission(customerUid: user?.uid);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      body: NetworkListenerWrapper(
        child: DoubleBackToExitWrapper(
          child: widget.child,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceWhite,
          border: Border(
            top: BorderSide(color: AppColors.borderSoft, width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 68,
            child: Row(
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Home',
                  isActive: activeIndex == 0,
                  onTap: () => _navigateTab(context, ref, 0, isAuthenticated),
                ),
                _NavItem(
                  icon: Icons.favorite_outline_rounded,
                  activeIcon: Icons.favorite_rounded,
                  label: 'Favorites',
                  isActive: activeIndex == 1,
                  onTap: () => _navigateTab(context, ref, 1, isAuthenticated),
                ),
                _NavItem(
                  icon: Icons.design_services_outlined,
                  activeIcon: Icons.design_services_rounded,
                  label: 'My Stitching',
                  isActive: activeIndex == 2,
                  onTap: () => _navigateTab(context, ref, 2, isAuthenticated),
                ),
                _NavItem(
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: 'Profile',
                  isActive: activeIndex == 3,
                  onTap: () => _navigateTab(context, ref, 3, isAuthenticated),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _navigateTab(
    BuildContext context,
    WidgetRef ref,
    int index,
    bool isAuthenticated,
  ) async {
    if (!isAuthenticated && (index == 1 || index == 2)) {
      final title = index == 1 ? 'Save Favorites' : 'Track Stitching Orders';
      final message = index == 1
          ? 'Sign in with Google to save your favorite styles across devices.'
          : 'Sign in with Google to view and manage your custom stitching requests.';

      final loggedIn = await GoogleAuthBottomSheet.show(
        context,
        title: title,
        message: message,
      );

      if (!loggedIn) return;
    }

    if (context.mounted) {
      context.go(CustomerShellPage._tabPaths[index]);
    }
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.brandGreen900 : AppColors.mutedText;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(isActive ? activeIcon : icon, size: 22, color: color),
              const SizedBox(height: 3),
              Text(
                label,
                style: GoogleFonts.montserrat(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: color,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
