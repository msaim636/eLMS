import 'package:elms/common/models/message_model.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/common/widgets/tappable_image.dart';
import 'package:flutter/material.dart';
import 'package:elms/utils/extensions/context_extension.dart';

class UserProfileTile extends StatelessWidget {
  final MessageModel message;
  const UserProfileTile({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return _buildProfileTile(
      context: context,
      profile: message.profile,
      name: message.userName,
      subtitle: message.userSubtitle,
      messageId: message.id,
    );
  }

  Widget _buildNameAndSubtitle({
    required BuildContext context,
    required String name,
    String? subtitle,
  }) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        CustomText(
          name,
          fontSize: context.font.medium,
          fontWeight: .w500,
          maxLines: 1,
          ellipsis: true,
        ),
        if (subtitle != null)
          CustomText(
            subtitle,
            style: TextStyle(
              fontSize: context.font.xSmall,
              fontWeight: FontWeight.w400,
            ),
          ),
      ],
    );
  }

  Widget _buildAvatar({required String profile, required String messageId}) {
    return TappableImage.circular(imageUrl: profile, width: 42, height: 42);
  }

  Widget _buildProfileTile({
    required BuildContext context,
    required String profile,
    required String name,
    required String messageId,
    String? subtitle,
  }) {
    return Row(
      spacing: 12,
      children: [
        _buildAvatar(profile: profile, messageId: messageId),
        Expanded(
          child: _buildNameAndSubtitle(
            context: context,
            name: name,
            subtitle: subtitle,
          ),
        ),
      ],
    );
  }
}
