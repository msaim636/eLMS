import 'package:elms/common/models/message_model.dart';
import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/features/course/features/discussion/widgets/user_profile_tile.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';

class MessageCard extends StatelessWidget {
  final Message message;
  final bool useCard;
  const MessageCard({super.key, required this.message, this.useCard = false});

  @override
  Widget build(BuildContext context) {
    final Column content = Column(
      crossAxisAlignment: .start,
      children: [
        UserProfileTile(message: message),
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 52, top: 8),
          child: CustomText(
            message.content,
            style: TextStyle(fontSize: context.font.small),
          ),
        ),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: CustomText(
            message.timesAgo,
            style: TextStyle(
              fontSize: context.font.xSmall,
              fontWeight: .w400,
              color: context.color.textSecondary,
            ),
          ),
        ),
      ],
    );

    if (useCard) {
      return CustomCard(padding: const .all(8), border: 0, child: content);
    }
    return content;
  }
}
