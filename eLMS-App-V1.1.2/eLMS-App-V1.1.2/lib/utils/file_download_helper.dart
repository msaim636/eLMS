import 'dart:io';
import 'package:dio/dio.dart';
import 'package:elms/utils/ui_utils.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class FileDownloadHelper {
  FileDownloadHelper._();

  static final Dio _dio = Dio();

  /// Downloads a file from the given URL and saves it to the application documents directory.
  /// If the file already exists (based on URL hash), it opens the file directly without downloading.
  /// Returns the file path if successful, null otherwise.
  static Future<String?> downloadOrOpenFile(
    String fileUrl, {
    Function(double)? onProgress,
    String? fileName,
  }) async {
    try {
      // Get application documents directory
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String downloadPath = '${appDocDir.path}/downloads';

      // Create downloads directory if it doesn't exist
      final Directory downloadDir = Directory(downloadPath);
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      // Generate file name from URL hash and extension
      final String fileHash = fileUrl.hashCode.abs().toString();
      final String fileExtension = _getFileExtension(fileUrl);
      final String finalFileName = fileName ?? 'file_$fileHash$fileExtension';
      final String filePath = '$downloadPath/$finalFileName';

      // Check if file already exists
      final File file = File(filePath);
      if (await file.exists()) {
        // File exists, open it directly
        UiUtils.showSnackBar('Opening file...');
        await _openFile(filePath);
        return filePath;
      }

      // File doesn't exist, download it
      UiUtils.showSnackBar('Downloading file...');

      await _dio.download(
        fileUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            onProgress?.call(progress);
          }
        },
      );

      UiUtils.showSnackBar('Download completed');

      // Open the downloaded file
      await _openFile(filePath);

      return filePath;
    } catch (e) {
      UiUtils.showSnackBar('Failed to download file: $e', isError: true);
      return null;
    }
  }

  /// Extracts file extension from URL
  static String _getFileExtension(String url) {
    try {
      final Uri uri = Uri.parse(url);
      final String path = uri.path;
      final int lastDot = path.lastIndexOf('.');

      if (lastDot != -1 && lastDot < path.length - 1) {
        return path.substring(lastDot);
      }
      return '';
    } catch (_) {
      return '';
    }
  }

  /// Opens the file using the default system application
  static Future<void> _openFile(String filePath) async {
    try {
      final result = await OpenFile.open(filePath);

      if (result.type == ResultType.done) {
        UiUtils.showSnackBar('File opened successfully');
      } else if (result.type == ResultType.noAppToOpen) {
        UiUtils.showSnackBar('No app found to open this file', isError: true);
      } else if (result.type == ResultType.fileNotFound) {
        UiUtils.showSnackBar('File not found', isError: true);
      } else if (result.type == ResultType.permissionDenied) {
        UiUtils.showSnackBar('Permission denied', isError: true);
      } else {
        UiUtils.showSnackBar('Error: ${result.message}', isError: true);
      }
    } catch (e) {
      UiUtils.showSnackBar('Failed to open file: $e', isError: true);
    }
  }

  /// Checks if a file exists for the given URL
  static Future<bool> fileExists(String fileUrl) async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String fileHash = fileUrl.hashCode.abs().toString();
      final String fileExtension = _getFileExtension(fileUrl);
      final String filePath =
          '${appDocDir.path}/downloads/file_$fileHash$fileExtension';

      final File file = File(filePath);
      return await file.exists();
    } catch (_) {
      return false;
    }
  }

  /// Deletes the downloaded file for the given URL
  static Future<bool> deleteFile(String fileUrl) async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String fileHash = fileUrl.hashCode.abs().toString();
      final String fileExtension = _getFileExtension(fileUrl);
      final String filePath =
          '${appDocDir.path}/downloads/file_$fileHash$fileExtension';

      final File file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Gets the file path for the given URL without downloading
  static Future<String?> getFilePath(String fileUrl) async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String fileHash = fileUrl.hashCode.abs().toString();
      final String fileExtension = _getFileExtension(fileUrl);
      final String filePath =
          '${appDocDir.path}/downloads/file_$fileHash$fileExtension';

      final File file = File(filePath);
      if (await file.exists()) {
        return filePath;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Clears all downloaded files
  static Future<bool> clearAllDownloads() async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String downloadPath = '${appDocDir.path}/downloads';
      final Directory downloadDir = Directory(downloadPath);

      if (await downloadDir.exists()) {
        await downloadDir.delete(recursive: true);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
