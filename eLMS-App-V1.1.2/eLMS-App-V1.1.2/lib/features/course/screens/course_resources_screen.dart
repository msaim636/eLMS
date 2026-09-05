import 'package:elms/common/widgets/custom_app_bar.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/features/course/cubit/resource_cubit.dart';
import 'package:elms/features/course/repository/resource_repository.dart';
import 'package:elms/features/course/widgets/all_resources_section.dart';
import 'package:elms/features/course/widgets/current_lecture_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class CourseResourcesScreen extends StatefulWidget {
  final int id;
  const CourseResourcesScreen({super.key, required this.id});
  static Widget route([RouteSettings? settings]) {
    final Map arguments = (settings?.arguments ?? Get.arguments) as Map;
    return BlocProvider(
      create: (context) =>
          ResourceCubit(ResourceRepository())
            ..fetchResources(courseId: arguments['course_id'], lectureId: arguments['lecture_id']),
      child: CourseResourcesScreen(id: arguments['course_id']),
    );
  }

  @override
  State<CourseResourcesScreen> createState() => _CourseResourcesScreenState();
}

class _CourseResourcesScreenState extends State<CourseResourcesScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: CustomAppBar(
          showBackButton: true,
          title: AppLabels.resources.tr,
        ),
        body: Padding(
          padding: const .symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              _buildTabBar(),
              const Expanded(
                child: TabBarView(
                  children: [AllResources(), CurrentLectureSection()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      dividerHeight: 1,
      indicatorSize: .tab,
      indicatorAnimation: .linear,
      tabAlignment: .start,
      tabs: [
        Tab(text: AppLabels.allResources.tr),
        Tab(text: AppLabels.currentLectureResources.tr),
      ],
      isScrollable: true,
      automaticIndicatorColorAdjustment: false,
      dividerColor: Colors.grey.shade300,
    );
  }
}
