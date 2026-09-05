import 'package:elms/common/widgets/custom_app_bar.dart';
import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_error_widget.dart';
import 'package:elms/common/widgets/custom_inkwell.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/custom_shimmer.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/localization/app_localization.dart';
import 'package:elms/core/localization/get_language.dart';
import 'package:elms/core/localization/language_cubit.dart';
import 'package:elms/core/localization/language_state.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/utils.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  static Widget route() => const LanguageScreen();

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  Future<void> _onRefresh() async {
    await context.read<LanguageCubit>().fetchLanguages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: AppLabels.language.tr, showBackButton: true),
      body: BlocBuilder<LanguageCubit, LanguageState>(
        builder: (context, state) {
          if (state is LanguageProgress) {
            return const CustomShimmer();
          }

          if (state is LanguageSuccess) {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView.separated(
                itemCount: state.languages.length,
                padding: const .all(16),
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final LanguageModel language = state.languages[index];

                  return _buildLanguageTile(context, language, Get.locale!);
                },
              ),
            );
          }

          if (state is LanguageError) {
            return CustomErrorWidget(error: state.error, onRetry: _onRefresh);
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildLanguageTile(
    BuildContext context,
    LanguageModel language,
    Locale currentLocale,
  ) {
    return CustomInkWell(
      color: context.color.surface,
      radius: 8,
      onTap: () {
        LoadingOverlay.execute(() async {
          await AppLocalization.instance.setLocale(
            Locale(language.code),
            isRtl: language.isRtl,
          );
        });
      },
      child: CustomCard(
        color: Colors.transparent,
        padding: const .symmetric(vertical: 22, horizontal: 16),
        child: Row(
          spacing: 16,
          children: [
            CustomImage.circular(
              imageUrl: language.image,
              width: 36,
              height: 36,
            ),
            CustomText(
              language.name,
              style: TextStyle(
                fontSize: context.font.medium,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            RadioGroup<String>(
              groupValue: currentLocale.languageCode,
              onChanged: (value) {
                if (value != null) {
                  LoadingOverlay.execute(() async {
                    await AppLocalization.instance.setLocale(
                      Locale(value),
                      isRtl: language.isRtl,
                    );
                  });
                }
              },
              child: Radio(value: language.code),
            ),
          ],
        ),
      ),
    );
  }
}
