import 'package:elms/common/models/category_model.dart';
import 'package:elms/common/widgets/custom_expandable_tile.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Filter {
  final String titleKey;
  final String apiKey;
  List<FilterValue> values;
  final bool isMultiSelection;
  List<FilterValue> selectedValues;
  late ValueNotifier<List<FilterValue>> selectedValuesNotifier;

  Filter({
    required this.titleKey,
    required this.apiKey,
    required this.values,
    required this.selectedValues,
    this.isMultiSelection = true,
  });

  void initNotifier() {
    selectedValuesNotifier = ValueNotifier(selectedValues);
  }

  void disposeNotifier() {
    selectedValuesNotifier.dispose();
  }

  Widget filterItem(FilterValue value, int index) {
    if (isMultiSelection) {
      return CheckboxListTile(
        value: selectedValuesNotifier.value.contains(value),
        title: Text(value.toString()),
        checkboxShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
        side: const BorderSide(),
        contentPadding: .zero,
        onChanged: (isSelected) {
          if (isSelected == true) {
            selectedValuesNotifier.value = List.from(
              selectedValuesNotifier.value,
            )..add(value);
            selectedValues = List.from(selectedValuesNotifier.value);
          } else {
            selectedValuesNotifier.value = List.from(
              selectedValuesNotifier.value,
            )..remove(value);
            selectedValues = List.from(selectedValuesNotifier.value);
          }
        },
      );
    } else {
      return RadioGroup<FilterValue>(
        groupValue: selectedValuesNotifier.value.isNotEmpty
            ? selectedValuesNotifier.value.first
            : null,
        onChanged: (value) {
          if (value != null) {
            if (value == selectedValuesNotifier.value.firstOrNull) {
              selectedValuesNotifier.value = [];
            } else {
              selectedValuesNotifier.value = [value];
            }
            selectedValues = List.from(selectedValuesNotifier.value);
          }
        },
        child: RadioListTile(
          value: value,
          controlAffinity: .trailing,
          title: Text(value.toString()),
        ),
      );
    }
  }

  Widget build() {
    return ValueListenableBuilder(
      valueListenable: selectedValuesNotifier,
      builder: (context, value, child) {
        return CustomExpandableTile(
          borderRadius: 0,
          title: toString(),

          isExpanded: true,
          onToggle: () {},
          content: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: values.length,
            shrinkWrap: true,
            padding: .zero,
            itemBuilder: (context, index) {
              return filterItem(values[index], index);
            },
          ),
        );
      },
    );
  }

  @override
  String toString() {
    return titleKey.tr;
  }
}

class FilterValue {
  final String titleKey;
  final String apiValue;

  FilterValue({required this.titleKey, required this.apiValue});

  @override
  String toString() {
    return titleKey.tr;
  }
}

extension FilterListExtensions on List<Filter> {
  Map<String, dynamic> get apiExtraParams {
    return Map<String, dynamic>.fromEntries(
      map((e) {
        return MapEntry<String, dynamic>(
          e.apiKey,
          e.selectedValues.map((e) => e.apiValue).join(','),
        );
      }),
    );
  }

  bool get hasAppliedFilters {
    return !every((element) => element.selectedValues.isEmpty);
  }
}

class CategoryFilter extends Filter {
  List<CategoryModel> categories;

  CategoryFilter({
    required super.titleKey,
    required super.apiKey,
    required this.categories,
    required super.selectedValues,
  }) : super(values: []);

  void updateCategories(List<CategoryModel> newCategories) {
    categories = newCategories;
    // Flatten all category models recursively up to 3 levels to maintain backwards compatibility in values
    final List<FilterValue> flatValues = [];
    void flatten(List<CategoryModel>? list) {
      if (list == null) return;
      for (final cat in list) {
        flatValues.add(
          FilterValue(titleKey: cat.name, apiValue: cat.id.toString()),
        );
        flatten(cat.subcategories);
      }
    }

    flatten(categories);
    values = flatValues;
  }

  @override
  Widget build() {
    return ValueListenableBuilder(
      valueListenable: selectedValuesNotifier,
      builder: (context, value, child) {
        return CategoryFilterWidget(filter: this);
      },
    );
  }
}

class CategoryFilterWidget extends StatefulWidget {
  final CategoryFilter filter;
  const CategoryFilterWidget({super.key, required this.filter});

  @override
  State<CategoryFilterWidget> createState() => _CategoryFilterWidgetState();
}

