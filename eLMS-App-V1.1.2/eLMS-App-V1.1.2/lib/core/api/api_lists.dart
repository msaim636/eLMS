import 'package:elms/core/configs/app_settings.dart';

class Apis {
  Apis._();

  // Base URL
  static String baseUrl = AppSettings.baseUrl;

  // Auth endpoints
  static final String userExists = api('user-exists');
  static final String login = api('user-login');
  static final String userSignup = api('user-signup');
  static final String mobileLogin = api('mobile-login');
  static final String mobileRegister = api('mobile-registration');
  static final String resetPassword = api('mobile-reset-password');

  ///User/Profile APIs
  static final String getUserDetails = api('get-user-details');
  static final String updateProfile = api('update-profile');
  static final String changePassword = api('change-password');
  static final String deleteAccount = api('delete-account');

  ///App Settings APIs
  static final String appSettings = api('app-settings');
  static final String systemLanguages = api('system-languages');
  static final String pages = api('pages');

  ///Course related apis
  static final String getCourses = api('get-courses');
  static final String getCourse = api('get-course');
  static final String getCourseReviews = api('get-course-reviews');
  static final String getCourseLanguages = api('get-course-languages');
  static final String courseCompletion = api('curriculum/course-completion');

  ///Category related APIs
  static final String categories = api('categories');
  static final String categoriesTree = api('categories-tree');

  ///Instructor APIs
  static final String getInstructors = api('get-instructors');
  static final String getInstructorDetails = api('get-instructor-details');

  ///Slider/Featured APIs
  static final String slider = api('get-sliders');
  static final String getFeatureSections = api('get-feature-sections');

  ///Wishlist APIs
  static final String getWishlist = api('wishlist');
  static final String wishlist = api('wishlist/add-update-wishlist');

  ///Cart related APIs
  static final String getCart = api('cart');
  static final String addToCart = api('cart/add');
  static final String removeFromCart = api('cart/remove');
  static final String clearCart = api('cart/clear');
  static final String applyCouponCart = api('cart/apply-promo');
  static final String removeCouponCart = api('cart/remove-promo');
  static final String billingDetails = api('billing-details');

  ///Order APIs
  static final String placeOrder = api('place_order');
  static final String orders = api('orders');
  static final String invoiceDownload = api('download-invoice');

  ///Coupon/Promo Code APIs
  static final String getCouponList = api('promo-code/list');
  static final String applyCoupon = api('promo-code/apply-promo-code');

  ///My Learning related APIs
  static final String myLearning = api('my-learning');

  ///Curriculum APIs
  static final String markCurriculumComplete = api('curriculum/mark-completed');

  ///Assignment related APIs
  static final String getAssignments = api('get-assignments');
  static final String submitAssignment = api('assignments/submit');
  static final String updateAssignmentSubmission = api(
    'assignments/submission',
  );

  ///Resources APIs
  static final String getResources = api('get-resources');

  ///Review related APIs
  static final String addReview = api('rating/add');
  static final String deleteReview = api('rating/delete');

  ///Discussion related APIs
  static final String courseDiscussion = api('discussion/course');

  ///Notification APIs
  static final String notifications = api('notifications');

  ///help desk
  static final String discussionGroups = api('helpdesk/groups');
  static final String discussionQuestions = api('helpdesk/questions');
  static final String requestPrivateGroup = api('helpdesk/groups/request');
  static final String checkGroupApproval = api('helpdesk/check-group-approval');
  static final String helpDeskQuestion = api('helpdesk/question');
  static final String helpDeskQuestionReply = api('helpdesk/question/reply');
  static final String askQuestion = api('helpdesk/question');

  ///Quiz related APIs
  static final String getQuizDetails = api('quiz/details');
  static final String quizStart = api('quiz/start');
  static final String quizAnswer = api('quiz/answer');
  static final String quizFinish = api('quiz/finish');
  static final String quizSummary = api('quiz/summary');

  ///Certificate APIs
  static final String downloadCertificate = api('certificate/course/download');
  static final String purchaseCertificate = api('purchase-certificate');

  ///FAQ APIs
  static final String faqs = api('faqs');

  ///Contact APIs
  static final String contactUs = api('contact-us');

  ///Search APIs
  static final String getSearchSuggestions = api('get-search-suggestions');

  ///Team invitation related APIs
  static final String teamInvitationAction = api('accept-team-invitation');

  ///Refund related APIs
  static final String refundRequest = api('refund/request');
  static final String myRefunds = api('refund/my-refunds');

  ///Wallet related APIs
  static final String walletHistory = api('wallet/history');
  static final String withdrawalRequest = api('wallet/withdrawal-request');

  ///IAP related APIs
  static final String iapProducts = api('iap/products');
  static final String verifyIapPurchase = api('iap/verify-purchase');

  static String api(String url) {
    // ignore: no_leading_underscores_for_local_identifiers
    String _baseUrl = baseUrl;

    if (_baseUrl.endsWith('/')) {
      _baseUrl = _baseUrl.substring(0, _baseUrl.length - 1);
    } else {
      _baseUrl = baseUrl;
    }

    return '$_baseUrl/api/$url';
  }
}
