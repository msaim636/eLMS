import 'package:elms/common/models/blueprints.dart';
import 'package:elms/common/models/course_model.dart';
import 'package:elms/common/models/instructor_model.dart';
import 'package:elms/common/models/user_review_model.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';

class InstructorDetailsModel extends InstructorModel {
  InstructorDetailsModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.status,
    required super.name,
    required super.email,
    required super.slug,
    required super.profile,
    super.qualification,
    super.yearsOfExperience,
    super.skills,
    super.aboutMe,
    super.previewVideo,
    super.teamName,
    super.teamLogo,
    required super.averageRating,
    required super.totalRatings,
    required super.reviewCount,
    required super.studentEnrolledCount,
    required super.activeCoursesCount,
    required super.publishedCoursesCount,
    super.createdAt,
    super.updatedAt,
    super.deletedAt,
    required this.courses,
    required this.socialMedias,
    required this.ratings,
    this.myReview,
  });

  final List<CourseModel> courses;
  final List<InstructorSocialMediaModel> socialMedias;
  final List<InstructorRatingModel> ratings;
  final MyReviewModel? myReview;

  factory InstructorDetailsModel.fromJson(Map<String, dynamic> json) {
    return InstructorDetailsModel(
      id: json.require<int>('id'),
      userId: json.require<int>('user_id'),
      type: json.require<String>('type'),
      status: json.require<String>('status'),
      name: json.require<String>('name'),
      email: json.require<String>('email'),
      slug: json.require<String>('slug'),
      profile: json.require<String>('profile'),
      qualification: json.optional<String?>('qualification'),
      yearsOfExperience: json.optional<int>('years_of_experience'),
      skills: json.optional<String?>('skills'),
      aboutMe: json.optional<String?>('about_me'),
      previewVideo: json.optional<String?>('preview_video'),
      teamName: json.optional<String?>('team_name'),
      teamLogo: json.optional<String?>('team_logo'),
      averageRating: json.require<num>('average_rating').toDouble(),
      totalRatings: json.require<int>('total_ratings'),
      reviewCount: json.require<int>('review_count'),
      studentEnrolledCount: json.require<int>('student_enrolled_count'),
      activeCoursesCount: json.require<int>('active_courses_count'),
      publishedCoursesCount: json.require<int>('published_courses_count'),
      createdAt: json.optional<String?>('created_at') != null
          ? DateTime.tryParse(json.optional<String>('created_at')!)
          : null,
      updatedAt: json.optional<String?>('updated_at') != null
          ? DateTime.tryParse(json.optional<String>('updated_at')!)
          : null,
      deletedAt: json.optional<String?>('deleted_at') != null
          ? DateTime.tryParse(json.optional<String>('deleted_at')!)
          : null,
      courses: (json.optional<List<dynamic>>('courses') ?? [])
          .map((e) => CourseModel.fromJson(Map.from(e)))
          .toList(),
      socialMedias: (json.optional<List<dynamic>>('social_medias') ?? [])
          .map((e) => InstructorSocialMediaModel.fromJson(Map.from(e)))
          .toList(),
      ratings: (json.optional<List<dynamic>>('ratings') ?? [])
          .map((e) => InstructorRatingModel.fromMap(Map.from(e)))
          .toList(),
      myReview: json.optional<Map<String, dynamic>?>('my_review') != null
          ? MyReviewModel.fromMap(
              json.optional<Map<String, dynamic>>('my_review')!,
            )
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {};
  }
}

class InstructorSocialMediaModel extends Model {
  final String name;
  final String url;

  InstructorSocialMediaModel({required this.name, required this.url});

  factory InstructorSocialMediaModel.fromJson(Map<String, dynamic> json) {
    return InstructorSocialMediaModel(
      name: json.require<String>('title'),
      url: json.require<String>('url'),
    );
  }

  /// Supported social media platforms
  static const List<String> supportedPlatforms = [
    'Facebook',
    'Instagram',
    'LinkedIn',
    'Twitter',
    'YouTube',
  ];

  /// Check if this social media platform is supported
  bool get isSupported {
    return supportedPlatforms.any(
      (platform) => name.toLowerCase() == platform.toLowerCase(),
    );
  }

  /// Get the icon path for this social media platform
  String? get iconPath {
    final lowerName = name.toLowerCase();
    switch (lowerName) {
      case 'facebook':
        return 'assets/icons/facebook_icon.svg';
      case 'instagram':
        return 'assets/icons/instagram_icon.svg';
      case 'linkedin':
        return 'assets/icons/linkedin_icon.svg';
      case 'twitter':
        return 'assets/icons/twitter_icon.svg';
      case 'youtube':
        return 'assets/icons/youtube_icon.svg';
      default:
        return null;
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {};
  }
}
