import 'package:elms/common/models/course_details_model.dart';
import 'package:elms/common/models/course_model.dart';
import 'package:elms/common/widgets/custom_app_bar.dart';
import 'package:elms/common/widgets/custom_button.dart';
import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/routes/route_params.dart';
import 'package:elms/features/course/cubit/course_details_cubit.dart';
import 'package:elms/features/course/repository/course_repository.dart';
import 'package:elms/features/course/widgets/course_overview_widget.dart';
import 'package:elms/features/course/widgets/instructor_card_widget.dart';
import 'package:elms/features/settings/cubit/app_settings_cubit.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:elms/utils/extensions/context_extension.dart';

class AboutCourseScreen extends StatefulWidget {
  final CourseModel course;
  final CourseDetailsModel? courseDetails;

  const AboutCourseScreen({
    super.key,
    required this.course,
    this.courseDetails,
  });

  static Widget route([RouteSettings? settings]) {
    final CourseDetailsScreenArguments? args =
        (settings?.arguments ?? Get.arguments) as CourseDetailsScreenArguments?;
    if (args == null) {
      throw Exception(
        'CourseDetailsScreenArguments required for AboutCourseScreen',
      );
    }
    return BlocProvider(
      create: (context) => CourseDetailsCubit(CourseRepository()),
      child: AboutCourseScreen(
        course: args.course,
        courseDetails: args.course is CourseDetailsModel
            ? args.course as CourseDetailsModel
            : null,
      ),
    );
  }

  @override
  State<AboutCourseScreen> createState() => _AboutCourseScreenState();
}

class _AboutCourseScreenState extends State<AboutCourseScreen> {
  @override
  void initState() {
    super.initState();

    if (widget.courseDetails != null) {
      context.read<CourseDetailsCubit>().setInitialData(widget.courseDetails!);
    } else {
      context.read<CourseDetailsCubit>().fetchCourseDetails(widget.course);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        showBackButton: true,
        title: AppLabels.aboutCourse.tr,
      ),
      body: BlocBuilder<CourseDetailsCubit, CourseDetailsState>(
        builder: (context, state) {
          if (state is CourseDetailsProgress) {
            return _buildContent(
              state.initialData ??
                  CourseDetailsModel.fromCourseModel(widget.course),
              isLoading: true,
            );
          }

          if (state is CourseDetailsSuccess) {
            return _buildContent(state.data);
          }

          if (state is CourseDetailsError) {
            return _buildErrorWidget();
          }

          return _buildContent(
            CourseDetailsModel.fromCourseModel(widget.course),
          );
        },
      ),
    );
  }

  Widget _buildContent(
    CourseDetailsModel courseDetails, {
    bool isLoading = false,
  }) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 16 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        spacing: 12,
        children: [
          _buildCourseDetails(courseDetails),
          if (context.read<AppSettingsCubit>().isMultiInstructorMode) ...{
            if (courseDetails.instructor != null &&
                courseDetails.instructor?.name != "admin")
              InstructorCardWidget(
                instructor: courseDetails.instructor!.toInstructorModel(),
              ),

            if (courseDetails.instructor?.name == "admin")
              CustomCard(
                padding: const EdgeInsetsGeometry.all(16),
                width: double.maxFinite,
                child: CustomText(
                  AppLabels.addedByAdmin.tr,
                  style: TextStyle(fontSize: context.font.small),
                ),
              ),
          },

          if (isLoading)
            const Padding(
              padding: .all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: .center,
        children: [
          const Icon(Icons.error_outline, size: 64),
          const SizedBox(height: 16),
          CustomText(
            AppLabels.somethingWentWrong.tr,
            style: TextStyle(
              fontSize: context.font.medium,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          CustomButton(
            title: AppLabels.retry.tr,
            onPressed: () {
              context.read<CourseDetailsCubit>().fetchCourseDetails(
                widget.course,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCourseDetails(CourseDetailsModel courseDetails) {
    final int hours = ((courseDetails.totalDuration / 60) / 60).toInt();
    final Map<String, String> courseDetailsMap = {
      if (courseDetails.totalDuration > 0)
        'duration': hours.toString().getDurationLabel,
      'chapters': (courseDetails.chapterCount > 1)
          ? AppLabels.courseChaptersCount.translateWithTemplate({
              'count': courseDetails.chapterCount.toString(),
            })
          : AppLabels.courseChapterCount.translateWithTemplate({
              'count': courseDetails.chapterCount.toString(),
            }),
      'lectures': (courseDetails.lectureCount > 1)
          ? AppLabels.courseLecturesCount.translateWithTemplate({
              'count': courseDetails.lectureCount.toString(),
            })
          : AppLabels.courseLectureCount.translateWithTemplate({
              'count': courseDetails.lectureCount.toString(),
            }),
      'rating': AppLabels.courseRating.translateWithTemplate({
        'rating': courseDetails.averageRating.ratingLabel,
        'count': courseDetails.ratings.toString(),
      }),
      'language': courseDetails.language.isNotEmpty
          ? AppLabels.courseTaughtIn.translateWithTemplate({
              'language': courseDetails.language,
            })
          : AppLabels.courseLanguage.tr,
      'access': courseDetails.level.isNotEmpty
          ? courseDetails.level.capitalize ?? ''
          : AppLabels.courseLevelAdvanced.tr,
    };

    final String overview =
        courseDetails.description ?? courseDetails.shortDescription;

    final List<String> learningPoints = courseDetails.learnings
        .map((learning) => learning.title)
        .toList();

    final List<String> requirements = courseDetails.requirements
        .map((requirement) => requirement.requirement)
        .toList();

    return CourseOverviewWidget(
      level: courseDetails.level.isNotEmpty
          ? courseDetails.level
          : AppLabels.courseLevelAdvanced.tr,
      isFree: courseDetails.isFree,
      category: courseDetails.categoryName ?? '',
      currentPrice: courseDetails.subtotal,
      originalPrice: courseDetails.originalPrice,
      title: courseDetails.title,
      courseDetails: courseDetailsMap,
      overview: overview,
      learningPoints: learningPoints,
      requirements: requirements,
    );
  }
}
