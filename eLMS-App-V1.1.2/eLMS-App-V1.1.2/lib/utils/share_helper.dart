import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ShareHelper {
  ShareHelper._();

  static bool _isSharing = false;

  static Rect? _originFrom(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize || box.size.isEmpty) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  static Future<void> shareText(
    BuildContext context,
    String text, {
    String? subject,
  }) async {
    if (_isSharing) return;
    _isSharing = true;
    try {
      await Share.share(
        text,
        subject: subject,
        sharePositionOrigin: _originFrom(context),
      );
    } finally {
      _isSharing = false;
    }
  }

  static Future<void> shareUri(BuildContext context, Uri uri) async {
    if (_isSharing) return;
    _isSharing = true;
    try {
      await Share.shareUri(
        uri,
        sharePositionOrigin: _originFrom(context),
      );
    } finally {
      _isSharing = false;
    }
  }
}
