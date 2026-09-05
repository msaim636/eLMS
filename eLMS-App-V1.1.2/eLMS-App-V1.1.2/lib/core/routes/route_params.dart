import 'package:elms/common/enums.dart';
import 'package:elms/common/models/blueprints.dart';
import 'package:elms/common/models/chapter_model.dart';
import 'package:elms/common/models/course_model.dart';
import 'package:elms/core/login/phone_password_login.dart';
import 'package:elms/features/authentication/screens/signup/signup_screen.dart';
import 'package:elms/features/course/cubit/course_details_cubit.dart';

final class QuizResultParams extends RouteArguments {
  final QuizResult result;
  final int passingMarks;
  final int courseChapterQuizId;
  final String quizTitle;
  final int totalMarks;
  final List<Question> questions;
  final int courseId;
  final int chapterId;
  final int chapterIndex;
  final CourseDetailsCubit? courseDetailsCubit;

  QuizResultParams({
    required this.result,
    required this.passingMarks,
    required this.courseChapterQuizId,
    required this.quizTitle,
    required this.totalMarks,
    required this.questions,
    required this.courseId,
    required this.chapterId,
    required this.chapterIndex,
    this.courseDetailsCubit,
  });
}

final class SignupArguments extends RouteArguments {
  final SignupMode mode;
  final String? email;
  final PhoneNumber? phoneNumber;
  final String? firebaseToken;
  SignupArguments({
    required this.mode,
    this.email,
    this.phoneNumber,
    this.firebaseToken,
  });
}

final class VerifyScreenArguments extends RouteArguments {
  final PhoneNumber phoneNumber;
  final String verificationId;

  VerifyScreenArguments({
    required this.phoneNumber,
    required this.verificationId,
  });
}

final class CourseDetailsScreenArguments extends RouteArguments {
  final CourseModel course;
  final String? slug;

  CourseDetailsScreenArguments({required this.course, this.slug});
}

final class CourseContentScreenArguments extends RouteArguments {
  final CourseModel course;
  final String? slug;
  final int? id;
  final int? initialChapterIndex;
  final int? initialLectureIndex;

  CourseContentScreenArguments({
    required this.course,
    this.slug,
    this.initialChapterIndex,
    this.id,
    this.initialLectureIndex,
  });
}

final class DocumentViewerArguments extends RouteArguments {
  final String documentUrl;
  final String documentTitle;

  DocumentViewerArguments({
    required this.documentUrl,
    required this.documentTitle,
  });
}
