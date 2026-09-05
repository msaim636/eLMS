import 'package:elms/common/enums.dart';
import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/features/course/models/resource_data_model.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/file_download_helper.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourceTile extends StatelessWidget {
  final ResourceModel resource;
  final bool showCard;
  final int? index;

  const ResourceTile({
    super.key,
    required this.resource,
    this.showCard = false,
    this.index,
  });

  Future<void> _onTapResource() async {
    if (resource.type == ResourceType.download) {
      final fileUrl = resource.fileUrl;
      if (fileUrl != null && fileUrl.isNotEmpty) {
        await FileDownloadHelper.downloadOrOpenFile(
          fileUrl,
          fileName: resource.fileName,
        );
      }
    } else if (resource.type == ResourceType.externalLink) {
      final externalUrl = resource.externalUrl;
      if (externalUrl != null && externalUrl.isNotEmpty) {
        final uri = Uri.parse(externalUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Row content = Row(
      spacing: 10,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: context.color.info.withValues(alpha: 0.18),
          ),
          child: CustomImage(
            resource.type == ResourceType.download
                ? AppIcons.documentDownload
                : AppIcons.link,
            width: 14,
            height: 14,
            fit: .none,
            color: context.color.info,
          ),
        ),
        Expanded(
          child: CustomText(
            index != null
                ? '${index! + 1}. ${resource.getTitle}'
                : resource.getTitle,
            style: TextStyle(fontSize: context.font.small),
          ),
        ),
      ],
    );

    final Widget child = showCard
        ? CustomCard(padding: const .all(10), child: content)
        : content;

    return GestureDetector(onTap: _onTapResource, child: child);
  }
}
