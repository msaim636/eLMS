import 'package:elms/common/models/blueprints.dart';

class OnboardingModel implements Model {
  final String title;
  final String description;
  final String image;
  OnboardingModel({
    required this.title,
    required this.description,
    required this.image,
  });

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
