import 'dart:io';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/ui_utils.dart';
import 'package:flutter/material.dart';

class ProfileImageWidget extends StatefulWidget {
  final String image;
  final Function(File) onSelected;
  const ProfileImageWidget({
    super.key,
    required this.image,
    required this.onSelected,
  });

  @override
  State<ProfileImageWidget> createState() => _ProfileImageWidgetState();
}

class _ProfileImageWidgetState extends State<ProfileImageWidget> {
  String? path;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 125,
      height: 125,
      child: Stack(
        fit: .expand,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: .circle,
              border: Border.all(color: context.color.primary),
            ),
            child: Padding(
              padding: const .all(10),
              child: CustomImage.circular(imageUrl: path ?? widget.image),
            ),
          ),
          Align(
            alignment: .bottomRight,
            child: GestureDetector(
              onTap: () {
                UiUtils.showImagePickerSheet((image) {
                  path = image.path;
                  widget.onSelected(image);
                  setState(() {});
                });
              },
              child: Container(
                width: 37,
                height: 37,
                alignment: .center,
                padding: const .all(8),
                decoration: BoxDecoration(
                  shape: .circle,
                  color: context.color.primary,
                  border: Border.all(color: context.color.onPrimary, width: 2),
                ),
                child: CustomImage(
                  AppIcons.edit2,
                  color: context.color.onPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
