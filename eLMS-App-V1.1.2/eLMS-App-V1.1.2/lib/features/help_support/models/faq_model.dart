import 'package:elms/common/models/blueprints.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';

class Faq extends Model {
  final int id;
  final String question;
  final String answer;
  final DateTime createdAt;
  final DateTime updatedAt;

  Faq({
    required this.id,
    required this.question,
    required this.answer,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Faq.fromJson(Map<String, dynamic> json) {
    return Faq(
      id: json.optional<int>('id') ?? 0,
      question: json.optional<String>('question') ?? '',
      answer: json.optional<String>('answer') ?? '',
      createdAt:
          DateTime.tryParse(json.optional<String>('created_at') ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json.optional<String>('updated_at') ?? '') ??
          DateTime.now(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'question': question,
    'answer': answer,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}
