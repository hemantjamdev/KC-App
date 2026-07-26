import 'package:go_router/go_router.dart';
import '../features/boutique/presentation/pages/customer_boutique_selection_page.dart';
import '../features/boutique/presentation/pages/customer_branch_selection_page.dart';
import '../features/category/domain/models/category_model.dart';
import '../features/category/presentation/pages/category_preview_page.dart';
import '../features/category/presentation/pages/customer_category_list_page.dart';
import '../features/customer/presentation/pages/customer_profile_edit_page.dart';
import '../features/customer/presentation/pages/customer_profile_page.dart';
import '../features/design/domain/models/design_model.dart';
import '../features/design/presentation/pages/customer_all_designs_page.dart';
import '../features/design/presentation/pages/customer_design_details_page.dart';
import '../features/design/presentation/pages/customer_design_list_page.dart';
import '../features/home/presentation/pages/customer_home_page.dart';
import '../features/notification/domain/models/notification_model.dart';
import '../features/notification/presentation/pages/customer_notification_details_page.dart';
import '../features/notification/presentation/pages/customer_notification_list_page.dart';
import '../features/onboarding/presentation/pages/splash_page.dart';
import '../features/onboarding/presentation/pages/welcome_page.dart';
import '../features/section/domain/models/section_model.dart';
import '../features/section/presentation/pages/customer_section_details_page.dart';
import '../features/stitching/domain/models/stitching_order_model.dart';
import '../features/stitching/presentation/pages/customer_stitching_order_details_page.dart';
import '../features/stitching/presentation/pages/customer_stitching_order_list_page.dart';

/// Centralized route paths and router configuration for KC-App.
abstract class AppRoutes {
  const AppRoutes._();

  // Onboarding
  static const String splash = '/splash';
  static const String welcome = '/welcome';

  // Boutique selection
  static const String customerSelectBoutique = '/customer/select-boutique';
  static const String customerSelectBranch = '/customer/select-branch';

  // Customer home
  static const String customerHome = '/customer/home';

  // Categories
  static const String customerCategoryList = '/customer/categories';
  static const String customerCategoryPreview = '/customer/categories/preview';

  // Designs
  static const String customerCategoryDesigns = '/customer/categories/designs';
  static const String customerAllDesigns = '/customer/designs/all';
  static const String customerDesignDetails = '/customer/designs/details';

  // Sections
  static const String customerSectionDetails = '/customer/sections/details';

  // Profile & Auth
  static const String customerProfile = '/customer/profile';
  static const String customerProfileEdit = '/customer/profile/edit';

  // Stitching Orders
  static const String customerStitchingList = '/customer/stitching';
  static const String customerStitchingDetails = '/customer/stitching/details';

  // Notifications
  static const String customerNotificationList = '/customer/notifications';
  static const String customerNotificationDetails =
      '/customer/notifications/details';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: AppRoutes.welcome,
      builder: (context, state) => const WelcomePage(),
    ),
    GoRoute(
      path: AppRoutes.customerSelectBoutique,
      builder: (context, state) => const CustomerBoutiqueSelectionPage(),
    ),
    GoRoute(
      path: AppRoutes.customerSelectBranch,
      builder: (context, state) => const CustomerBranchSelectionPage(),
    ),
    GoRoute(
      path: AppRoutes.customerHome,
      builder: (context, state) => const CustomerHomePage(),
    ),
    GoRoute(
      path: AppRoutes.customerCategoryList,
      builder: (context, state) => const CustomerCategoryListPage(),
    ),
    GoRoute(
      path: AppRoutes.customerCategoryPreview,
      builder: (context, state) =>
          CategoryPreviewPage(category: state.extra as CategoryModel),
    ),
    // Designs
    GoRoute(
      path: AppRoutes.customerCategoryDesigns,
      builder: (context, state) =>
          CustomerDesignListPage(category: state.extra as CategoryModel),
    ),
    GoRoute(
      path: AppRoutes.customerAllDesigns,
      builder: (context, state) => const CustomerAllDesignsPage(),
    ),
    GoRoute(
      path: AppRoutes.customerDesignDetails,
      builder: (context, state) =>
          CustomerDesignDetailsPage(design: state.extra as DesignModel),
    ),
    // Sections
    GoRoute(
      path: AppRoutes.customerSectionDetails,
      builder: (context, state) =>
          CustomerSectionDetailsPage(section: state.extra as SectionModel),
    ),
    // Profile
    GoRoute(
      path: AppRoutes.customerProfile,
      builder: (context, state) => const CustomerProfilePage(),
    ),
    GoRoute(
      path: AppRoutes.customerProfileEdit,
      builder: (context, state) => const CustomerProfileEditPage(),
    ),
    // Stitching Orders
    GoRoute(
      path: AppRoutes.customerStitchingList,
      builder: (context, state) => const CustomerStitchingOrderListPage(),
    ),
    GoRoute(
      path: AppRoutes.customerStitchingDetails,
      builder: (context, state) => CustomerStitchingOrderDetailsPage(
        order: state.extra as StitchingOrderModel,
      ),
    ),
    // Notifications
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
  ],
);
