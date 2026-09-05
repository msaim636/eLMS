import 'dart:io';
import 'package:elms/common/widgets/custom_app_bar.dart';
import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/custom_inkwell.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/common/widgets/profile_card.dart';
import 'package:elms/core/configs/app_settings.dart';
import 'package:elms/core/constants/app_constant.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/debug/pattern_gesture.dart';
import 'package:elms/core/debug/production_devtools/devtools_screen.dart';
import 'package:elms/core/routes/routes.dart';
import 'package:elms/features/authentication/cubit/authentication_cubit.dart';
import 'package:elms/features/cart/widgets/cart_bottom_inset.dart';
import 'package:elms/features/policy/screens/policy_screen.dart';
import 'package:elms/features/authentication/repository/auth_repository.dart';
import 'package:elms/features/profile/cubit/delete_account_cubit.dart';
import 'package:elms/features/profile/widgets/account_security_bottomsheet.dart';
import 'package:elms/features/profile/widgets/theme_bottom_sheet.dart';
import 'package:elms/features/profile/widgets/delete_account_dialog.dart';
import 'package:elms/features/profile/widgets/logout_dialog.dart';
import 'package:elms/features/settings/cubit/app_settings_cubit.dart';
import 'package:elms/utils/extensions/color_extension.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/share_app_helper.dart';
import 'package:elms/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  PatternGestureController? _patternController;

  @override
  void initState() {
    super.initState();
    if (AppConstant.kEnableExperimentalPatternGestureDebug) {
      _patternController = PatternGestureController(
        pattern: [
          const PatternStep(1, 2), // Tap box 1 twice
          const PatternStep(2, 4), // Tap box 2 four times
        ],
        timeout: const Duration(seconds: 3),
        onPatternMatched: _onDebugUnlocked,
        isDebugModeEnabled: true,
      );
    }
  }

  @override
  void dispose() {
    _patternController?.dispose();
    super.dispose();
  }

  void _onDebugUnlocked() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const DevtoolsScreen()));
  }

  bool _isSharingApp = false;

  Future<void> _onTapShareApp() async {
    if (_isSharingApp) return;
    _isSharingApp = true;
    try {
      await ShareAppHelper.shareApp(context);
    } finally {
      // Adding a small delay to ensure the share dialog has time to appear
      // preventing multiple rapid clicks from triggering it again immediately
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        _isSharingApp = false;
      }
    }
  }

  Future<void> _onTapRating() async {
    if (Platform.isAndroid) {
      await _openStoreListing();
      return;
    }

    try {
      await _openStoreListing();
    } catch (e) {
      await _openStoreListing();
    }
  }

  Future<void> _openStoreListing() async {
    final settings = context.read<AppSettingsCubit>().settings;
    final String? storeUrl = Platform.isIOS
        ? settings?.appstoreUrl
        : settings?.playstoreUrl;

    if (storeUrl != null && storeUrl.isNotEmpty) {
      final Uri uri = Uri.parse(storeUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    }
  }

  Widget _buildProfileHeader(BuildContext context) {
    return BlocBuilder<AuthenticationCubit, AuthenticationState>(
      builder: (context, state) {
        String profileURL = '';
        String userName = '';
        String? userEmail = '';

        if (state is Authenticated) {
          profileURL = state.user?.profile ?? '';
          userName = state.user?.name ?? '';
          userEmail = state.user?.email;
        } else {
          profileURL = AppIcons.profilePlaceholder;
          userName = AppLabels.helloGuest.tr;
          userEmail = AppLabels.loginSignup.tr;
        }

        return GestureDetector(
          onTap: () {
            if (state is Authenticated) {
              Get.toNamed(AppRoutes.editProfileScreen);
            } else {
              Get.toNamed(AppRoutes.loginScreen);
            }
          },
          child: Container(
            padding: const .symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(color: context.color.primary),
            child: Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                ProfileCard(
                  iconSize: 78,
                  verticalSpace: 10,
                  space: 10,
                  titleStyle: TextStyle(
                    fontSize: context.font.medium,
                    fontWeight: .w400,
                    color: context.color.primary.getAdaptiveTextColor(),
                  ),
                  subtitleStyle: TextStyle(fontSize: context.font.small)
                      .copyWith(
                        color: context.color.primary.getAdaptiveTextColor(),
                      ),
                  profileDefaultIconColor: context.color.primary.brighten(0.5),
                ),
                CustomImage(
                  AppIcons.right,
                  supportsRTL: true,
                  color: context.color.primary.getAdaptiveTextColor(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSwitchToInstructor(BuildContext context) {
    return BlocBuilder<AuthenticationCubit, AuthenticationState>(
      builder: (context, state) {
        // Only show switch to instructor for authenticated users
        if (state is! Authenticated) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: () {
            final webUrl =
                context.read<AppSettingsCubit>().settings?.websiteURL ??
                AppSettings.webLink;
            launchUrl(Uri.parse('$webUrl/become-instructor'));
          },
          child: Container(
            margin: const .symmetric(horizontal: 16),
            padding: const .all(16),
            decoration: BoxDecoration(
              color: context.color.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: context.color.primary),
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: CustomImage(
                    AppIcons.switchInstructor,
                    width: 30,
                    height: 30,
                    color: context.color.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomText(
                    AppLabels.switchToInstructor.tr,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium!.copyWith(fontWeight: .w400),
                  ),
                ),
                CustomImage(
                  AppIcons.right,
                  supportsRTL: true,
                  color: context.color.onSurface,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingItem({
    required BuildContext context,
    required String icon,
    required String title,
    required VoidCallback onTap,
    Color? iconBackgroundColor,
    Color? iconColor,
    Color? textColor,
    Widget? trailing,
  }) {
    return CustomInkWell(
      onTap: onTap,
      color: Colors.transparent,
      child: Padding(
        padding: const .symmetric(vertical: 8, horizontal: 16),
        child: SizedBox(
          height: 46,
          child: Row(
            children: [
              Container(
                padding: const .all(7),
                decoration: BoxDecoration(
                  color:
                      iconBackgroundColor ??
                      context.color.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: CustomImage(
                  icon,
                  width: 16,
                  height: 16,
                  color: iconColor ?? context.color.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CustomText(
                  title,
                  style: TextStyle(
                    fontSize: context.font.medium,
                    fontWeight: .w400,
                    color: textColor ?? context.color.onSurface,
                  ),
                ),
              ),
              trailing ??
                  CustomImage(
                    AppIcons.right,
                    supportsRTL: true,
                    color: iconColor ?? context.color.onSurface,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return BlocBuilder<AuthenticationCubit, AuthenticationState>(
      builder: (context, authState) {
        final bool isAuthenticated = authState is Authenticated;
        final String? userType = isAuthenticated ? authState.user?.type : null;

        return CustomCard(
          margin: const .symmetric(horizontal: 16),
          padding: const .symmetric(vertical: 7),
          borderColor: Colors.transparent,
          child: Column(
            crossAxisAlignment: .start,
            children: [
              if (context.read<AppSettingsCubit>().isMultiInstructorMode)
                _buildSettingItem(
                  context: context,
                  icon: AppIcons.instructor,
                  title: AppLabels.instructors.tr,
                  onTap: () {
                    Get.toNamed(AppRoutes.exploreInstructorsScreen);
                  },
                ),
              if (isAuthenticated) ...{
                _buildSettingItem(
                  context: context,
                  icon: AppIcons.wishlist,
                  title: AppLabels.wishlist.tr,
                  onTap: () {
                    Get.toNamed(AppRoutes.wishlistScreen);
                  },
                ),
                _buildSettingItem(
                  context: context,
                  icon: AppIcons.transaction,
                  title: AppLabels.billingDetails.tr,
                  onTap: () {
                    Get.toNamed(AppRoutes.billingDetailsScreen);
                  },
                ),
                _buildSettingItem(
                  context: context,
                  icon: AppIcons.transaction,
                  title: AppLabels.purchaseHistory.tr,
                  onTap: () {
                    Get.toNamed(AppRoutes.purchaseHistoryScreen);
                  },
                ),
                _buildSettingItem(
                  context: context,
                  icon: AppIcons.wallet,
                  title: AppLabels.wallet.tr,
                  onTap: () {
                    Get.toNamed(AppRoutes.walletScreen);
                  },
                ),
                _buildSettingItem(
                  context: context,
                  icon: AppIcons.notificationFilled,
                  title: AppLabels.notification.tr,
                  onTap: () {
                    Get.toNamed(AppRoutes.notificationScreen);
                  },
                ),
              },
              _buildSettingItem(
                context: context,
                icon: AppIcons.language,
                title: AppLabels.language.tr,
                onTap: () {
                  Get.toNamed(AppRoutes.languageScreen);
                },
              ),
              _buildSettingItem(
                context: context,
                icon: AppIcons.theme,
                title: AppLabels.theme.tr,
                onTap: () {
                  UiUtils.showCustomBottomSheet(
                    context,
                    child: const ThemeBottomSheet(),
                  );
                },
              ),
              // Only show Account Security if login type is not social media
              if (isAuthenticated &&
                  userType != 'google' &&
                  userType != 'apple')
                _buildSettingItem(
                  context: context,
                  icon: AppIcons.security,
                  title: AppLabels.accountSecurity.tr,
                  onTap: () {
                    UiUtils.showCustomBottomSheet(
                      context,
                      child: const AccountSecurityBottomSheet(),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMoreSettingsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Padding(
          padding: const .symmetric(horizontal: 16),
          child: Row(
            children: [
              CustomText(
                AppLabels.moreSetting.tr,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium!.copyWith(fontWeight: .w500),
              ),
              if (_patternController != null)
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PatternGesture(
                        height: 30,
                        width: 30,
                        boxKey: 1,
                        controller: _patternController!,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        CustomCard(
          padding: const .symmetric(vertical: 7),
          margin: const .symmetric(horizontal: 16),
          borderColor: Colors.transparent,
          child: Column(
            children: [
              _buildSettingItem(
                context: context,
                icon: AppIcons.help,
                title: AppLabels.helpCenter.tr,
                onTap: () {
                  Get.toNamed(AppRoutes.helpSupportScreen);
                },
              ),

              _buildSettingItem(
                context: context,
                icon: AppIcons.terms,
                title: AppLabels.termAndCondition.tr,
                onTap: () {
                  Get.toNamed(
                    AppRoutes.policyScreen,
                    arguments: {'policyType': PolicyType.termsAndConditions},
                  );
                },
              ),
              _buildSettingItem(
                context: context,
                icon: AppIcons.privacy,
                title: AppLabels.privacyPolicy.tr,
                onTap: () {
                  Get.toNamed(
                    AppRoutes.policyScreen,
                    arguments: {'policyType': PolicyType.privacyPolicy},
                  );
                },
              ),
              _buildSettingItem(
                context: context,
                icon: AppIcons.refundPolicy,
                title: AppLabels.refundPolicy.tr,
                onTap: () {
                  Get.toNamed(
                    AppRoutes.policyScreen,
                    arguments: {'policyType': PolicyType.refundPolicy},
                  );
                },
              ),
              _buildSettingItem(
                context: context,
                icon: AppIcons.contact,
                title: AppLabels.contactUs.tr,
                onTap: () {
                  Get.toNamed(AppRoutes.contactUsScreen);
                },
              ),
              _buildSettingItem(
                context: context,
                icon: AppIcons.shareSolid,
                title: AppLabels.shareApp.tr,
                onTap: _onTapShareApp,
              ),
              _buildSettingItem(
                context: context,
                icon: AppIcons.rating,
                title: AppLabels.rating.tr,
                onTap: _onTapRating,
              ),
              BlocBuilder<AuthenticationCubit, AuthenticationState>(
                builder: (context, authState) {
                  if (authState is! Authenticated) {
                    return const SizedBox.shrink();
                  }

                  return _buildSettingItem(
                    context: context,
                    icon: AppIcons.delete,
                    title: AppLabels.deleteAccount.tr,
                    onTap: () {
                      ///In demo mode account deletion is disabled.
                      if (AppConstant.kIsDemoMode) {
                        UiUtils.showSnackBar(
                          AppLabels.demoModeRestriction.tr,
                          isError: true,
                        );
                        return;
                      }
                      UiUtils.showDialog(
                        context,
                        child: BlocProvider(
                          create: (context) =>
                              DeleteAccountCubit(AuthRepository()),
                          child: const DeleteAccountDialog(),
                        ),
                      );
                    },
                    iconBackgroundColor: context.color.error.withValues(
                      alpha: 0.1,
                    ),
                    iconColor: context.color.error,
                    textColor: context.color.error,
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: CustomAppBar(
        customTitle: Row(
          children: [
            CustomText(
              AppLabels.profile.tr,
              style: TextStyle(fontSize: context.font.xxLarge),
              softWrap: true,
              ellipsis: true,
              maxLines: 1,
            ),
            if (_patternController != null)
              PatternGesture(
                height: double.infinity,
                width: 30,
                boxKey: 2,
                controller: _patternController!,
              ),
          ],
        ),
        actions: [
          BlocBuilder<AuthenticationCubit, AuthenticationState>(
            builder: (context, authState) {
              if (authState is! Authenticated) {
                return const SizedBox.shrink();
              }

              return GestureDetector(
                onTap: () {
                  UiUtils.showDialog(context, child: const LogoutDialog());
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: context.color.outline),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: CustomImage(
                    AppIcons.logout,
                    supportsRTL: true,
                    color: context.color.onSurface,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<AuthenticationCubit, AuthenticationState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: EdgeInsetsDirectional.only(
              bottom: 7 + context.cartBottomInset,
            ),
            child: Column(
              crossAxisAlignment: .start,
              spacing: 20,
              children: [
                _buildProfileHeader(context),
                if (state is Authenticated &&
                    context.read<AppSettingsCubit>().isMultiInstructorMode)
                  _buildSwitchToInstructor(context),
                _buildSettingsSection(context),
                _buildMoreSettingsSection(context),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
