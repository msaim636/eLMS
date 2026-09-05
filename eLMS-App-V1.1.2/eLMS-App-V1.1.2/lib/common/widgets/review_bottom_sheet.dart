import 'package:elms/common/cubits/review_cubit.dart';
import 'package:elms/common/enums.dart';
import 'package:elms/common/models/blueprints.dart';
import 'package:elms/common/widgets/custom_button.dart';
import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/common/widgets/custom_text_form_field.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class ReviewBottomSheet extends StatefulWidget {
  final ReviewType type;
  final int id;
  final int? initialRating;
  final String? initialReview;

  const ReviewBottomSheet({
    super.key,
    required this.type,
    required this.id,
    this.initialRating,
    this.initialReview,
  });

  @override
  State<ReviewBottomSheet> createState() => _ReviewBottomSheetState();
}

class _ReviewBottomSheetState extends State<ReviewBottomSheet> {
  late final ValueNotifier<int> _starSelection;
  late final TextEditingController _reviewController;

  @override
  void initState() {
    super.initState();
    _starSelection = ValueNotifier<int>(widget.initialRating ?? 0);
    _reviewController = TextEditingController(text: widget.initialReview);
  }

  @override
  void dispose() {
    _starSelection.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  void _onTapSubmitButton(BuildContext context) {
    if (_starSelection.value == 0) {
      UiUtils.showSnackBar(AppLabels.pleaseSelectRating.tr, isError: true);
      return;
    }

    if (_reviewController.text.trim().isEmpty) {
      UiUtils.showSnackBar(AppLabels.pleaseWriteReview.tr, isError: true);
      return;
    }

    context.read<ReviewCubit>().submitReview(
      rating: _starSelection.value,
      review: _reviewController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReviewCubit(type: widget.type, id: widget.id),
      child: BlocListener<ReviewCubit, BaseState>(
        listener: (context, state) {
          if (state is ReviewSubmitSuccess) {
            Navigator.pop(context, {
              'rating': _starSelection.value,
              'review': _reviewController.text.trim(),
            });
            final message = widget.initialReview != null
                ? AppLabels.updatedSuccessfully.tr
                : AppLabels.reviewSubmittedSuccessfully.tr;
            UiUtils.showSnackBar(message);
          }
          if (state is ReviewSubmitFail) {
            UiUtils.showSnackBar(state.error, isError: true);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .start,
            children: [
              CustomText(
                widget.initialReview != null
                    ? AppLabels.editReview.tr
                    : widget.type == ReviewType.instructor
                        ? AppLabels.yourReviewMatters.tr
                        : AppLabels.addReview.tr,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium!.copyWith(fontWeight: .w600),
              ),
              CustomText(
                widget.type == ReviewType.instructor
                    ? AppLabels.helpShapeInstructorReview.tr
                    : AppLabels.shareYourFeedback.tr,
                style: TextStyle(fontSize: context.font.medium),
              ),
              _buildRateBar(context),
              CustomTextFormField(
                controller: _reviewController,
                hintText: AppLabels.writeHere.tr,
                title: AppLabels.yourFeedback.tr,
                minLines: 5,
                isMultiline: true,
                fillColor: context.color.outline.withValues(alpha: 0.2),
                requiredErrorMessage: AppLabels.feedbackRequired.tr,
              ),
              const SizedBox(height: 30),
              BlocBuilder<ReviewCubit, BaseState>(
                builder: (context, state) {
                  return CustomButton(
                    title: widget.initialReview != null
                        ? AppLabels.editReview.tr
                        : AppLabels.submitReview.tr,
                    fullWidth: true,
                    isLoading: state is ReviewInProgress,
                    onPressed: () => _onTapSubmitButton(context),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRateBar(BuildContext context) {
    return Padding(
      padding: const .symmetric(vertical: 16),
      child: ValueListenableBuilder<int>(
        valueListenable: _starSelection,
        builder: (context, value, child) {
          return Row(
            spacing: 8,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () {
                  _starSelection.value = index + 1;
                },
                child: CustomCard(
                  borderRadius: 4,
                  padding: const .all(8),
                  child: CustomImage(
                    AppIcons.starFilled,
                    height: 24,
                    width: 24,
                    color: value >= index + 1
                        ? context.color.warning
                        : context.color.outline,
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
