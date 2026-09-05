import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:elms/common/enums.dart' as elms;
import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_dialog_box.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/common/widgets/custom_text_form_field.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/services/refresh_notifier.dart';
import 'package:elms/features/course/cubit/assignment_cubit.dart';
import 'package:elms/features/course/repository/course_repository.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/ui_utils.dart';
import 'package:elms/utils/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class UploadAssignmentDialog extends StatefulWidget {
  final int assignmentId;
  final int chapterId;
  final int courseId;
  final List<String> allowedFileTypes;

  const UploadAssignmentDialog({
    super.key,
    required this.assignmentId,
    required this.chapterId,
    required this.courseId,
    this.allowedFileTypes = const [],
  });

  @override
  State<UploadAssignmentDialog> createState() => _UploadAssignmentDialogState();
}

class _UploadAssignmentDialogState extends State<UploadAssignmentDialog> {
  final TextEditingController _commentController = TextEditingController();
  List<PlatformFile>? _selectedFiles;
  bool _isUploading = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _onTapChooseFile() async {
    try {
      final List<String> allowedExtensions = _getAllowedExtensions();
      final bool isIOS = Platform.isIOS;

      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
      );

      if (result != null && result.files.isNotEmpty) {
        if (isIOS && allowedExtensions.isNotEmpty) {
          final bool hasInvalidFile = result.files.any((file) {
            final String extension =
                file.extension?.toLowerCase() ??
                (file.name.contains('.')
                    ? file.name.split('.').last.toLowerCase()
                    : '');
            return !allowedExtensions.contains(extension);
          });

          if (hasInvalidFile) {
            Future.delayed(const Duration(milliseconds: 300), () {
              UiUtils.showSnackBar(
                'The file is not supported. Supported file types are: ${allowedExtensions.join(", ")}',
                isError: true,
              );
            });
            return;
          }
        }

        setState(() {
          _selectedFiles = result.files;
        });
      }
    } catch (e) {
      UiUtils.showSnackBar('Error picking files: $e', isError: true);
    }
  }

  List<String> _getAllowedExtensions() {
    final List<String> extensions = [];

    for (final type in widget.allowedFileTypes) {
      final fileTypeEnum = _parseFileType(type);
      if (fileTypeEnum != null) {
        extensions.addAll(fileTypeEnum.extensions);
      } else {
        // Handle raw extensions or comma-separated extensions (e.g., "pdf", ".doc", "doc,docx")
        final List<String> parts = type.split(',');
        for (var part in parts) {
          final cleaned = part.replaceAll('.', '').trim().toLowerCase();
          if (cleaned.isNotEmpty) {
            extensions.add(cleaned);
          }
        }
      }
    }

    return extensions.toSet().toList(); // Remove duplicates
  }

  elms.FileType? _parseFileType(String type) {
    return elms.FileType.fromString(type);
  }

  Future<void> _markCurriculumCompleted() async {
    try {
      await CourseRepository().markCurriculumCompleted(
        chapterId: widget.chapterId,
        modelId: widget.assignmentId,
        modelType: 'assignment',
      );
      RefreshNotifier.instance.markMyLearningForRefresh();
    } catch (_) {
      // Silently ignore — curriculum completion is best-effort
    }
  }

  void _onTapUpload() {
    if (_selectedFiles == null || _selectedFiles!.isEmpty) {
      UiUtils.showSnackBar('Please select at least one file', isError: true);
      return;
    }

    if (_commentController.text.trim().isEmpty) {
      UiUtils.showSnackBar('Please enter a comment', isError: true);
      return;
    }

    final List<String> filePaths = _selectedFiles!
        .map((file) => file.path ?? '')
        .where((path) => path.isNotEmpty)
        .toList();

    if (filePaths.isEmpty) {
      UiUtils.showSnackBar('No valid file paths found', isError: true);
      return;
    }

    setState(() {
      _isUploading = true;
    });

    context.read<AssignmentCubit>().submitAssignment(
      assignmentId: widget.assignmentId,
      files: filePaths,
      comment: _commentController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AssignmentCubit, AssignmentState>(
      listener: (context, state) {
        if (state is AssignmentSubmissionSuccess) {
          setState(() {
            _isUploading = false;
          });
          UiUtils.showSnackBar(state.message);
          Navigator.of(context).pop();
          context.read<AssignmentCubit>().fetchAssignments(
            widget.courseId,
            chapterId: widget.chapterId,
          );
          _markCurriculumCompleted();
        } else if (state is AssignmentSubmissionError) {
          setState(() {
            _isUploading = false;
          });
          UiUtils.showSnackBar(state.error, isError: true);
        }
      },
      child: CustomDialogBox(
        actions: [
          DialogButton(
            title: _isUploading ? AppLabels.uploading.tr : AppLabels.upload.tr,
            style: elms.DialogButtonStyle.primary,
            onTap:
                (!_isUploading &&
                    _selectedFiles != null &&
                    _selectedFiles!.isNotEmpty)
                ? _onTapUpload
                : null,
          ),
        ],
        title: AppLabels.uploadAssignment.tr,
        content: Column(
          spacing: 20,
          mainAxisSize: .min,
          children: [
            CustomTextFormField(
              controller: _commentController,
              title: AppLabels.assignmentTitle.tr,
              hintText: AppLabels.text.tr,
              fillColor: context.color.outline.withValues(alpha: 0.17),
              requiredErrorMessage: AppLabels.fieldRequired.tr,
            ),
            GestureDetector(
              onTap: _onTapChooseFile,
              child: DottedBorder(
                strokeWidth: 2,
                borderType: BorderType.RRect,
                dashPattern: const [6, 5],
                color: context.color.outline,
                child: SizedBox(
                  width: context.screenWidth,
                  child: Padding(
                    padding: const .symmetric(vertical: 32, horizontal: 16),
                    child: Column(
                      spacing: 16,
                      children: [
                        CustomCard(
                          color: context.color.outline.withValues(alpha: 0.17),
                          border: 0,
                          padding: const .all(8),
                          child: CustomImage(
                            AppIcons.documentUpload,
                            color: context.color.textSecondary,
                          ),
                        ),
                        if (_selectedFiles == null || _selectedFiles!.isEmpty)
                          CustomText(
                            AppLabels.chooseFileToUpload.tr,
                            style: TextStyle(fontSize: context.font.medium),
                          )
                        else
                          Column(
                            spacing: 8,
                            children: [
                              CustomText(
                                AppLabels.filesSelected.tr.replaceAll(
                                  '{{files}}',
                                  Utils.pluralize(
                                    _selectedFiles!.length,
                                    singular: AppLabels.file,
                                    plural: AppLabels.files,
                                  ),
                                ),
                                style: TextStyle(fontSize: context.font.medium),
                              ),
                              ..._selectedFiles!.map(
                                (file) => CustomText(
                                  file.name,
                                  style: TextStyle(
                                    fontSize: context.font.xSmall,
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
