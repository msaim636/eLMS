import 'package:elms/features/settings/cubit/app_settings_cubit.dart';
import 'package:elms/utils/share_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ShareAppHelper {
  ShareAppHelper._();

  static Future<void> shareApp(BuildContext context) async {
    final settings = context.read<AppSettingsCubit>().settings;
    final String? playstoreUrl = settings?.playstoreUrl;
    final String? appstoreUrl = settings?.appstoreUrl;

    const String appName = 'ELMS';
    final String message =
        'Check out $appName - Your complete E-Learning Management System!\n\n'
        'Download now:\n'
        '${playstoreUrl != null && playstoreUrl.isNotEmpty ? 'Android: $playstoreUrl\n' : ''}'
        '${appstoreUrl != null && appstoreUrl.isNotEmpty ? 'iOS: $appstoreUrl' : ''}';

    await ShareHelper.shareText(
      context,
      message.trim(),
      subject: 'Check out $appName',
    );
  }

  static Future<void> shareAppWithMessage({
    required BuildContext context,
    required String message,
    String? subject,
  }) async {
    await ShareHelper.shareText(context, message, subject: subject);
  }
}
