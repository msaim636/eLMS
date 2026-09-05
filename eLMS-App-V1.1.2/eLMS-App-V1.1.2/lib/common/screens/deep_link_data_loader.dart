import 'package:elms/common/models/course_details_model.dart';
import 'package:elms/features/course/repository/course_repository.dart';
import 'package:elms/utils/course_navigation_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeepLinkDataLoader extends StatefulWidget {
  final String target;
  final Map<String, dynamic> params;
  const DeepLinkDataLoader({
    super.key,
    required this.target,
    required this.params,
  });
  Widget route() {
    final Map<dynamic, dynamic> arguments = Get.arguments as Map;
    return DeepLinkDataLoader(
      target: arguments['target'],
      params: arguments['params'],
    );
  }

  @override
  State<DeepLinkDataLoader> createState() => _DeepLinkDataLoaderState();
}

class _DeepLinkDataLoaderState extends State<DeepLinkDataLoader> {
  bool isLoading = true;

  Future<void> _loadDeepLinkData(
    String target,
    Map<String, dynamic> params,
  ) async {
    if (target == 'course-details') {
      final CourseRepository repository = CourseRepository();
      final CourseDetailsModel courseDetailsModel = await repository
          .fetchCourseDetails(slug: params['slug']);
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Get.back();
        CourseNavigationHelper.navigateToCourse(
          courseDetailsModel,
          context: context,
        );
      });

      if (mounted) {
        isLoading = false;

        setState(() {});
      }
    }
  }

  @override
  void initState() {
    _loadDeepLinkData(widget.target, widget.params);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Container();
  }
}
