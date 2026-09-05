import 'package:elms/core/api/api_client.dart';
import 'package:elms/core/api/api_params.dart';
import 'package:elms/core/error_management/exceptions.dart';
import 'package:elms/core/localization/language_cubit.dart';
import 'package:elms/core/localization/language_state.dart';
import 'package:elms/features/policy/models/policy_settings_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class PolicyRepository {
  Future<PolicySettingsModel> fetchPolicySettings({
    required String type,
  }) async {
    final Map<String, dynamic> response = await Api.get(
      Apis.pages,
      data: {ApiParams.type: type, "lang": Get.locale?.languageCode},
    );

    final List<dynamic> dataList = response[ApiParams.data] as List<dynamic>;
    if (dataList.isEmpty) {
      throw AppException(message: 'No data found');
    }

    // Get currently selected language id from LanguageCubit
    int? selectedLanguageId;
    final languageState = Get.context?.read<LanguageCubit>().state;
    if (languageState is LanguageSuccess) {
      final currentCode = Get.locale?.languageCode;
      final matched = languageState.languages
          .where((lang) => lang.code == currentCode)
          .firstOrNull;
      selectedLanguageId = matched?.id ?? languageState.defaultLanguage.id;
    }

    // Find the policy entry matching the selected language
    Map<String, dynamic>? matchedItem;
    if (selectedLanguageId != null) {
      matchedItem = dataList
          .cast<Map<String, dynamic>>()
          .where((item) => item['language_id'] == selectedLanguageId)
          .firstOrNull;
    }

    // Fall back to first item if no match found
    final Map<String, dynamic> item =
        matchedItem ?? dataList.first as Map<String, dynamic>;

    return PolicySettingsModel.fromJson(item);
  }
}
