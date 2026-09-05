import 'package:elms/utils/extensions/data_type_extensions.dart';

class CourseCompletionData {
  final bool allCurriculumCompleted;
  final bool allAssignmentsSubmitted;
  final String certificate;
  final bool certificateFeePaid;
  final num? certificateFee;
  final num? certificateTaxPercentage;
  final num? certificateTaxAmount;
  final num? certificateTotal;

  CourseCompletionData({
    required this.allCurriculumCompleted,
    required this.allAssignmentsSubmitted,
    required this.certificate,
    required this.certificateFeePaid,
    this.certificateFee,
    this.certificateTaxPercentage,
    this.certificateTaxAmount,
    this.certificateTotal,
  });

  factory CourseCompletionData.fromJson(Map<String, dynamic> json) {
    return CourseCompletionData(
      allCurriculumCompleted:
          json.optional<bool>('all_curriculum_completed') ?? false,
      allAssignmentsSubmitted:
          json.optional<bool>('all_assignments_submitted') ?? false,
      certificate: json.optional<String>('certificate') ?? '',
      certificateFeePaid: json.optional<bool>('certificate_fee_paid') ?? false,
      certificateFee: json.optional<num>('certificate_fee'),
      certificateTaxPercentage: json.optional<num>(
        'certificate_tax_percentage',
      ),
      certificateTaxAmount: json.optional<num>('certificate_tax_amount'),
      certificateTotal: json.optional<num>('certificate_total'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'all_curriculum_completed': allCurriculumCompleted,
      'all_assignments_submitted': allAssignmentsSubmitted,
      'certificate': certificate,
      'certificate_fee_paid': certificateFeePaid,
      'certificate_fee': certificateFee,
      'certificate_tax_percentage': certificateTaxPercentage,
      'certificate_tax_amount': certificateTaxAmount,
      'certificate_total': certificateTotal,
    };
  }
}
