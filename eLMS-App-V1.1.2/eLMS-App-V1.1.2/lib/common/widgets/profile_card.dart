import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/common/widgets/tappable_image.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/routes/routes.dart';
import 'package:elms/features/authentication/cubit/authentication_cubit.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class ProfileCard extends StatelessWidget {
  final double? iconSize;
  final double? space;
  final double? verticalSpace;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final Color? profileDefaultIconColor;

  const ProfileCard({
    super.key,
    this.iconSize,
    this.space,
    this.verticalSpace,
    this.titleStyle,
    this.subtitleStyle,
    this.profileDefaultIconColor,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationCubit, AuthenticationState>(
      builder: (context, state) {
        String? profileURL = '', title = '', subtitle = '';

        if (state is Authenticated) {
          profileURL = state.user?.profile ?? '';
          title = state.user?.name ?? '';
          subtitle = state.user?.email;
        } else {
          profileURL = AppIcons.profilePlaceholder;
          title = AppLabels.helloGuest.tr;
          subtitle = AppLabels.loginSignup.tr;
        }

        return GestureDetector(
          onTap: () {
            if (state is! Authenticated) {
              Get.toNamed(AppRoutes.loginScreen);
            }
          },
          child: Row(
            mainAxisSize: .min,
            children: [
              if (state is Authenticated)
                TappableImage.circular(
                  imageUrl: profileURL,
                  width: iconSize ?? 56,
                  height: iconSize ?? 56,
                )
              else
                CustomImage.circular(
                  imageUrl: profileURL,
                  width: iconSize ?? 56,
                  height: iconSize ?? 56,
                  color: profileDefaultIconColor ?? context.color.primary,
                ),
              Flexible(
                child: Padding(
                  padding: .symmetric(horizontal: space ?? 7),
                  child: Column(
                    mainAxisSize: .min,
                    crossAxisAlignment: .start,
                    children: [
                      CustomText(
                        title,
                        style:
                            titleStyle ??
                            TextStyle(
                              fontSize: context.font.small,
                              fontWeight: .w500,
                              color: context.color.onSurface,
                            ),
                        maxLines: 1,
                        ellipsis: true,
                      ),
                      if (subtitle != null) ...{
                        SizedBox(height: verticalSpace ?? 4),
                        CustomText(
                          subtitle,
                          style:
                              subtitleStyle ??
                              TextStyle(
                                fontSize: context.font.xSmall,
                                color: context.color.onSurface,
                                fontWeight: .w400,
                              ),
                          maxLines: 1,
                          ellipsis: true,
                        ),
                      },
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
