import 'dart:convert';
import 'package:elms/common/models/blueprints.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';

class RatingDistribution extends Model {
  final int fiveStars;
  final int fourStars;
  final int threeStars;
  final int twoStars;
  final int oneStar;
  final num fiveStarsPercentage;
  final num fourStarsPercentage;
  final num threeStarsPercentage;
  final num twoStarsPercentage;
  final num oneStarPercentage;

  RatingDistribution({
    required this.fiveStars,
    required this.fourStars,
    required this.threeStars,
    required this.twoStars,
    required this.oneStar,
    required this.fiveStarsPercentage,
    required this.fourStarsPercentage,
    required this.threeStarsPercentage,
    required this.twoStarsPercentage,
    required this.oneStarPercentage,
  });

  int get totalRatingsCount =>
      fiveStars + fourStars + threeStars + twoStars + oneStar;

  @override
  Map<String, dynamic> toJson() {
    return {
      'fiveStars': fiveStars,
      'fourStars': fourStars,
      'threeStars': threeStars,
      'twoStars': twoStars,
      'oneStar': oneStar,
      'fiveStarsPercentage': fiveStarsPercentage,
      'fourStarsPercentage': fourStarsPercentage,
      'threeStarsPercentage': threeStarsPercentage,
      'twoStarsPercentage': twoStarsPercentage,
      'oneStarPercentage': oneStarPercentage,
    };
  }

  factory RatingDistribution.fromMap(Map<String, dynamic> map) {
    final breakdown =
        map.optional<Map<String, dynamic>>('rating_breakdown') ?? {};
    final percentages =
        map.optional<Map<String, dynamic>>('percentage_breakdown') ?? {};

    return RatingDistribution(
      fiveStars: breakdown.optional<int>('5_stars') ?? 0,
      fourStars: breakdown.optional<int>('4_stars') ?? 0,
      threeStars: breakdown.optional<int>('3_stars') ?? 0,
      twoStars: breakdown.optional<int>('2_stars') ?? 0,
      oneStar: breakdown.optional<int>('1_star') ?? 0,
      fiveStarsPercentage: percentages.optional<num>('5_stars') ?? 0,
      fourStarsPercentage: percentages.optional<num>('4_stars') ?? 0,
      threeStarsPercentage: percentages.optional<num>('3_stars') ?? 0,
      twoStarsPercentage: percentages.optional<num>('2_stars') ?? 0,
      oneStarPercentage: percentages.optional<num>('1_star') ?? 0,
    );
  }

  factory RatingDistribution.fromJson(String source) =>
      RatingDistribution.fromMap(json.decode(source));
}

class ReviewModel extends Model {
  final num averageRating;
  final int totalReviews;
  final RatingDistribution ratingDistribution;

  ReviewModel({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'ratingDistribution': ratingDistribution.toJson(),
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      averageRating: map.optional<num>('average_rating')?.toDouble() ?? 0.0,
      totalReviews: map.optional<int>('total_reviews') ?? 0,
      ratingDistribution: RatingDistribution.fromMap(map),
    );
  }

  factory ReviewModel.fromJson(String source) =>
      ReviewModel.fromMap(json.decode(source));
}
