import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:elms/core/debug/production_devtools/api_logger/api_log_model.dart';
import 'package:encrypt/encrypt.dart';
import 'package:path_provider/path_provider.dart';

class ApiLoggerService {
  ApiLoggerService._();

  static final ApiLoggerService instance = ApiLoggerService._();

  // Obscured filename - looks like font cache
  static const String _fileName = 'font_cache.dat';
  static const int _maxLogs = 100;
  static const int _logsWithBody = 20; // Only recent 20 logs keep full body

  // AES-256 encryption key (32 bytes) and IV (16 bytes)
  static final _key = Key.fromUtf8(
    'ElmsDevTools2024SecretKey32Byte!',
  ); // exactly 32 chars
  static final _iv = IV.fromUtf8('ElmsIV16BytesXX!'); // exactly 16 chars
  final Encrypter _encrypter = Encrypter(AES(_key, mode: AESMode.cbc));

  final List<ApiLogModel> _logs = [];
  final Map<String, DateTime> _pendingRequests = {};

  int _successCount = 0;
  int _failCount = 0;

  bool _isInitialized = false;

  List<ApiLogModel> get logs => List.unmodifiable(_logs);
  int get successCount => _successCount;
  int get failCount => _failCount;
  int get totalCount => _successCount + _failCount;

  Future<void> init() async {
    if (_isInitialized) return;
    await _loadLogs();
    _isInitialized = true;
  }

  String generateRequestId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${_logs.length}';
  }

  void logRequest({
    required String requestId,
    required String endpoint,
    required String method,
    Map<String, dynamic>? headers, // kept for API compatibility, not stored
    dynamic body,
  }) {
    _pendingRequests[requestId] = DateTime.now();

    final log = ApiLogModel(
      id: requestId,
      endpoint: endpoint,
      method: method,
      requestBody: body,
      requestTime: DateTime.now(),
      isSuccess: false,
    );

    _logs.insert(0, log);
    _trimLogs();
  }

  void logResponse({
    required String requestId,
    required int statusCode,
    dynamic body,
  }) {
    final requestTime = _pendingRequests.remove(requestId);
    final responseTime = DateTime.now();
    final durationMs = requestTime != null
        ? responseTime.difference(requestTime).inMilliseconds
        : null;

    final isSuccess = statusCode >= 200 && statusCode < 300;

    final index = _logs.indexWhere((log) => log.id == requestId);
    if (index != -1) {
      _logs[index] = _logs[index].copyWith(
        statusCode: statusCode,
        responseBody: body,
        responseTime: responseTime,
        durationMs: durationMs,
        isSuccess: isSuccess,
      );

      if (isSuccess) {
        _successCount++;
      } else {
        _failCount++;
      }
    }

    _saveLogs();
  }

  void logError({
    required String requestId,
    required String errorMessage,
    int? statusCode,
  }) {
    final requestTime = _pendingRequests.remove(requestId);
    final responseTime = DateTime.now();
    final durationMs = requestTime != null
        ? responseTime.difference(requestTime).inMilliseconds
        : null;

    final index = _logs.indexWhere((log) => log.id == requestId);
    if (index != -1) {
      _logs[index] = _logs[index].copyWith(
        statusCode: statusCode,
        responseTime: responseTime,
        durationMs: durationMs,
        isSuccess: false,
        errorMessage: errorMessage,
      );

      _failCount++;
    }

    _saveLogs();
  }

  void clearLogs() {
    _logs.clear();
    _successCount = 0;
    _failCount = 0;
    _pendingRequests.clear();
    _saveLogs();
  }

  Future<File> _getLogFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }

  Future<void> _loadLogs() async {
    try {
      final file = await _getLogFile();
      if (await file.exists()) {
        final encryptedData = await file.readAsBytes();
        final decryptedData = _decryptAndDecompress(encryptedData);
        final jsonData = jsonDecode(decryptedData) as Map<String, dynamic>;

        _successCount = jsonData['sc'] as int? ?? 0;
        _failCount = jsonData['fc'] as int? ?? 0;

        final logsJson = jsonData['l'] as List<dynamic>? ?? [];
        _logs.clear();
        for (final logJson in logsJson) {
          _logs.add(ApiLogModel.fromJson(logJson as Map<String, dynamic>));
        }
      }
    } catch (e) {
      // If loading fails, start fresh
      _logs.clear();
      _successCount = 0;
      _failCount = 0;
    }
  }

  Future<void> _saveLogs() async {
    try {
      // Recent logs (0 to _logsWithBody-1) keep full body
      // Older logs use compact format (no body) to save space
      final logsJson = <Map<String, dynamic>>[];
      for (int i = 0; i < _logs.length; i++) {
        if (i < _logsWithBody) {
          logsJson.add(_logs[i].toJson());
        } else {
          logsJson.add(_logs[i].toJsonCompact());
        }
      }

      final jsonData = {'sc': _successCount, 'fc': _failCount, 'l': logsJson};
      final jsonString = jsonEncode(jsonData);
      final encryptedData = _encryptAndCompress(jsonString);

      final file = await _getLogFile();
      await file.writeAsBytes(encryptedData);
    } catch (e) {
      // Silently fail on save errors
    }
  }

  // Get file size
  Future<int> getFileSize() async {
    final logFile = await _getLogFile();
    if (await logFile.exists()) {
      return await logFile.length();
    }
    return 0;
  }

  void _trimLogs() {
    if (_logs.length > _maxLogs) {
      _logs.removeRange(_maxLogs, _logs.length);
    }
  }

  // GZIP + AES-256 encryption
  Uint8List _encryptAndCompress(String data) {
    // First GZIP compress
    final compressed = gzip.encode(utf8.encode(data));

    // Then AES encrypt
    final encrypted = _encrypter.encryptBytes(compressed, iv: _iv);
    return encrypted.bytes;
  }

  String _decryptAndDecompress(Uint8List encryptedData) {
    // First AES decrypt
    final encrypted = Encrypted(encryptedData);
    final decrypted = _encrypter.decryptBytes(encrypted, iv: _iv);

    // Then GZIP decompress
    final decompressed = gzip.decode(decrypted);
    return utf8.decode(decompressed);
  }

  // Stats methods
  num get averageResponseTime {
    final completedLogs = _logs.where((log) => log.durationMs != null).toList();
    if (completedLogs.isEmpty) return 0;
    final total = completedLogs.fold<num>(
      0,
      (sum, log) => sum + (log.durationMs ?? 0),
    );
    return total / completedLogs.length;
  }

  num get successRate {
    if (totalCount == 0) return 0;
    return (_successCount / totalCount) * 100;
  }

  List<ApiLogModel> getFilteredLogs({
    bool? successOnly,
    bool? failedOnly,
    String? methodFilter,
    String? endpointFilter,
  }) {
    return _logs.where((log) {
      if (successOnly == true && !log.isSuccess) return false;
      if (failedOnly == true && log.isSuccess) return false;
      if (methodFilter != null && log.method != methodFilter) return false;
      if (endpointFilter != null &&
          !log.endpoint.toLowerCase().contains(endpointFilter.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
  }
}
