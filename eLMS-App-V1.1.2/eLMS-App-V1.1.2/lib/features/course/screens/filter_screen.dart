import 'package:elms/common/enums.dart';
import 'package:elms/common/widgets/custom_app_bar.dart';
import 'package:elms/common/widgets/custom_button.dart';
import 'package:elms/common/widgets/rating_bar_widget.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/features/course/models/filter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FilterScreen extends StatefulWidget {
  final List<Filter> filters;
  const FilterScreen({super.key, required this.filters});
  static Widget route() {
    final args = Get.arguments as List<Filter>;
    return FilterScreen(filters: args);
  }

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late final filters = widget.filters;

  @override
  void initState() {
    for (final Filter filter in filters) {
      filter.initNotifier();
    }
    super.initState();
  }

  @override
  void dispose() {
    for (final Filter filter in filters) {
      filter.disposeNotifier();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: AppLabels.filterBy.tr, showBackButton: true),
      bottomNavigationBar: BottomAppBar(
        padding: const .all(8),
        height: kBottomNavigationBarHeight,
        child: CustomButton(
          title: AppLabels.apply.tr,
          onPressed: () {
            Get.back(result: filters);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: List.generate(filters.length, (index) {
            return filters[index].build();
          }),
        ),
      ),
    );
  }
}

class RatingFilter extends Filter {
  RatingFilter({
    required super.titleKey,
    required super.apiKey,
    required super.values,
    required super.selectedValues,
  });
  @override
  Widget filterItem(FilterValue value, int index) {
    return CheckboxListTile(
      side: const BorderSide(),
      contentPadding: .zero,
      value: selectedValuesNotifier.value.contains(value),
      title: Rating.bar(
        filledStarCount: 5 - index,
        starStyle: RatingStarStyle.filled,
        showRatingCount: true,
      ),
      onChanged: (isSelected) {
        if (isSelected == true) {
          selectedValuesNotifier.value = List.from(selectedValuesNotifier.value)
            ..add(value);
          selectedValues = List.from(selectedValuesNotifier.value);
        } else {
          selectedValuesNotifier.value = List.from(selectedValuesNotifier.value)
            ..remove(value);
          selectedValues = List.from(selectedValuesNotifier.value);
        }
      },
    );
  }

  // Widget _buildStarBar() {
  //   // return Row(children: List.generate(5, (index) {
  //   //   re
  //   //   // return CustomIconButton(image: image, onTap: onTap)
  //   // },),);
  // }
}
