// Global enums here
import 'package:elms/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

enum AuthenticationType { apple, google, email, guest }

enum CustomButtonType { primary, outlined }

enum CourseCardStyle { horizontal, vertical, learning, withCourseDetails }

enum InstructorCardStyle { small, detailed }

enum DoubleTapDirection { left, right }

enum LessonType { video, document, quiz, assignment }

enum ChapterType { video, quiz, resource }

enum RatingStarStyle { filled, outlined }

enum TransactionStatus {
  pending(Colors.orange),
  success(Colors.green),
  failed(Colors.red);

  final Color color;

  const TransactionStatus(this.color);
}

enum QuizResult { pass, fail }

enum DialogButtonStyle { primary, outlined }

enum PlaybackSpeed {
  x0_25(0.25, '0.25x'),
  x0_5(0.5, '0.5x'),
  x0_75(0.75, '0.75x'),
  normal(1.0, 'Normal'),
  x1_25(1.25, '1.25x'),
  x1_5(1.5, '1.5x'),
  x1_75(1.75, '1.75x'),
  x2(2.0, '2x');

  final double value;
  final String label;

  const PlaybackSpeed(this.value, this.label);
}

enum SeekBarOrientation { horizontal, vertical }

enum UpdateCartAction { add, remove }

enum CheckoutType { cart, directEnroll }

enum ReviewType { course, instructor }

enum ResourceType { externalLink, download }

enum SubmissionStatus {
  submitted,
  inReview,
  accepted,
  rejected,
  suspended;

  Color getColor(BuildContext context) {
    return switch (this) {
      SubmissionStatus.submitted => Theme.of(context).colorScheme.success,
      SubmissionStatus.inReview => Theme.of(context).colorScheme.warning,
      SubmissionStatus.accepted => Theme.of(context).colorScheme.success,
      SubmissionStatus.rejected => Theme.of(context).colorScheme.error,
      SubmissionStatus.suspended => Theme.of(context).colorScheme.error,
    };
  }
}

enum DiscussionDestination { course, helpDesk }

enum CouponListTarget { course, cart }

enum FileType {
  audio,
  video,
  document,
  image;

  static FileType? fromString(String value) {
    switch (value.toLowerCase()) {
      case 'audio':
        return FileType.audio;
      case 'video':
        return FileType.video;
      case 'document':
        return FileType.document;
      case 'image':
        return FileType.image;
      default:
        return null;
    }
  }

  static FileType? fromExtension(String filePathOrUrl) {
    // Extract extension from file path or URL
    final String extension = filePathOrUrl.split('.').last.toLowerCase();

    // Remove query parameters if present
    final String cleanExtension = extension.split('?').first;

    // Check each file type's extensions
    for (final fileType in FileType.values) {
      if (fileType.extensions.contains(cleanExtension)) {
        return fileType;
      }
    }

    return null;
  }

  List<String> get extensions {
    switch (this) {
      case FileType.audio:
        return ['mp3', 'wav', 'aac', 'm4a', 'ogg', 'flac'];
      case FileType.video:
        return ['mp4', 'avi', 'mov', 'mkv', 'webm', 'flv'];
      case FileType.document:
        return ['pdf', 'doc', 'docx', 'txt', 'xls', 'xlsx', 'ppt', 'pptx'];
      case FileType.image:
        return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'svg', 'webp'];
    }
  }

  String get mimeType {
    switch (this) {
      case FileType.audio:
        return 'audio/*';
      case FileType.video:
        return 'video/*';
      case FileType.document:
        return 'application/*';
      case FileType.image:
        return 'image/*';
    }
  }
}

enum PaymentStatus {
  completed('completed'),
  paymentFailed('payment_failed'),
  cancelled('cancelled');

  final String value;

  const PaymentStatus(this.value);

  static PaymentStatus from(String value) {
    return PaymentStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw Exception('Unknown payment status: $value'),
    );
  }
}

enum RefundStatus {
  none(Colors.grey),
  pending(Colors.orange),
  approved(Colors.green),
  rejected(Colors.red);

  final Color color;

  const RefundStatus(this.color);

  static RefundStatus fromString(String? value) {
    if (value == null) return RefundStatus.none;

    return switch (value.toLowerCase()) {
      'pending' => RefundStatus.pending,
      'approved' => RefundStatus.approved,
      'rejected' => RefundStatus.rejected,
      _ => RefundStatus.none,
    };
  }
}

enum BillingDetails { get, post, patch }
