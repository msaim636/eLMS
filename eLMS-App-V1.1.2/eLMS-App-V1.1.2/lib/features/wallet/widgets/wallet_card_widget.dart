import 'dart:io';

import 'package:elms/common/widgets/custom_button.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/features/authentication/cubit/authentication_cubit.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/utils/extensions/color_extension.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

/// Balance card shown inside each wallet tab.
///
/// [buttonTitle]  — label on the action button (Add Money / Withdraw Money).
/// [onTapButton]  — callback when the button is tapped. Pass `null` to disable.
/// [isTotalBalance] — if true, shows the total balance (including IAP credit), else shows withdrawable wallet balance.
class WalletCardWidget extends StatefulWidget {
  final String buttonTitle;
  final VoidCallback? onTapButton;
  final bool isTotalBalance;

  const WalletCardWidget({
    super.key,
    required this.buttonTitle,
    this.onTapButton,
    this.isTotalBalance = false,
  });

  @override
  State<WalletCardWidget> createState() => _WalletCardWidgetState();
}

class _WalletCardWidgetState extends State<WalletCardWidget> {
  @override
  void initState() {
    context.read<AuthenticationCubit>().refreshUserDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final AuthenticationCubit authCubit = context.watch<AuthenticationCubit>();
    final num balance = widget.isTotalBalance
        ? (authCubit.totalBalance ?? 0)
        : (authCubit.totalBalance! - authCubit.creditBalance!);
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              context.color.primary,
              context.color.primary.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SizedBox(
          height: 143,
          child: Stack(
            children: [
              ..._buildBackgroundShapes(),
              SizedBox(
                width: context.screenWidth,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (Platform.isAndroid) ...[
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                CustomText(
                                  AppLabels.currentBalance.tr,
                                  style: TextStyle(
                                    fontSize: context.font.xSmall,
                                  ),
                                  color: context.color.primary
                                      .getAdaptiveTextColor(),
                                ),
                                CustomText(
                                  (authCubit.totalBalance?.toStringAsFixed(
                                        2,
                                      ))?.currency ??
                                      '0',
                                  style: TextStyle(
                                    fontSize: context.font.xLarge,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  color: context.color.primary
                                      .getAdaptiveTextColor(),
                                ),
                              ],
                            ),
                          ),

                          Container(
                            width: 1,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: .topCenter,
                                end: .bottomCenter,
                                stops: const [0.0, 0.5, 1.0],
                                colors: [
                                  context.color.primary,
                                  Colors.white,
                                  context.color.primary,
                                ],
                              ),
                            ),
                          ),

                          Expanded(
                            child: Column(
                              children: [
                                CustomText(
                                  AppLabels.withdrawMoney.tr,
                                  style: TextStyle(
                                    fontSize: context.font.xSmall,
                                  ),
                                  color: context.color.primary
                                      .getAdaptiveTextColor(),
                                ),
                                CustomText(
                                  authCubit.walletBalance.toString().currency,
                                  style: TextStyle(
                                    fontSize: context.font.xLarge,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  color: context.color.primary
                                      .getAdaptiveTextColor(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],

                    if (Platform.isIOS)
                      Column(
                        children: [
                          CustomText(
                            widget.isTotalBalance
                                ? AppLabels.currentBalance.tr
                                : AppLabels.withdrawMoneyBalance.tr,
                            style: TextStyle(fontSize: context.font.small),
                            color: context.color.primary.getAdaptiveTextColor(),
                          ),
                          CustomText(
                            balance.toStringAsFixed(2).currency,
                            style: TextStyle(
                              fontSize: context.font.xxLarge,
                              fontWeight: FontWeight.bold,
                            ),
                            color: context.color.primary.getAdaptiveTextColor(),
                          ),
                        ],
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: CustomButton(
                        title: widget.buttonTitle,
                        onPressed: widget.onTapButton,
                        textColor: context.color.primary,
                        backgroundColor: Colors.white,
                        fullWidth: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Positioned> _buildBackgroundShapes() {
    return [
      Positioned(
        right: -37,
        top: -37,
        child: CustomPaint(
          painter: ShapePainter(color: context.color.primary.brighten(.05)),
          child: const SizedBox(width: 100, height: 100),
        ),
      ),
      Positioned(
        left: -50,
        bottom: -50,
        child: CustomPaint(
          painter: ShapePainter(color: context.color.primary.brighten(.07)),
          child: const SizedBox(width: 100, height: 100),
        ),
      ),
    ];
  }
}

class ShapePainter extends CustomPainter {
  final Color color;
  ShapePainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    // Build all paths
    final path0 = _buildPath0(size);
    final path1 = _buildPath1(size);

    // Calculate combined bounds of all shapes
    Rect combinedBounds = path0.getBounds();
    combinedBounds = combinedBounds.expandToInclude(path1.getBounds());

    // Calculate offset to center all shapes as a group
    final dx = size.width / 2 - combinedBounds.center.dx;
    final dy = size.height / 2 - combinedBounds.center.dy;
    final centerOffset = Offset(dx, dy);

    // Apply centering offset to all paths
    final centeredPath0 = path0.shift(centerOffset);
    final centeredPath1 = path1.shift(centerOffset);

    // Shape 1
    final Paint fillPaint0 = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(centeredPath0, fillPaint0);

    // Shape 2
    final Paint fillPaint1 = Paint()
      ..color = const Color(0x00000000)
      ..style = PaintingStyle.fill;
    canvas.drawPath(centeredPath1, fillPaint1);
    final Paint strokePaint1 = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawPath(centeredPath1, strokePaint1);
  }

  static Path _buildPath0(Size size) {
    return Path()
      ..moveTo(size.width * 0.5011, size.height * 0.0605)
      ..cubicTo(
        size.width * 0.7393,
        size.height * 0.0605,
        size.width * 0.9323,
        size.height * 0.2564,
        size.width * 0.9323,
        size.height * 0.4981,
      )
      ..cubicTo(
        size.width * 0.9323,
        size.height * 0.7398,
        size.width * 0.7393,
        size.height * 0.9357,
        size.width * 0.5011,
        size.height * 0.9357,
      )
      ..cubicTo(
        size.width * 0.263,
        size.height * 0.9357,
        size.width * 0.07,
        size.height * 0.7398,
        size.width * 0.07,
        size.height * 0.4981,
      )
      ..cubicTo(
        size.width * 0.07,
        size.height * 0.2564,
        size.width * 0.263,
        size.height * 0.0605,
        size.width * 0.5011,
        size.height * 0.0605,
      )
      ..close();
  }

  static Path _buildPath1(Size size) {
    return Path()
      ..moveTo(size.width * 0.5, 0)
      ..cubicTo(
        size.width * 0.7761,
        0,
        size.width,
        size.height * 0.2239,
        size.width,
        size.height * 0.5,
      )
      ..cubicTo(
        size.width,
        size.height * 0.7761,
        size.width * 0.7761,
        size.height,
        size.width * 0.5,
        size.height,
      )
      ..cubicTo(
        size.width * 0.2239,
        size.height,
        0,
        size.height * 0.7761,
        0,
        size.height * 0.5,
      )
      ..cubicTo(
        0,
        size.height * 0.2239,
        size.width * 0.2239,
        0,
        size.width * 0.5,
        0,
      )
      ..close();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
