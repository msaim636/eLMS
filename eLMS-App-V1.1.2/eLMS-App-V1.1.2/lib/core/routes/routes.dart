import 'package:elms/common/screens/course_list_screen.dart';
import 'package:elms/common/screens/reviews_screen.dart';
import 'package:elms/features/authentication/screens/forgot_password_screen.dart';
import 'package:elms/features/authentication/screens/login_screen.dart';
import 'package:elms/features/authentication/screens/register_options_screen.dart';
import 'package:elms/features/authentication/screens/reset_password_screen.dart';
import 'package:elms/features/authentication/screens/signup/signup_screen.dart';
import 'package:elms/features/cart/screens/billing_details_screen.dart';
import 'package:elms/features/coupon/screens/coupon_screen.dart';
import 'package:elms/features/course/features/quiz/screens/quiz_result_screen.dart';
import 'package:elms/features/course/features/quiz/screens/quiz_screen.dart';
import 'package:elms/features/course/features/quiz/screens/quiz_summary_screen.dart';
import 'package:elms/features/course/screens/about_course_screen.dart';
import 'package:elms/features/course/screens/certificate_screen.dart';
import 'package:elms/features/course/screens/course_content_screen.dart';
import 'package:elms/features/course/screens/course_details_screen.dart';
import 'package:elms/features/course/features/discussion/screens/thread_screen.dart';
import 'package:elms/features/course/screens/course_resources_screen.dart';
import 'package:elms/features/course/screens/document_viewer_screen.dart';
import 'package:elms/features/course/screens/filter_screen.dart';
import 'package:elms/features/help_support/screens/discussion_groups_screen.dart';
import 'package:elms/features/help_support/screens/discussion_list_screen.dart';
import 'package:elms/features/help_support/screens/discussion_thread_screen.dart';
import 'package:elms/features/help_support/screens/help_support_screen.dart';
import 'package:elms/features/instructor/screens/instructor_details_screen.dart';
import 'package:elms/features/main/main_screen.dart';
import 'package:elms/features/notification/screens/notification_screen.dart';
import 'package:elms/features/onboarding/screens/onboarding_screen.dart';
import 'package:elms/features/profile/screens/edit_profile_screen.dart';
import 'package:elms/features/splash/splash_screen.dart';
import 'package:elms/features/authentication/screens/verification_screen.dart';
import 'package:elms/features/home/screens/home_screen.dart';
import 'package:elms/features/search/screens/search_screen.dart';
import 'package:elms/features/my_learning/screens/my_learning_screen.dart';
import 'package:elms/features/cart/screens/cart_screen.dart';
import 'package:elms/features/cart/screens/checkout_screen.dart';
import 'package:elms/features/cart/screens/payment_webview_screen.dart';
import 'package:elms/features/category/screens/category_list_screen.dart';
import 'package:elms/features/explore/screens/explore_instructors_screen.dart';
import 'package:elms/features/instructor/screens/instructor_list_screen.dart';
import 'package:elms/features/video_player/screens/full_screen_player.dart';
import 'package:elms/features/video_player/screens/video_preview_screen.dart';
import 'package:elms/features/wishlist/screens/wishlist_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:elms/features/settings/screens/language_screen.dart';
import 'package:elms/features/course/screens/assignment_screen.dart';
import 'package:elms/features/transaction/screens/purchase_history_screen.dart';
import 'package:elms/features/wallet/screens/wallet_screen.dart';
import 'package:elms/features/policy/screens/policy_screen.dart';
import 'package:elms/features/contact_us/screens/contact_us_screen.dart';
import 'package:elms/features/settings/screens/maintenance_mode_screen.dart';
import 'package:elms/features/iap/screens/add_money_screen.dart';