class _CategoryFilterWidgetState extends State<CategoryFilterWidget> {
  final Set<int> expandedCategoryIds = {};

  @override
  void initState() {
    super.initState();
    _autoExpandSelectedCategories();
  }

  @override
  void didUpdateWidget(covariant CategoryFilterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _autoExpandSelectedCategories();
  }

  void _autoExpandSelectedCategories() {
    final selectedIds = widget.filter.selectedValuesNotifier.value
        .map((fv) => fv.apiValue)
        .toSet();

    bool hasSelectedChild(CategoryModel category) {
      bool hasSelected = false;
      if (category.subcategories != null &&
          category.subcategories!.isNotEmpty) {
        for (final subcat in category.subcategories!) {
          final bool isSubcatSelected = selectedIds.contains(
            subcat.id.toString(),
          );
          final bool subcatHasSelectedChild = hasSelectedChild(subcat);
          if (isSubcatSelected || subcatHasSelectedChild) {
            expandedCategoryIds.add(category.id);
            hasSelected = true;
          }
        }
      }
      return hasSelected;
    }

    for (final category in widget.filter.categories) {
      hasSelectedChild(category);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> treeWidgets = _buildCategoryTree(
      widget.filter.categories,
      1,
    );

    return CustomExpandableTile(
      borderRadius: 0,
      title: widget.filter.toString(),
      isExpanded: true,
      onToggle: () {},
      content: treeWidgets.isEmpty
          ? const SizedBox()
          : Column(children: treeWidgets),
    );
  }

  List<Widget> _buildCategoryTree(List<CategoryModel> list, int level) {
    final List<Widget> widgets = [];
    for (final category in list) {
      final bool isSelected = widget.filter.selectedValuesNotifier.value.any(
        (fv) => fv.apiValue == category.id.toString(),
      );
      final bool isExpanded = expandedCategoryIds.contains(category.id);
      final bool hasSubs =
          category.subcategories != null && category.subcategories!.isNotEmpty;

      widgets.add(
        _buildCategoryRow(category, level, isSelected, isExpanded, hasSubs),
      );

      if (isExpanded && hasSubs && level < 3) {
        widgets.addAll(_buildCategoryTree(category.subcategories!, level + 1));
      }
    }
    return widgets;
  }

  Widget _buildCategoryRow(
    CategoryModel category,
    int level,
    bool isSelected,
    bool isExpanded,
    bool hasSubs,
  ) {
    double indentation = 0;
    if (level == 2) {
      indentation = 36.0;
    } else if (level == 3) {
      indentation = 56.0;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: indentation),
          Checkbox(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            value: isSelected,
            side: const BorderSide(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            activeColor: context.color.primary,
            onChanged: (val) {
              final fv = FilterValue(
                titleKey: category.name,
                apiValue: category.id.toString(),
              );
              if (val == true) {
                widget.filter.selectedValuesNotifier.value = List.from(
                  widget.filter.selectedValuesNotifier.value,
                )..add(fv);
                widget.filter.selectedValues = List.from(
                  widget.filter.selectedValuesNotifier.value,
                );
              } else {
                widget.filter.selectedValuesNotifier.value = List.from(
                  widget.filter.selectedValuesNotifier.value,
                )..removeWhere((e) => e.apiValue == category.id.toString());
                widget.filter.selectedValues = List.from(
                  widget.filter.selectedValuesNotifier.value,
                );
              }
              setState(() {});
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                final fv = FilterValue(
                  titleKey: category.name,
                  apiValue: category.id.toString(),
                );
                if (isSelected) {
                  widget.filter.selectedValuesNotifier.value = List.from(
                    widget.filter.selectedValuesNotifier.value,
                  )..removeWhere((e) => e.apiValue == category.id.toString());
                } else {
                  widget.filter.selectedValuesNotifier.value = List.from(
                    widget.filter.selectedValuesNotifier.value,
                  )..add(fv);
                }
                widget.filter.selectedValues = List.from(
                  widget.filter.selectedValuesNotifier.value,
                );
                setState(() {});
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  category.name,
                  style: TextStyle(
                    color: context.color.onSurface,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          if (hasSubs && level < 3)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() {
                  if (isExpanded) {
                    expandedCategoryIds.remove(category.id);
                  } else {
                    expandedCategoryIds.add(category.id);
                  }
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Icon(
                  isExpanded ? Icons.remove : Icons.add,
                  size: 20,
                  color: context.color.onSurface,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
