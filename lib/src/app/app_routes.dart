import 'package:go_router/go_router.dart';

import '../features/category/domain/models/category_model.dart';
import '../features/category/presentation/pages/customer_category_designs_page.dart';
import '../features/customer/presentation/pages/customer_profile_edit_page.dart';
import '../features/customer/presentation/pages/customer_profile_page.dart';
import '../features/design/domain/models/design_model.dart';
import '../features/design/presentation/pages/customer_design_details_page.dart';
import '../features/design/presentation/pages/customer_favorites_page.dart';
import '../features/home/presentation/pages/customer_home_page.dart';
import '../features/home/presentation/pages/customer_shell_page.dart';
import '../features/notification/domain/models/notification_model.dart';
import '../features/notification/presentation/pages/customer_notification_details_page.dart';
import '../features/notification/presentation/pages/customer_notification_list_page.dart';
import '../features/onboarding/presentation/pages/splash_page.dart';
import '../features/section/domain/models/section_model.dart';
import '../features/section/presentation/pages/customer_section_listing_page.dart';
import '../features/stitching/domain/models/stitching_order_model.dart';
import '../features/stitching/presentation/pages/customer_stitching_order_details_page.dart';
import '../features/stitching/presentation/pages/customer_stitching_order_list_page.dart';
import '../features/trending/presentation/pages/customer_trending_listing_page.dart';

/// Centralized route paths and router configuration for KC-App.
abstract class AppRoutes {
  const AppRoutes._();

  // Splash
  static const String splash = '/splash';

  // Customer shell 4 primary tabs
  static const String customerHome = '/customer/home';
  static const String customerFavorites = '/customer/favorites';
  static const String customerStitchingList = '/customer/stitching';
  static const String customerProfile = '/customer/profile';

  // Section & Trending listing
  static const String customerSectionListing = '/customer/sections/listing';
  static const String customerTrendingListing = '/customer/trending/listing';

  // Design details
  static const String customerDesignDetails = '/customer/designs/details';

  // Profile Edit
  static const String customerProfileEdit = '/customer/profile/edit';

  // Stitching Details
  static const String customerStitchingDetails = '/customer/stitching/details';

  // Notifications
  static const String customerNotificationList = '/customer/notifications';
  static const String customerNotificationDetails =
      '/customer/notifications/details';

  // Legacy/Alias route fallbacks
  static const String welcome = splash;
  static const String customerSelectBoutique = customerHome;
  static const String customerSelectBranch = customerHome;
  static const String customerCategoryList = customerHome;
  static const String customerCategoryDesigns = '/customer/category/designs';
  static const String customerAllDesigns = customerHome;
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    // Splash screen -> auto restores auth and navigates to customerHome
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashPage(),
    ),

    // ── Persistent 4-Tab Bottom Nav Shell ───────────────────────
    ShellRoute(
      builder: (context, state, child) => CustomerShellPage(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.customerHome,
          builder: (context, state) => const CustomerHomePage(),
        ),
        GoRoute(
          path: AppRoutes.customerFavorites,
          builder: (context, state) => const CustomerFavoritesPage(),
        ),
        GoRoute(
          path: AppRoutes.customerStitchingList,
          builder: (context, state) => const CustomerStitchingOrderListPage(),
        ),
        GoRoute(
          path: AppRoutes.customerProfile,
          builder: (context, state) => const CustomerProfilePage(),
        ),
      ],
    ),

    // ── Push Routes ─────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.customerSectionListing,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is SectionModel) {
          return CustomerSectionListingPage(section: extra);
        }
        final sectionName = state.uri.queryParameters['section'] ?? 'Trending';
        return CustomerSectionListingPage(sectionName: sectionName);
      },
    ),
    GoRoute(
      path: AppRoutes.customerTrendingListing,
      builder: (context, state) => const CustomerTrendingListingPage(),
    ),
    GoRoute(
      path: AppRoutes.customerDesignDetails,
      builder: (context, state) =>
          CustomerDesignDetailsPage(design: state.extra as DesignModel),
    ),
    GoRoute(
      path: AppRoutes.customerProfileEdit,
      builder: (context, state) => const CustomerProfileEditPage(),
    ),
    GoRoute(
      path: AppRoutes.customerStitchingDetails,
      builder: (context, state) => CustomerStitchingOrderDetailsPage(
        order: state.extra as StitchingOrderModel,
      ),
    ),
    GoRoute(
      path: AppRoutes.customerNotificationList,
      builder: (context, state) => const CustomerNotificationListPage(),
    ),
    GoRoute(
      path: AppRoutes.customerNotificationDetails,
      builder: (context, state) => CustomerNotificationDetailsPage(
        notification: state.extra as NotificationModel,
      ),
    ),
    GoRoute(
      path: AppRoutes.customerCategoryDesigns,
      builder: (context, state) => CustomerCategoryDesignsPage(
        category: state.extra as CategoryModel,
      ),
    ),
  ],
);
