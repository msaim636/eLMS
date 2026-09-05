// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:elms/common/models/blueprints.dart';
import 'package:elms/core/api/api_client.dart';


class Quality {
  final String name;
  final String url;
  Quality({required this.name, required this.url});

  factory Quality.notSpecified() {
    return Quality(name: '', url: '');
  }
}

class HostedVideo extends VideoSource {
  final String url;
  HostedVideo(this.url);

  @override
  FutureOr<String> getSource() {
    return url;
  }
}



class HLSVideo extends VideoSource {
  final String apiUrl;
  String? _manifestUrl;
  DateTime? _tokenExpiry;

  HLSVideo(this.apiUrl);

  @override
  FutureOr<String> getSource() async {
    final streamResponse = await _getVideoStream();

    _tokenExpiry = DateTime.now().add(
      Duration(seconds: streamResponse['expires_in_seconds'] as int),
    );

    _manifestUrl = streamResponse['manifest_url'] as String;
    return _manifestUrl!;
  }

  Future<Map<String, dynamic>> _getVideoStream() async {
    try {
      final response = await Api.get(apiUrl);

      if (response['error'] == false) {
        return response['data'] as Map<String, dynamic>;
      } else {
        throw Exception(response['message'] ?? 'Failed to get video stream');
      }
    } catch (e) {
      // Handle specific error codes
      if (e.toString().contains('401')) {
        throw Exception('Authentication expired. Please log in again.');
      } else if (e.toString().contains('403')) {
        throw Exception('You are not enrolled in this course.');
      } else if (e.toString().contains('503')) {
        throw Exception(
          'Video is still being processed. Please try again later.',
        );
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Check if token needs refresh (5 minutes before expiry)
  bool needsRefresh() {
    if (_tokenExpiry == null) return false;
    final refreshTime = _tokenExpiry!.subtract(const Duration(minutes: 5));
    return DateTime.now().isAfter(refreshTime);
  }

  // Get time until token refresh is needed
  Duration? getRefreshDuration() {
    if (_tokenExpiry == null) return null;
    final refreshTime = _tokenExpiry!.subtract(const Duration(minutes: 5));
    final duration = refreshTime.difference(DateTime.now());
    return duration.isNegative ? null : duration;
  }

  // Refresh the token and get new manifest URL
  Future<String> refreshToken() async {
    return await getSource();
  }
}
