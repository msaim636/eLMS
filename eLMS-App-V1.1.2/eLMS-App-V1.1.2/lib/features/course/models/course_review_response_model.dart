import 'package:elms/common/models/blueprints.dart';
import 'package:elms/common/models/review_model.dart';
import 'package:elms/common/models/user_review_model.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';

class CourseReviewResponseModel extends Model {
  final CourseInfo course;
  final ReviewModel statistics;
  final MyReviewModel? myReview;

  CourseReviewResponseModel({
    required this.course,
    required this.statistics,
    this.myReview,
  });

  factory CourseReviewResponseModel.fromMap(Map<String, dynamic> map) {
    return CourseReviewResponseModel(
      course: CourseInfo.fromMap(map.require<Map<String, dynamic>>('course')),
      statistics: ReviewModel.fromMap(
        map.require<Map<String, dynamic>>('statistics'),
      ),
      myReview: map.optional<Map<String, dynamic>?>('my_review') != null
          ? MyReviewModel.fromMap(
              map.require<Map<String, dynamic>>('my_review'),
            )
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'course': course.toJson(),
      'statistics': statistics.toJson(),
      'my_review': myReview?.toJson(),
    };
  }
}

class CourseInfo extends Model {
  final int id;
  final String title;
  final String slug;

  CourseInfo({required this.id, required this.title, required this.slug});

  factory CourseInfo.fromMap(Map<String, dynamic> map) {
    return CourseInfo(
      id: map.require<int>('id'),
      title: map.require<String>('title'),
      slug: map.require<String>('slug'),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'slug': slug};
  }
}
