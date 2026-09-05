import 'package:elms/common/widgets/custom_no_data_widget.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/features/course/cubit/resource_cubit.dart';
import 'package:elms/features/course/models/resource_data_model.dart';
import 'package:elms/features/course/widgets/resource_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:elms/utils/extensions/context_extension.dart';

class CurrentLectureSection extends StatelessWidget {
  const CurrentLectureSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ResourceCubit, ResourceState>(
      builder: (context, state) {
        if (state is ResourceProgress) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ResourceError) {
          return Center(
            child: CustomText(
              'Error: ${state.error}',
              style: TextStyle(fontSize: context.font.small),
            ),
          );
        }

        if (state is ResourceSuccess) {
          if (state.data.flatCurrentLectureResources.isEmpty) {
            return const CustomNoDataWidget();
          }

          return Padding(
            padding: const .symmetric(vertical: 16),
            child: Column(
              spacing: 10,
              children: state.data.flatCurrentLectureResources
                  .indexed
                  .map((e) {
                return ResourceTile(
                  resource: e.$2,
                  showCard: true,
                  index: e.$1,
                );
              }).toList(),
            ),
          );
        }

        return const SizedBox();
      },
    );
  }
}