abstract class AppRoutes {
  static const String splashScreen = '/';
  static const String onBoardingScreen = '/onboarding';
  static const String loginScreen = '/login';
  static const String registerOptionsScreen = '/register-options';
  static const String signupScreen = '/signup';
  static const String verificationScreen = '/verification';
  static const String forgotPasswordScreen = '/forgot-password';
  static const String resetPasswordScreen = '/reset-password';
  static const String mainActivity = '/main';
  static const String homeScreen = '/home';
  static const String searchScreen = '/search';
  static const String myLearningScreen = '/my-learning';
  static const String cartScreen = '/cart';
  static const String checkoutScreen = '/checkout';
  static const String paymentWebViewScreen = '/payment-webview';
  static const String categoryListScreen = '/categories';
  static const String instructorListScreen = '/instructors';
  static const String exploreInstructorsScreen = '/explore-instructors';
  static const String courseListScreen = '/course-list';
  static const String courseDetailsScreen = '/course-details';
  static const String languageScreen = '/language';
  static const String courseContentScreen =
      '/course-content'; // Points to CourseContentRoute
  static const String threadScreen = '/thread-screen';
  // Course content related routes (used when experimental feature is off)
  static const String aboutCourseScreen = '/about-course';
  static const String courseResourcesScreen = '/course-resources';
  static const String courseCertificateScreen = '/course-certificate';
  static const String assignmentScreen = '/course-assignment';
  static const String couponScreen = '/coupon';
  static const String videoPreviewScreen = '/video-preview';
  static const String filterScreen = '/filter-screen';
  static const String instructorDetailsScreen = '/instructor-details';
  static const String editProfileScreen = '/edit-profile';
  static const String notificationScreen = '/notification';
  static const String purchaseHistoryScreen = '/purchase-history';
  static const String walletScreen = '/wallet';
  static const String wishlistScreen = '/wishlist';
  static const String quizScreen = '/quiz';
  static const String quizResultScreen = '/result';
  static const String quizSummaryScreen = '/quiz-summary';
  static const String helpSupportScreen = '/help-support';
  static const String discussionGroupListScreen =
      '/discussion-group-list-screen';
  static const String discussionPointsScreen = '/discussion-points';
  static const String discussionListScreen = '/discussion-screen';
  static const String discussionThreadScreen = '/discussion-thread-screen';
  static const String reviewsScreen = '/reviews';
  static const String fullScreenVideoPlayer = '/full-screen-video';
  static const String policyScreen = '/policy';
  static const String contactUsScreen = '/contact-us';
  static const String maintenanceModeScreen = '/maintenance-mode';
  static const String billingDetailsScreen = '/billing-details';
  static const String addMoneyScreen = '/add-money';
  static const String dynamicLink = '/link';
  static const String documentViewer = '/document-viewer';

  static final List<GetPage> pages = <GetPage>[
    GetPage(name: splashScreen, page: SplashScreen.route),
    GetPage(name: onBoardingScreen, page: OnboardingScreen.route),
    GetPage(name: loginScreen, page: LoginScreen.route),
    GetPage(name: registerOptionsScreen, page: RegisterOptionsScreen.route),
    GetPage(name: signupScreen, page: SignupScreen.route),
    GetPage(name: verificationScreen, page: VerificationScreen.route),
    GetPage(name: forgotPasswordScreen, page: ForgotPasswordScreen.route),
    GetPage(name: mainActivity, page: MainScreen.route),
    GetPage(name: homeScreen, page: HomeScreen.route),
    GetPage(name: searchScreen, page: SearchScreen.route),
    GetPage(name: myLearningScreen, page: MyLearningScreen.route),
    GetPage(name: cartScreen, page: CartScreen.route),
    GetPage(name: checkoutScreen, page: CheckoutScreen.route),
    GetPage(name: paymentWebViewScreen, page: PaymentWebViewScreen.route),
    GetPage(name: categoryListScreen, page: CategoryListScreen.route),
    GetPage(name: instructorListScreen, page: InstructorListScreen.route),
    GetPage(
      name: exploreInstructorsScreen,
      page: ExploreInstructorsScreen.route,
    ),
    GetPage(name: courseListScreen, page: CourseListScreen.route),
    GetPage(name: courseDetailsScreen, page: CourseDetailsScreen.route),
    GetPage(
      name: courseContentScreen,
      page: CourseContentScreen.route,
      opaque: false,
      transition: Transition.noTransition,
      transitionDuration: Duration.zero,
    ),
    GetPage(name: aboutCourseScreen, page: () => AboutCourseScreen.route()),
    GetPage(
      name: courseResourcesScreen,
      page: () => CourseResourcesScreen.route(),
    ),
    GetPage(
      name: courseCertificateScreen,
      page: () => CourseCertificateScreen.route(),
    ),
    GetPage(name: languageScreen, page: LanguageScreen.route),

    GetPage(name: threadScreen, page: ThreadScreen.route),
    GetPage(name: couponScreen, page: CouponScreen.route),
    GetPage(name: videoPreviewScreen, page: VideoPreviewScreen.route),
    GetPage(name: filterScreen, page: FilterScreen.route),
    GetPage(name: instructorDetailsScreen, page: InstructorDetailsScreen.route),
    GetPage(name: editProfileScreen, page: EditProfileScreen.route),
    GetPage(name: notificationScreen, page: NotificationScreen.route),
    GetPage(name: purchaseHistoryScreen, page: PurchaseHistoryScreen.route),
    GetPage(name: walletScreen, page: WalletScreen.route),
    GetPage(name: wishlistScreen, page: WishlistScreen.route),
    GetPage(name: quizScreen, page: QuizScreen.route),
    GetPage(name: quizResultScreen, page: QuizResultScreen.route),
    GetPage(name: quizSummaryScreen, page: QuizSummaryScreen.route),
    GetPage(name: helpSupportScreen, page: HelpSupportScreen.route),
    GetPage(
      name: discussionGroupListScreen,
      page: DiscussionGroupsScreen.route,
    ),
    GetPage(name: discussionListScreen, page: DiscussionListScreen.route),
    GetPage(name: discussionThreadScreen, page: DiscussionThreadScreen.route),
    GetPage(name: reviewsScreen, page: ReviewsScreen.route),
    GetPage(name: reviewsScreen, page: ReviewsScreen.route),
    GetPage(name: fullScreenVideoPlayer, page: FullScreenPlayer.route),
    GetPage(name: resetPasswordScreen, page: ResetPasswordScreen.route),
    GetPage(name: policyScreen, page: PolicyScreen.route),
    GetPage(name: contactUsScreen, page: ContactUsScreen.route),
    GetPage(name: maintenanceModeScreen, page: MaintenanceModeScreen.route),

    //Second time for the course content
    GetPage(name: assignmentScreen, page: AssignmentScreen.route),
    GetPage(name: reviewsScreen, page: ReviewsScreen.route),
    GetPage(name: billingDetailsScreen, page: BillingDetailsScreen.route),
    GetPage(name: addMoneyScreen, page: AddMoneyScreen.route),
    GetPage(name: documentViewer, page: DocumentViewerScreen.route),
    GetPage(
      name: dynamicLink,
      page: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      transition: Transition.noTransition,
    ),
  ];
}

