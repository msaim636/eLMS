import 'package:elms/common/widgets/custom_app_bar.dart';
import 'package:elms/common/widgets/custom_error_widget.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/error_management/exceptions.dart';
import 'package:elms/features/policy/cubit/policy_cubit.dart';
import 'package:elms/features/policy/cubit/policy_state.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

enum PolicyType { termsAndConditions, privacyPolicy, refundPolicy }

class PolicyScreen extends StatefulWidget {
  final PolicyType policyType;

  const PolicyScreen({super.key, required this.policyType});

  static Widget route() {
    final Map<String, dynamic> args = Get.arguments as Map<String, dynamic>;
    return PolicyScreen(policyType: args['policyType'] as PolicyType);
  }

  @override
  State<PolicyScreen> createState() => _PolicyScreenState();
}

class _PolicyScreenState extends State<PolicyScreen> {
  bool _isFetched = false;

  String get _policyType {
    if (widget.policyType == PolicyType.termsAndConditions) {
      return 'terms-and-conditions';
    }
    if (widget.policyType == PolicyType.refundPolicy) {
      return 'refund-policy';
    }
    return 'privacy-policy';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isFetched) {
      context.read<PolicyCubit>().fetchPolicySettings(type: _policyType);
      _isFetched = true;
    }
  }

  void _onTapLink(String? url) {
    if (url != null) {
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.policyType == PolicyType.termsAndConditions
            ? AppLabels.termsAndConditions.tr
            : widget.policyType == PolicyType.refundPolicy
            ? AppLabels.refundPolicy.tr
            : AppLabels.privacyPolicy.tr,
        showBackButton: true,
      ),
      body: BlocBuilder<PolicyCubit, PolicyState>(
        builder: (context, state) {
          if (state is PolicyProgress) {
            return Center(
              child: CircularProgressIndicator(color: context.color.primary),
            );
          }
          if (state is PolicySuccess) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Html(
                data: state.policySettings.pageContent,
                onLinkTap: (url, attributes, element) => _onTapLink(url),
                style: {
                  'body': Style(
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero,
                    color: context.color.onSurface,
                    fontFamily: 'Roboto',
                  ),
                  'h1': Style(color: context.color.onSurface),
                  'h2': Style(color: context.color.onSurface),
                  'h3': Style(color: context.color.onSurface),
                  'h4': Style(color: context.color.onSurface),
                  'h5': Style(color: context.color.onSurface),
                  'h6': Style(color: context.color.onSurface),
                  'p': Style(
                    color: context.color.onSurface,
                    lineHeight: LineHeight.em(1.5),
                  ),
                  'a': Style(color: context.color.primary),
                  'li': Style(color: context.color.onSurface),
                  'ul': Style(color: context.color.onSurface),
                  'ol': Style(color: context.color.onSurface),
                },
              ),
            );
          }

          if (state is PolicyError) {
            if (state.error is CustomException) {
              return CustomErrorWidget(
                error: state.error,
                onRetry: () {
                  context.read<PolicyCubit>().fetchPolicySettings(
                    type: _policyType,
                  );
                },
              );
            }
          }

          return const SizedBox();
        },
      ),
    );
  }
}
