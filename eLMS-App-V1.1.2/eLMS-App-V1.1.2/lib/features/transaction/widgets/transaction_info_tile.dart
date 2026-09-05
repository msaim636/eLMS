import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';

class TransactionInfoTile extends StatelessWidget {
  final String title;
  final String value;
  const TransactionInfoTile({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        CustomText(
          '$title:',
          style: Theme.of(
            context,
          ).textTheme.titleMedium!.copyWith(fontWeight: .w600),
        ),
        CustomText(
          value,
          style: TextStyle(
            fontSize: context.font.small,
            color: context.color.textSecondary,
          ),
        ),
      ],
    );
  }
}
