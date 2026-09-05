class ApiLogModel {
  final String id;
  final String endpoint;
  final String method;
  final dynamic requestBody;
  final int? statusCode;
  final dynamic responseBody;
  final DateTime requestTime;
  final DateTime? responseTime;
  final int? durationMs;
  final bool isSuccess;
  final String? errorMessage;

  ApiLogModel({
    required this.id,
    required this.endpoint,
    required this.method,
    this.requestBody,
    this.statusCode,
    this.responseBody,
    required this.requestTime,
    this.responseTime,
    this.durationMs,
    required this.isSuccess,
    this.errorMessage,
  });

  ApiLogModel copyWith({
    String? id,
    String? endpoint,
    String? method,
    dynamic requestBody,
    int? statusCode,
    dynamic responseBody,
    DateTime? requestTime,
    DateTime? responseTime,
    int? durationMs,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return ApiLogModel(
      id: id ?? this.id,
      endpoint: endpoint ?? this.endpoint,
      method: method ?? this.method,
      requestBody: requestBody ?? this.requestBody,
      statusCode: statusCode ?? this.statusCode,
      responseBody: responseBody ?? this.responseBody,
      requestTime: requestTime ?? this.requestTime,
      responseTime: responseTime ?? this.responseTime,
      durationMs: durationMs ?? this.durationMs,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  factory ApiLogModel.fromJson(Map<String, dynamic> json) {
    return ApiLogModel(
      id: json['i'] as String,
      endpoint: json['e'] as String,
      method: json['m'] as String,
      requestBody: json['q'],
      statusCode: json['c'] as int?,
      responseBody: json['b'],
      requestTime: DateTime.parse(json['t'] as String),
      responseTime: json['r'] != null
          ? DateTime.parse(json['r'] as String)
          : null,
      durationMs: json['d'] as int?,
      isSuccess: json['s'] as bool,
      errorMessage: json['x'] as String?,
    );
  }

  // Full JSON with body - for recent logs
  // Short keys: i=id, e=endpoint, m=method, q=requestBody,
  // c=statusCode, b=responseBody, t=requestTime, r=responseTime,
  // d=durationMs, s=isSuccess, x=errorMessage
  Map<String, dynamic> toJson() {
    return {
      'i': id,
      'e': endpoint,
      'm': method,
      'q': _sanitizeBody(requestBody),
      'c': statusCode,
      'b': _sanitizeBody(responseBody),
      't': requestTime.toIso8601String(),
      'r': responseTime?.toIso8601String(),
      'd': durationMs,
      's': isSuccess,
      'x': errorMessage,
    };
  }

  // Compact JSON without body - for older logs (saves space)
  Map<String, dynamic> toJsonCompact() {
    return {
      'i': id,
      'e': endpoint,
      'm': method,
      'c': statusCode,
      't': requestTime.toIso8601String(),
      'r': responseTime?.toIso8601String(),
      'd': durationMs,
      's': isSuccess,
      'x': errorMessage,
    };
  }

  dynamic _sanitizeBody(dynamic body) {
    if (body == null) return null;
    if (body is String) return body;
    if (body is Map) return Map<String, dynamic>.from(body);
    if (body is List) return List.from(body);
    return body.toString();
  }
}
