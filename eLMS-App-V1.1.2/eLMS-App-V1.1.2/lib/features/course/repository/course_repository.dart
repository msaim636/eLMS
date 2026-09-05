import 'dart:io';

import 'package:elms/common/models/blueprints.dart';
import 'package:elms/common/models/course_model.dart';
import 'package:elms/common/models/course_details_model.dart';
import 'package:elms/common/models/data_class.dart';
import 'package:elms/core/api/api_client.dart';
import 'package:elms/core/api/api_params.dart';
import 'package:elms/features/course/models/course_completion_model.dart';
import 'package:elms/features/course/models/purchase_certificate_response_model.dart';
import 'package:elms/features/home/models/featured_section_model.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';
import 'package:path_provider/path_provider.dart';

extension type CourseParams(Map<String, dynamic> params) {}

class CourseRepository extends ICourseRepository {
  @override
  Future<PaginatedDataClass<CourseModel>> fetch({
    int? page,
    int? perPage,
    String? slug,
    CourseParams? extraParams,
  }) async {
    try {
      final Map<String, dynamic> parameters = {
        ApiParams.page: page,
        ApiParams.perPage: perPage,
        ...extraParams?.params ?? {},
      }.removeEmptyKeys();

      final Map<String, dynamic> response = await Api.get(
        Apis.getCourses,
        data: parameters,
      );
      return PaginatedDataClass.fromResponse(
        (Map<String, dynamic> data) => CourseModel.fromJson(data),
        response,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<FeaturedSectionModel>> fetchFeaturedSectionProducts() async {
    final Map<String, dynamic> response = await Api.get(
      Apis.getFeatureSections,
    );

    return (response[ApiParams.data] as List).map((e) {
      return FeaturedSectionModel.fromJson(e);
    }).toList();
  }

  Future<CourseDetailsModel> fetchCourseDetails({
    int? courseId,
    String? slug,
  }) async {
    assert(
      courseId != null || slug != null,
      'Either courseId or slug must be provided',
    );
    try {
      final Map<String, dynamic> data = {};
      // Prioritize id over slug (slug is only used for wishlist navigation)
      if (courseId != null) {
        data['id'] = courseId;
      } else if (slug != null && slug.isNotEmpty) {
        data['slug'] = slug;
      }

      final Map<String, dynamic> response = await Api.get(
        Apis.getCourse,
        data: data,
      );

      return CourseDetailsModel.fromJson(
        response[ApiParams.data] as Map<String, dynamic>,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Mark a curriculum item as completed
  ///
  /// [chapterId] - The course_chapter_id
  /// [modelId] - The curriculum item ID
  /// [modelType] - The type of curriculum (lecture, quiz, assignment, etc.)
  Future<void> markCurriculumCompleted({
    required int chapterId,
    required int modelId,
    required String modelType,
  }) async {
    try {
      await Api.post(
        Apis.markCurriculumComplete,
        data: {
          'course_chapter_id': chapterId,
          'model_id': modelId,
          'model_type': modelType,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<CourseCompletionData> checkCourseStatus(int courseId) async {
    final response = await Api.get(
      Apis.courseCompletion,
      data: {ApiParams.courseId: courseId},
    );

    return CourseCompletionData.fromJson(response['data']);
  }

  Future<String> downloadCertificate({required int courseId}) async {
    try {
      // Get application documents directory
      final appDocDir = await getApplicationDocumentsDirectory();
      final downloadPath = '${appDocDir.path}/downloads';

      // Create downloads directory if it doesn't exist
      final downloadDir = Directory(downloadPath);
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      // Generate save path for the certificate
      final savePath = '$downloadPath/certificate_$courseId.pdf';

      final response = await Api.downloadPdf(
        Apis.downloadCertificate,
        data: {'course_id': courseId},
        savePath: savePath,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Purchase certificate for a course
  ///
  /// [courseId] - The course ID
  /// [paymentMethod] - The payment method (stripe, razorpay, flutterwave)
  Future<PurchaseCertificateResponseModel> purchaseCertificate({
    required int courseId,
    required String paymentMethod,
  }) async {
    try {
      final response = await Api.post(
        Apis.purchaseCertificate,
        data: {
          'course_id': courseId,
          'payment_method': paymentMethod,
          "type": "app",
        },
      );

      return PurchaseCertificateResponseModel.fromJson(
        response[ApiParams.data] as Map<String, dynamic>,
      );
    } catch (e) {
      rethrow;
    }
  }
}
