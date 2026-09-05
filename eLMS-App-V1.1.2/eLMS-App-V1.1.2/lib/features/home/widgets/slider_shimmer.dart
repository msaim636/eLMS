import 'package:elms/common/widgets/custom_shimmer.dart';
import 'package:flutter/material.dart';

class SliderShimmer extends StatelessWidget {
  const SliderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomShimmer(height: 190, margin: .symmetric(horizontal: 16));
  }
}
