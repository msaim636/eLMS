import 'dart:async';
import 'dart:io';

import 'package:elms/common/enums.dart';
import 'package:elms/common/widgets/custom_app_bar.dart';
import 'package:elms/common/widgets/custom_button.dart';
import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_dialog_box.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/common/widgets/stepper_progress_widget.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/routes/routes.dart';
import 'package:elms/features/authentication/cubit/authentication_cubit.dart';
import 'package:elms/features/cart/screens/payment_webview_screen.dart';
import 'package:elms/features/course/cubit/certificate_download_cubit.dart';
import 'package:elms/features/course/cubit/purchase_certificate_cubit.dart';
import 'package:elms/features/course/features/quiz/cubits/check_course_completion_cubit.dart';
import 'package:elms/features/course/repository/course_repository.dart';
import 'package:elms/features/course/widgets/certificate_widget.dart';
import 'package:elms/features/course/widgets/payment_method_dialog.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';
import 'package:elms/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';

class CourseCertificateScreen extends StatefulWidget {
  final int courseId;
  const CourseCertificateScreen({super.key, required this.courseId});

  static Widget route([RouteSettings? settings]) {
    final args = (settings?.arguments ?? Get.arguments) as Map<String, dynamic>;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => CheckCourseCompletionCubit(CourseRepository()),
        ),
        BlocProvider(
          create: (context) => PurchaseCertificateCubit(CourseRepository()),
        ),
        BlocProvider(
          create: (context) => CertificateDownloadCubit(CourseRepository()),
        ),
      ],
      child: CourseCertificateScreen(courseId: args['courseId'] as int),
    );
  }

  @override
  State<CourseCertificateScreen> createState() =>
      _CourseCertificateScreenState();
}

class _CourseCertificateScreenState extends State<CourseCertificateScreen> {
  String? _selectedPaymentMethod;

  @override
  void initState() {
    context.read<CheckCourseCompletionCubit>().check(widget.courseId);
    super.initState();
  }

  void _onTapDownloadOrPurchaseCertificate() {
    final state = context.read<CheckCourseCompletionCubit>().state;

    if (state is CheckCourseCompletionStatusSuccess) {
      final data = state.data;

      // Check if certificate fee needs to be paid
      if (data.certificateFee != null &&
          (data.certificateFee ?? 0) > 0 &&
          !data.certificateFeePaid) {
        // Use certificateTotal (includes tax) if available, otherwise fall back to certificateFee
        final totalAmount = data.certificateTotal ?? data.certificateFee!;

        if (Platform.isIOS) {
          final userTotalBalance =
              context.read<AuthenticationCubit>().totalBalance ?? 0;
          if (userTotalBalance >= totalAmount) {
            _selectedPaymentMethod = 'wallet';
            _purchaseCertificate('wallet');
          } else {
            _showInsufficientBalanceDialog(
              currentBalance: userTotalBalance,
              requiredAmount: totalAmount,
            );
          }
        } else {
          // Show payment method selection dialog
          PaymentMethodDialog.show(
            context: context,
            onPaymentMethodSelected: (paymentMethod) {
              _selectedPaymentMethod = paymentMethod;
              _purchaseCertificate(paymentMethod);
            },
            totalAmount: totalAmount,
          );
        }
      } else {
        // Free certificate or already paid - proceed to download
        _downloadCertificate();
      }
    }
  }

  void _purchaseCertificate(String paymentMethod) {
    context.read<PurchaseCertificateCubit>().purchaseCertificate(
      courseId: widget.courseId,
      paymentMethod: paymentMethod,
    );
  }

  void _downloadCertificate() {
    context.read<CertificateDownloadCubit>().downloadCertificate(
      courseId: widget.courseId,
    );
  }

