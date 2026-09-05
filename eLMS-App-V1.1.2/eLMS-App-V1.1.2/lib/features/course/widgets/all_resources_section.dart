import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_expandable_tile.dart';
import 'package:elms/common/widgets/custom_no_data_widget.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/features/course/cubit/resource_cubit.dart';
import 'package:elms/features/course/models/resource_data_model.dart';
import 'package:elms/features/course/widgets/resource_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/utils.dart';
import 'package:elms/utils/extensions/context_extension.dart';

class AllResources extends StatelessWidget {
  const AllResources({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ResourceCubit, ResourceState>(
      builder: (context, state) {
        if (state is ResourceProgress) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ResourceError) {
          return Center(child: Text('Error: ${state.error}'));
        }

        if (state is ResourceSuccess) {
          return _buildResourcesContent(context);
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildResourcesContent(BuildContext context) {
    final ResourceState state = context.read<ResourceCubit>().state;
    if (state is! ResourceSuccess) {
      return const SizedBox();
    }
    final CourseResourcesModel resourceData = state.data;

    if (resourceData.allResources.chapters.isEmpty) {
      return const CustomNoDataWidget();
    }

    return ListView.separated(
      padding: const .symmetric(vertical: 16),
      itemBuilder: (context, index) {
        final ChapterModel chapter = resourceData.allResources.chapters[index];
        return CustomExpandableTile(
          content: Padding(
            padding: const .all(8.0),
            child: Column(
              crossAxisAlignment: .start,
              children: [
                CustomCard(
                  width: double.infinity,
                  padding: const .all(16),
                  child: Column(
                    spacing: 6,
                    crossAxisAlignment: .start,
                    children: <Widget>[
                      CustomText(
                        AppLabels.chapterResources.tr,
                        style: TextStyle(
                          fontSize: context.font.small,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      ...List.generate(chapter.resources.length, (index) {
                        final ResourceModel resource = chapter.resources[index];

                        return Padding(
                          padding: const .symmetric(vertical: 8),
                          child: ResourceTile(
                            resource: resource,
                            index: index,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 6),

                if (chapter.lectureResources.isNotEmpty) ...{
                  CustomText(
                    AppLabels.lectureResources.tr,
                    style: TextStyle(
                      fontSize: context.font.small,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const SizedBox(height: 16),
                },
                ...List.generate(chapter.lectureResources.length, (index) {
                  final LectureModel lectureModel =
                      chapter.lectureResources[index];

                  return CustomExpandableTile(
                    highlightTitle: true,
                    content: Column(
                      children: List.generate(lectureModel.resources.length, (
                        index,
                      ) {
                        final resource = lectureModel.resources[index];

                        return Padding(
                          padding: const .symmetric(vertical: 8),
                          child: ResourceTile(
                            resource: resource,
                            index: index,
                          ),
                        );
                      }),
                    ),
                    title: lectureModel.title,
                    onToggle: () {},
                  );
                }),
              ],
            ),
          ),
          onToggle: () {},
          highlightTitle: true,
          title: chapter.chapterTitle,
        );
      },
      separatorBuilder: (context, index) {
        return const SizedBox(height: 17);
      },
      itemCount: resourceData.allResources.chapters.length,
    );
  }
}
