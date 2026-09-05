import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/features/instructor/models/instructor_details_model.dart';
import 'package:flutter/material.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:url_launcher/url_launcher.dart';

class InstructorSocialMedia extends StatelessWidget {
  final List<InstructorSocialMediaModel> socialMedias;

  const InstructorSocialMedia({super.key, required this.socialMedias});

  @override
  Widget build(BuildContext context) {
    // Filter to only show supported platforms with available icons
    final supportedSocialMedias = socialMedias
        .where(
          (socialMedia) =>
              socialMedia.isSupported && socialMedia.iconPath != null,
        )
        .toList();

    if (supportedSocialMedias.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      runSpacing: 5,

      children: supportedSocialMedias.map((socialMedia) {
        return _buildSocialMediaIcon(
          context,
          socialMedia.iconPath!,
          socialMedia.url,
        );
      }).toList(),
    );
  }

  Widget _buildSocialMediaIcon(
    BuildContext context,
    String iconPath,
    String url,
  ) {
    return GestureDetector(
      onTap: () => _launchUrl(url),
      child: Container(
        margin: const .only(right: 10),
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: context.color.onSurface,
          shape: .circle,
        ),
        child: Center(
          child: CustomImage(
            iconPath,
            width: 16,
            height: 16,
            color: context.color.surface,
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
