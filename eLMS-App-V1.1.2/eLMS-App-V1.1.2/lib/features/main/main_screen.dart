import 'package:elms/common/widgets/custom_popscope.dart';
import 'package:elms/core/constants/app_constant.dart';
import 'package:elms/core/deep_linking/deep_link_manager.dart';
import 'package:elms/core/login/guest_checker.dart';
import 'package:elms/core/routes/routes.dart';
import 'package:elms/features/settings/cubit/app_settings_cubit.dart';
import 'package:elms/features/cart/cubit/cart_cubit.dart';
import 'package:elms/features/cart/widgets/floating_cart_bar.dart';
import 'package:elms/features/course/cubits/fetch_course_languages_cubit.dart';
import 'package:elms/features/course/repository/course_repository.dart';
import 'package:elms/features/course/services/course_content_notifier.dart';
import 'package:elms/features/course/services/course_content_overlay.dart';
import 'package:elms/features/home/cubits/fetch_featured_sections_cubit.dart';
import 'package:elms/features/home/cubits/fetch_slider_cubit.dart';
import 'package:elms/features/home/repositories/slider_repository.dart';
import 'package:elms/features/home/screens/home_screen.dart';
import 'package:elms/features/main/widgets/custom_bottom_nav_bar.dart';
import 'package:elms/features/profile/screens/profile_screen.dart';
import 'package:elms/features/my_learning/screens/my_learning_screen.dart';
import 'package:elms/features/explore/cubit/explore_cubit.dart';
import 'package:elms/features/explore/screens/explore_screen.dart';
import 'package:elms/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

export 'package:elms/features/course/services/course_content_overlay.dart'
    show
        courseContentNavigator,
        courseContentOverlayVisible,
        courseContentRouteObserver,
        CourseContentRouteObserver;

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  static Widget route() => MultiBlocProvider(
    providers: [
      BlocProvider(create: (context) => FetchSliderCubit(SliderRepository())),
      BlocProvider(
        create: (context) => FetchFeaturedSectionsCubit(CourseRepository()),
      ),
      BlocProvider(
        create: (context) => ExploreCubit(CourseRepository())..fetch(),
      ),
    ],
    child: const MainScreen(),
  );
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  // Controllers

  final PageController pageController = PageController();
  final ValueNotifier<int> _currentIndex = ValueNotifier(0);

  void _pageControllerListener() {
    if (pageController.page != null) {
      _currentIndex.value = pageController.page!.toInt();
    }
  }

  GlobalKey bottomNavigationKey = GlobalKey();

  // State
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      AppConstant.calculatedBottomNavigationHight = UiUtils.getWidgetBounds(
        bottomNavigationKey,
      )!.size.height;
    });
    DeepLinkManager.instance.initialize();

    if (!GuestChecker.value) {
      context.read<CartCubit>().fetch();
    }

    context.read<AppSettingsCubit>().fetchIfFailed();
    context.read<FetchCourseLanguagesCubit>().fetch();
    _setupPageController();
  }

  void _setupPageController() {
    // Remove listener if it was already added to avoid duplicates
    pageController.removeListener(_pageControllerListener);
    pageController.addListener(_pageControllerListener);
  }

  @override
  void dispose() {
    // Remove listener when widget is disposed
    pageController.removeListener(_pageControllerListener);
    super.dispose();
  }

  void _onNavItemTapped(int index) {
    _currentIndex.value = index;
    pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopScope(
      preventOverlay: true,
      shouldPop: () async {
        if (CourseContentNotifier.instance.isVisible) {
          CourseContentNotifier.instance.hide();
          return false;
        }
        if (courseContentNavigator.value != null) {
          courseContentNavigator.value = null;
          return false;
        }
        if (_currentIndex.value != 0) {
          _onNavItemTapped(0);
          return false;
        }
        await SystemNavigator.pop();
        return false;
      },
      child: _buildMainScaffold(),
    );
  }

  Widget _buildMainScaffold() {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              HomeScreen(),
              MyLearningScreen(),
              ExploreScreen(),
              ProfileScreen(),
            ],
          ),
          if (!GuestChecker.value)
            Positioned(
              left: 16,
              right: 16,
              bottom: 12,
              child: FloatingCartBar(
                onCheckout: () => Get.toNamed(AppRoutes.cartScreen),
              ),
            ),
        ],
      ),
      bottomNavigationBar: ValueListenableBuilder(
        valueListenable: _currentIndex,
        builder: (BuildContext context, int value, Widget? child) {
          return CustomBottomNavBar(
            key: bottomNavigationKey,
            onTabSelected: _onNavItemTapped,
            selectedTabIndex: value,
          );
        },
      ),
    );
  }
}