class CourseContentRoute {
  // Base route - used for initial route in nested navigator
  static const String courseContentScreen = '/course-content';

  // Nested routes - these are used within the nested navigator
  static const String aboutCourse = '/about-course';
  static const String courseResources = '/course-resources';
  static const String courseCertificate = '/course-certificate';
  static const String assignment = '/course-assignment';
  static const String documentViewer = '/document-viewer';
  static const String reviews = '/reviews';
  static const String quiz = '/quiz';
  static const String quizResult = '/result';
  static const String quizSummary = '/quiz-summary';
  static const String paymentWebView = '/payment-webview';
  static const String fullScreenVideoPlayer = '/full-screen-video';
  static const String discussionThread = '/discussion-thread';

  static Route? onGenerateRoute(RouteSettings settings) {
    final route = settings.name;
    if (route == '/') {
      return GetPageRoute(
        page: () {
          return CourseContentScreen.route();
        },
      );
    } else if (route == aboutCourse) {
      return GetPageRoute(
        page: () => AboutCourseScreen.route(settings),
        settings: settings,
      );
    } else if (route == courseResources) {
      return GetPageRoute(
        page: () => CourseResourcesScreen.route(settings),
        settings: settings,
      );
    } else if (route == courseCertificate) {
      return GetPageRoute(
        page: () => CourseCertificateScreen.route(settings),
        settings: settings,
      );
    } else if (route == assignment) {
      return GetPageRoute(
        page: () => AssignmentScreen.route(settings),
        settings: settings,
      );
    } else if (route == documentViewer) {
      return GetPageRoute(
        page: () => DocumentViewerScreen.route(settings),
        settings: settings,
      );
    } else if (route == reviews) {
      return GetPageRoute(
        page: () => ReviewsScreen.route(settings),
        settings: settings,
      );
    } else if (route == quiz) {
      return GetPageRoute(
        page: () => QuizScreen.route(settings),
        settings: settings,
      );
    } else if (route == quizResult) {
      return GetPageRoute(
        page: () => QuizResultScreen.route(settings),
        settings: settings,
      );
    } else if (route == quizSummary) {
      return GetPageRoute(
        page: () => QuizSummaryScreen.route(settings),
        settings: settings,
      );
    } else if (route == paymentWebView) {
      return GetPageRoute(
        page: () => PaymentWebViewScreen.route(settings),
        settings: settings,
      );
    } else if (route == fullScreenVideoPlayer) {
      return GetPageRoute(
        page: () => FullScreenPlayer.route(settings),
        settings: settings,
      );
    } else if (route == discussionThread) {
      return GetPageRoute(
        page: () => ThreadScreen.route(settings),
        settings: settings,
        fullscreenDialog: true,
      );
    }
    return null;
  }
}
