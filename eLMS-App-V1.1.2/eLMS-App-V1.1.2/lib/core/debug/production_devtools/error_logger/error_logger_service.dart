import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:elms/core/debug/production_devtools/error_logger/error_log_model.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/foundation.dart' hide Key;
import 'package:path_provider/path_provider.dart';

class ErrorLoggerService {
  ErrorLoggerService._();

  static final ErrorLoggerService instance = ErrorLoggerService._();

  // Obscured filename - looks like layout cache
  static const String _fileName = 'layout_cache.dat';
  static const int _maxLogs = 100;
  static const int _logsWithStackTrace = 20;

  // AES-256 encryption key and IV (must be exactly 32 and 16 chars)
  static final _key = Key.fromUtf8('ElmsErrLog2024SecretKey32Byte!!!');
  static final _iv = IV.fromUtf8('ElmsErrIV16Byte!');
  final Encrypter _encrypter = Encrypter(AES(_key, mode: AESMode.cbc));

  final List<ErrorLogModel> _logs = [];

  int _infoCount = 0;
  int _warningCount = 0;
  int _errorCount = 0;
  int _fatalCount = 0;

  bool _isInitialized = false;

  List<ErrorLogModel> get logs => List.unmodifiable(_logs);
  int get infoCount => _infoCount;
  int get warningCount => _warningCount;
  int get errorCount => _errorCount;
  int get fatalCount => _fatalCount;
  int get totalCount => _infoCount + _warningCount + _errorCount + _fatalCount;

  Future<void> init() async {
    if (_isInitialized) return;
    await _loadLogs();
    _isInitialized = true;
  }

  String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${_logs.length}';
  }

  void logError({
    required Object error,
    StackTrace? stackTrace,
    String? source,
    ErrorSeverity severity = ErrorSeverity.error,
  }) {
    final log = ErrorLogModel(
      id: _generateId(),
      errorType: error.runtimeType.toString(),
      message: error.toString(),
      stackTrace: stackTrace?.toString(),
      source: source,
      timestamp: DateTime.now(),
      severity: severity,
    );

    _logs.insert(0, log);
    _updateCounts(severity, increment: true);
    _trimLogs();
    _saveLogs();
  }

  void logInfo(String message, {String? source}) {
    logError(error: message, source: source, severity: ErrorSeverity.info);
  }

  void logWarning(String message, {String? source, StackTrace? stackTrace}) {
    logError(
      error: message,
      stackTrace: stackTrace,
      source: source,
      severity: ErrorSeverity.warning,
    );
  }

  void logFatal(Object error, {StackTrace? stackTrace, String? source}) {
    logError(
      error: error,
      stackTrace: stackTrace,
      source: source,
      severity: ErrorSeverity.fatal,
    );
  }

  void clearLogs() {
    _logs.clear();
    _infoCount = 0;
    _warningCount = 0;
    _errorCount = 0;
    _fatalCount = 0;
    _saveLogs();
  }

  void _updateCounts(ErrorSeverity severity, {required bool increment}) {
    final delta = increment ? 1 : -1;
    switch (severity) {
      case ErrorSeverity.info:
        _infoCount += delta;
      case ErrorSeverity.warning:
        _warningCount += delta;
      case ErrorSeverity.error:
        _errorCount += delta;
      case ErrorSeverity.fatal:
        _fatalCount += delta;
    }
  }

  Future<File> _getLogFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }

  Future<void> _loadLogs() async {
    try {
      final file = await _getLogFile();
      final exists = await file.exists();

      if (exists) {
        final encryptedData = await file.readAsBytes();
        final decryptedData = _decryptAndDecompress(encryptedData);
        final jsonData = jsonDecode(decryptedData) as Map<String, dynamic>;

        _infoCount = jsonData['ic'] as int? ?? 0;
        _warningCount = jsonData['wc'] as int? ?? 0;
        _errorCount = jsonData['ec'] as int? ?? 0;
        _fatalCount = jsonData['fc'] as int? ?? 0;

        final logsJson = jsonData['l'] as List<dynamic>? ?? [];
        _logs.clear();
        for (final logJson in logsJson) {
          _logs.add(ErrorLogModel.fromJson(logJson as Map<String, dynamic>));
        }
      }
    } catch (e) {
      // If loading fails, start fresh
      _logs.clear();
      _infoCount = 0;
      _warningCount = 0;
      _errorCount = 0;
      _fatalCount = 0;
    }
  }

  Future<void> _saveLogs() async {
    try {
      final logsJson = <Map<String, dynamic>>[];
      for (int i = 0; i < _logs.length; i++) {
        if (i < _logsWithStackTrace) {
          logsJson.add(_logs[i].toJson());
        } else {
          logsJson.add(_logs[i].toJsonCompact());
        }
      }

      final jsonData = {
        'ic': _infoCount,
        'wc': _warningCount,
        'ec': _errorCount,
        'fc': _fatalCount,
        'l': logsJson,
      };
      final jsonString = jsonEncode(jsonData);
      final encryptedData = _encryptAndCompress(jsonString);

      final file = await _getLogFile();
      await file.writeAsBytes(encryptedData);

      // Verify
      await file.exists();
    } catch (e) {
      // Ignore write errors silently in production
    }
  }

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

  Uint8List _encryptAndCompress(String data) {
    final compressed = gzip.encode(utf8.encode(data));
    final encrypted = _encrypter.encryptBytes(compressed, iv: _iv);
    return encrypted.bytes;
  }

  String _decryptAndDecompress(Uint8List encryptedData) {
    final encrypted = Encrypted(encryptedData);
    final decrypted = _encrypter.decryptBytes(encrypted, iv: _iv);
    final decompressed = gzip.decode(decrypted);
    return utf8.decode(decompressed);
  }

  List<ErrorLogModel> getFilteredLogs({
    ErrorSeverity? severityFilter,
    String? searchQuery,
  }) {
    return _logs.where((log) {
      if (severityFilter != null && log.severity != severityFilter) {
        return false;
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        return log.message.toLowerCase().contains(query) ||
            log.errorType.toLowerCase().contains(query) ||
            (log.source?.toLowerCase().contains(query) ?? false);
      }
      return true;
    }).toList();
  }
}