  void _showInsufficientBalanceDialog({
    required num currentBalance,
    required num requiredAmount,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => CustomDialogBox(
        title: AppLabels.insufficientBalance.tr,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildBalanceRow(
              label: AppLabels.currentBalance.tr,
              amount: currentBalance,
              color: context.color.error,
            ),
            const SizedBox(height: 8),
            _buildBalanceRow(
              label: AppLabels.requiredAmount.tr,
              amount: requiredAmount,
              color: context.color.onSurface,
            ),
          ],
        ),
        actions: [
          DialogButton(
            title: AppLabels.cancel.tr,
            onTap: () => Navigator.pop(dialogContext),
            color: context.color.primary,
            style: DialogButtonStyle.outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceRow({
    required String label,
    required num amount,
    required Color color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(
          label,
          style: TextStyle(
            fontSize: context.font.medium,
            color: context.color.textSecondary,
          ),
        ),
        CustomText(
          amount.toStringAsFixed(2).currency,
          style: TextStyle(
            fontSize: context.font.medium,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<PurchaseCertificateCubit, PurchaseCertificateState>(
          listener: (context, state) async {
            if (state is PurchaseCertificateSuccess) {
              // Check if payment URL exists (for gateway payments)
              if (state.data.payment?.url != null &&
                  state.data.payment!.url.isNotEmpty) {
                // Navigate to payment webview using nested navigator
                final navigator = Get.nestedKey(1)?.currentState;
                final result = await navigator?.pushNamed(
                  CourseContentRoute.paymentWebView,
                  arguments: {
                    'paymentUrl': state.data.payment!.url,
                    'orderNumber': state.data.orderNumber,
                  },
                );

                // Reset the purchase certificate state
                if (context.mounted) {
                  context.read<PurchaseCertificateCubit>().reset();
                  if (result case final PaymentGatewayCallbackResponse data) {
                    if (data.status == PaymentStatus.completed) {
                      // Refresh user details if payment was made through wallet
                      if (_selectedPaymentMethod == 'wallet' &&
                          context.mounted) {
                        try {
                          await context
                              .read<AuthenticationCubit>()
                              .refreshUserDetails();
                        } catch (e) {
                          // Continue even if refresh fails
                        }
                      }

                      if (context.mounted) {
                        Navigator.pop(context);
                        unawaited(
                          context.read<CheckCourseCompletionCubit>().check(
                            widget.courseId,
                          ),
                        );
                        UiUtils.showSnackBar(AppLabels.certificatePurchased.tr);
                      }
                    }
                  } else if (result is Map && result['success'] == true) {
                    // Refresh user details if payment was made through wallet
                    if (_selectedPaymentMethod == 'wallet' && context.mounted) {
                      try {
                        await context
                            .read<AuthenticationCubit>()
                            .refreshUserDetails();
                      } catch (e) {
                        // Continue even if refresh fails
                      }
                    }

                    if (context.mounted) {
                      Navigator.pop(context);
                      unawaited(
                        context.read<CheckCourseCompletionCubit>().check(
                          widget.courseId,
                        ),
                      );
                      UiUtils.showSnackBar('Certificate purchased');
                    }
                  }
                }
              } else {
                // Direct payment (likely wallet or free) - no payment URL
                // Refresh user details if payment was made through wallet
                if (_selectedPaymentMethod == 'wallet' && context.mounted) {
                  try {
                    await context
                        .read<AuthenticationCubit>()
                        .refreshUserDetails();
                  } catch (e) {
                    // Continue even if refresh fails
                  }
                }

                // Reset state and refresh certificate data
                if (context.mounted) {
                  context.read<PurchaseCertificateCubit>().reset();
                  unawaited(
                    context.read<CheckCourseCompletionCubit>().check(
                      widget.courseId,
                    ),
                  );
                  UiUtils.showSnackBar(AppLabels.certificatePurchasedSuccessfully.tr);
                }
              }
            } else if (state is PurchaseCertificateError) {
              UiUtils.showSnackBar(state.error, isError: true);
            }
          },
        ),
        BlocListener<CertificateDownloadCubit, CertificateDownloadState>(
          listener: (context, state) async {
            if (state is CertificateDownloadSuccess) {
              UiUtils.showSnackBar(AppLabels.certificateDownloadedSuccessfully.tr);

              await OpenFile.open(state.filePath);
            }
          },
        ),
      ],
      child:
          BlocBuilder<
            CheckCourseCompletionCubit,
            CheckCourseCompletionStatusState
          >(
            builder: (context, state) {
              if (state is CheckCourseCompletionStatusInProgress) {
                return Scaffold(
                  appBar: CustomAppBar(
                    showBackButton: true,
                    title: AppLabels.certificate.tr,
                  ),
                  body: const Center(
                    child: CircularProgressIndicator.adaptive(),
                  ),
                );
              }

              return Scaffold(
                appBar: CustomAppBar(
                  showBackButton: true,
                  title: AppLabels.certificate.tr,
                ),
                bottomNavigationBar: BottomAppBar(
                  padding: const .symmetric(horizontal: 16, vertical: 8),
                  height: 65,
                  child: _buildBottomNavigationBar(),
                ),
                body: Padding(
                  padding: const .all(16),
                  child: Column(
                    children: [_buildProgress(), _buildCertificateContainer()],
                  ),
                ),
              );
            },
          ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BlocBuilder<
      CheckCourseCompletionCubit,
      CheckCourseCompletionStatusState
    >(
      builder: (context, state) {
        bool isEligible = false;
        String buttonTitle = AppLabels.completeTasksToDownload.tr;

        if (state is CheckCourseCompletionStatusSuccess) {
          isEligible =
              state.data.allAssignmentsSubmitted &&
              state.data.allCurriculumCompleted;

          if (isEligible) {
            // Check if certificate is paid and not yet purchased
            if (state.data.certificateFee != null &&
                (state.data.certificateFee ?? 0) > 0 &&
                !state.data.certificateFeePaid) {
              // Use certificateTotal (includes tax) if available, otherwise fall back to certificateFee
              final displayAmount =
                  state.data.certificateTotal ?? state.data.certificateFee;
              buttonTitle = AppLabels.purchaseCertificate.translateWithTemplate(
                {'amount': displayAmount.toString().currency},
              );
            } else {
              buttonTitle = AppLabels.downloadCertificate.tr;
            }
          }
        }

        return BlocBuilder<PurchaseCertificateCubit, PurchaseCertificateState>(
          builder: (context, purchaseState) {
            final isLoading =
                purchaseState is PurchaseCertificateProgress ||
                context.watch<CertificateDownloadCubit>().state
                    is CertificateDownloadProgress;

            return CustomButton(
              title: isLoading ? AppLabels.downloading : buttonTitle,
              onPressed: isEligible && !isLoading
                  ? _onTapDownloadOrPurchaseCertificate
                  : null,
              isLoading: isLoading,
            );
          },
        );
      },
    );
  }

  Widget _buildProgress() {
    return BlocBuilder<
      CheckCourseCompletionCubit,
      CheckCourseCompletionStatusState
    >(
      builder: (context, state) {
        int currentStep = 0;

        if (state is CheckCourseCompletionStatusSuccess) {
          if (state.data.allAssignmentsSubmitted) {
            currentStep = 2;
          } else if (state.data.allCurriculumCompleted) {
            currentStep = 1;
          }
        }

        return CustomCard(
          padding: const .all(8),
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .start,
            spacing: 15,
            children: [
              CustomText(
                AppLabels.completeTaskProgress.tr,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium!.copyWith(fontWeight: .w500),
              ),
              StepperProgressWidget(
                stepperPadding: const .symmetric(horizontal: 22),
                currentStep: currentStep,
                steps: [
                  ProgressStep(title: AppLabels.completeAClass.tr),
                  ProgressStep(title: AppLabels.submitAProject.tr),
                  ProgressStep(title: AppLabels.earnACertificate.tr),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCertificateContainer() {
    return Column(
      children: [
        _buildCertificateTitleDescription(),
        const SizedBox(
          height: 250,
          child: CertificateWidget(
            certificateImage: 'assets/images/certificate_bg.png',
          ),
        ),
      ],
    );
  }

  Widget _buildCertificateTitleDescription() {
    return Padding(
      padding: const .symmetric(vertical: 16),
      child: Column(
        children: [
          CustomText(
            AppLabels.earnYourCertificate.tr,
            style: Theme.of(
              context,
            ).textTheme.titleMedium!.copyWith(fontWeight: .w500),
          ),
          const SizedBox(height: 6),
          CustomText(
            AppLabels.certificateDescription.tr,
            height: 1.5,
            textAlign: .center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(fontWeight: .w400),
          ),
        ],
      ),
    );
  }
}
