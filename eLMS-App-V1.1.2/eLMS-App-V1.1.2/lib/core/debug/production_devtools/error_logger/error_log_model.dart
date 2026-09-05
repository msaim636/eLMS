class ErrorLogModel {
  final String id;
  final String errorType;
  final String message;
  final String? stackTrace;
  final String? source;
  final DateTime timestamp;
  final ErrorSeverity severity;

  ErrorLogModel({
    required this.id,
    required this.errorType,
    required this.message,
    this.stackTrace,
    this.source,
    required this.timestamp,
    required this.severity,
  });

  ErrorLogModel copyWith({
    String? id,
    String? errorType,
    String? message,
    String? stackTrace,
    String? source,
    DateTime? timestamp,
    ErrorSeverity? severity,
  }) {
    return ErrorLogModel(
      id: id ?? this.id,
      errorType: errorType ?? this.errorType,
      message: message ?? this.message,
      stackTrace: stackTrace ?? this.stackTrace,
      source: source ?? this.source,
      timestamp: timestamp ?? this.timestamp,
      severity: severity ?? this.severity,
    );
  }

  factory ErrorLogModel.fromJson(Map<String, dynamic> json) {
    return ErrorLogModel(
      id: json['i'] as String,
      errorType: json['t'] as String,
      message: json['m'] as String,
      stackTrace: json['s'] as String?,
      source: json['o'] as String?,
      timestamp: DateTime.parse(json['d'] as String),
      severity: ErrorSeverity.values[json['v'] as int],
    );
  }

  // Full JSON with stack trace - for recent logs
  // Short keys: i=id, t=errorType, m=message, s=stackTrace,
  // o=source, d=timestamp, v=severity
  Map<String, dynamic> toJson() {
    return {
      'i': id,
      't': errorType,
      'm': message,
      's': stackTrace,
      'o': source,
      'd': timestamp.toIso8601String(),
      'v': severity.index,
    };
  }

  // Compact JSON without stack trace - for older logs
  Map<String, dynamic> toJsonCompact() {
    return {
      'i': id,
      't': errorType,
      'm': message,
      'o': source,
      'd': timestamp.toIso8601String(),
      'v': severity.index,
    };
  }
}

enum ErrorSeverity {
  info,
  warning,
  error,
  fatal;

  String get label {
    return switch (this) {
      ErrorSeverity.info => 'Info',
      ErrorSeverity.warning => 'Warning',
      ErrorSeverity.error => 'Error',
      ErrorSeverity.fatal => 'Fatal',
    };
  }
}
