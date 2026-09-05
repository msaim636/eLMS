import 'package:elms/common/widgets/custom_shimmer.dart';
import 'package:flutter/material.dart';

class SearchSuggestionShimmer extends StatelessWidget {
  const SearchSuggestionShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      padding: const .symmetric(vertical: 10),
      itemBuilder: (context, index) {
        return const CustomShimmer(
          height: 20,
          borderRadius: 3,
          margin: .symmetric(vertical: 8),
        );
      },
      itemCount: 4,
    );
  }
}
