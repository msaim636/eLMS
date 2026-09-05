import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/extensions/color_extension.dart';
import 'package:flutter/material.dart';

class ProgressStep {
  final String title;
  ProgressStep({required this.title});
}

class StepperProgressWidget extends StatelessWidget {
  final List<ProgressStep> steps;
  final int currentStep;
  final double circleSize;
  final EdgeInsetsGeometry? stepperPadding;
  const StepperProgressWidget({
    super.key,
    required this.steps,
    required this.currentStep,
    this.circleSize = 16,
    this.stepperPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8,
      children: [
        Padding(
          padding: stepperPadding ?? .zero,
          child: Stack(
            alignment: .center,
            children: [
              LayoutBuilder(
                builder: (context, constraint) {
                  return Row(
                    children: [
                      Container(
                        height: 6,
                        margin: const .symmetric(vertical: 4),
                        width:
                            (constraint.maxWidth / (steps.length - 1)) *
                            currentStep,
                        decoration: BoxDecoration(color: context.color.primary),
                      ),
                      Expanded(
                        child: Container(
                          height: 6,
                          margin: const .symmetric(vertical: 4),
                          width: double.maxFinite,
                          decoration: BoxDecoration(
                            color: context.color.primary.brighten(0.5),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Row(
                  mainAxisAlignment: .spaceBetween,
                  children: List.generate(steps.length, (index) {
                    return Container(
                      width: circleSize,
                      height: circleSize,
                      decoration: BoxDecoration(
                        color: currentStep >= index
                            ? context.color.primary
                            : context.color.primary.brighten(0.5),
                        shape: .circle,
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: .spaceBetween,
          children: List.generate(
            steps.length,
            (index) => _buildStep(steps[index], steps),
          ),
        ),
      ],
    );
  }

  Widget _buildStep(ProgressStep step, List list) {
    final int currentStep = list.indexOf(step);
    return Expanded(
      child: Text(
        step.title,
        textAlign: currentStep == 0
            ? .start
            : currentStep == list.length - 1
            ? .end
            : .center,
      ),
    );
  }
}
