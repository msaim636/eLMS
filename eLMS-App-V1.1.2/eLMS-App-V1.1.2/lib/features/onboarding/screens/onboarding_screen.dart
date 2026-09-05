import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/common/widgets/custom_button.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/routes/routes.dart';
import 'package:elms/features/onboarding/models/onboarding_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static Widget route() => const OnboardingScreen();

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late List<OnboardingModel> onboardings = [
    OnboardingModel(
      title: AppLabels.onBoardingFirstTitle.tr,
      description: AppLabels.onBoardingFirstSubTitle.tr,
      image: AppIcons.onboarding1,
    ),
    OnboardingModel(
      title: AppLabels.onBoardingSecondTitle.tr,
      description: AppLabels.onBoardingSecondSubTitle.tr,
      image: AppIcons.onboarding2,
    ),
    OnboardingModel(
      title: AppLabels.onBoardingThirdTitle.tr,
      description: AppLabels.onBoardingThirdSubTitle.tr,
      image: AppIcons.onboarding3,
    ),
  ];

  late OnboardingModel currentOnboarding = onboardings.first;
  int currentIndex = 0;
  void _onClickNext() {
    ///If its last screen then navigate to login screen
    if (currentOnboarding == onboardings.last) {
      Get.offAllNamed(AppRoutes.loginScreen);
      return;
    }
    currentIndex = onboardings.indexOf(currentOnboarding);
    if (currentIndex < onboardings.length - 1) {
      currentOnboarding = onboardings[currentIndex + 1];
    }
    setState(() {});
  }

  void _onPreviousEvent() {
    final int currentIndex = onboardings.indexOf(currentOnboarding);
    if (currentIndex > 0) {
      currentOnboarding = onboardings[currentIndex - 1];
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(flex: 6, child: buildImageContainer()),
              Expanded(flex: 4, child: buildContentContainer(context)),
            ],
          ),

          if (currentOnboarding != onboardings.last)
            PositionedDirectional(
              end: 16,
              top: 70,
              child: CustomButton(
                height: 38,
                width: 61,
                type: .outlined,
                onPressed: () {
                  Get.offAllNamed(AppRoutes.loginScreen);
                },
                title: AppLabels.skip.tr,
              ),
            ),
        ],
      ),
    );
  }

  Widget buildContentContainer(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        ///This is to enable swipe to navigate
        if (details.velocity.pixelsPerSecond.dx == 0) {
          return;
        }
        if (details.velocity.pixelsPerSecond.dx.isNegative) {
          _onClickNext();
        } else {
          _onPreviousEvent();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: context.color.primary,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const .all(16),
          child: Column(
            children: [
              Expanded(
                flex: 9,
                child: Column(
                  spacing: 21,
                  mainAxisAlignment: .center,
                  children: [
                    Text(
                      currentOnboarding.title,
                      style: TextStyle(
                        fontSize: context.font.xxLarge,
                        fontWeight: .w600,
                        color: context.color.onPrimary,
                      ),
                    ),
                    Text(
                      currentOnboarding.description,
                      textAlign: .center,
                      style: TextStyle(
                        fontSize: context.font.medium,
                        fontWeight: .w400,
                        color: context.color.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    buildOnboardingIndicator(context),
                    const Spacer(),
                    buildContinueButton(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildImageContainer() {
    return Stack(
      children: [
        CustomImage(
          AppIcons.onboardingBackground,
          fit: .cover,
          width: double.maxFinite,
        ),
        Align(child: CustomImage(currentOnboarding.image)),
      ],
    );
  }

  Widget buildOnboardingIndicator(BuildContext context) {
    return Row(
      spacing: 6,
      children: List.generate(
        onboardings.length,
        (index) => AnimatedContainer(
          width: 12,
          height: 12,
          duration: const Duration(milliseconds: 260),
          decoration: BoxDecoration(
            color: currentOnboarding == onboardings[index]
                ? context.color.onPrimary
                : context.color.onPrimary.withValues(alpha: 0.4),
            shape: .circle,
          ),
        ),
      ),
    );
  }

  Widget buildContinueButton(BuildContext context) {
    final bool isLast = currentOnboarding == onboardings.last;

    if (isLast) {
      return CustomButton(
        key: const ValueKey('loginButton'),
        onPressed: _onClickNext,
        title: AppLabels.login.tr,
        width: 78,
        height: 34,
        backgroundColor: context.color.onPrimary,
      );
    }

    return GestureDetector(
      onTap: _onClickNext,
      key: const ValueKey('rightButton'),
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          shape: .circle,
          color: context.color.onPrimary,
        ),
        child: CustomImage(
          AppIcons.arrowRight,
          width: 24,
          height: 24,
          fit: .none,
          color: context.color.onSurface,
        ),
      ),
    );
  }
}
