import 'package:elms/common/widgets/custom_app_bar.dart';
import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/features/course/widgets/assignment_card.dart';
import 'package:elms/features/course/cubit/assignment_cubit.dart';
import 'package:elms/features/course/repository/assignment_repository.dart';
import 'package:elms/features/course/models/assignment_model.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class AssignmentScreen extends StatefulWidget {
  final int courseId;
  final int? chapterId;
  const AssignmentScreen({super.key, required this.courseId, this.chapterId});

  static Widget route([RouteSettings? settings]) {
    final arguments = settings?.arguments ?? Get.arguments;
    int courseId = 0;
    int? chapterId;

    if (arguments is Map<String, dynamic>) {
      courseId = arguments['courseId'] as int? ?? 0;
      chapterId = arguments['chapterId'] as int?;
    } else if (arguments is int) {
      courseId = arguments;
    }

    return BlocProvider(
      create: (context) => AssignmentCubit(AssignmentRepository()),
      child: AssignmentScreen(courseId: courseId, chapterId: chapterId),
    );
  }

  @override
  State<AssignmentScreen> createState() => _AssignmentScreenState();
}

class _AssignmentScreenState extends State<AssignmentScreen>
    with SingleTickerProviderStateMixin {
  int _selectedTabIndex = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _tabController.addListener(_onTabChanged);
    context.read<AssignmentCubit>().fetchAssignments(
      widget.courseId,
      chapterId: widget.chapterId,
    );
  }

  void _onTabChanged() {
    setState(() {
      _selectedTabIndex = _tabController.index;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight * 2.2),
        child: Column(
          children: [
            CustomAppBar(showBackButton: true, title: AppLabels.assignment.tr),
            _buildTabBar(),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildChapterAssignments(), _buildAllAssignments()],
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      indicatorColor: context.color.primary,
      labelColor: context.color.primary,
      unselectedLabelColor: context.color.onSurface,
      labelStyle: const TextStyle(fontWeight: .w500, fontSize: 14),
      unselectedLabelStyle: const TextStyle(fontWeight: .w400, fontSize: 14),
      padding: const .symmetric(horizontal: 16),
      dividerColor: context.color.outline,
      isScrollable: true,
      tabAlignment: .start,
      tabs: [
        Tab(
          child: CustomText(
            AppLabels.chapterAssignment.tr,
            fontSize: 14,
            style: TextStyle(
              fontSize: context.font.small,
              fontWeight: _selectedTabIndex == 0 ? .w500 : .w400,
              color: _selectedTabIndex == 0
                  ? context.color.primary
                  : context.color.onSurface,
            ),
          ),
        ),
        Tab(
          child: CustomText(
            AppLabels.allAssignments.tr,
            style: TextStyle(
              fontSize: context.font.small,
              fontWeight: _selectedTabIndex == 1 ? .w500 : .w400,
              color: _selectedTabIndex == 1
                  ? context.color.primary
                  : context.color.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAllAssignments() {
    return BlocBuilder<AssignmentCubit, AssignmentState>(
      buildWhen: (previous, current) {
        // Only rebuild for fetch states, ignore submission states
        return current is AssignmentProgress ||
            current is AssignmentSuccess ||
            current is AssignmentError;
      },
      builder: (context, state) {
        if (state is AssignmentProgress) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AssignmentError) {
          return Center(
            child: Padding(
              padding: const .all(16),
              child: CustomText(
                state.error,
                style: TextStyle(fontSize: context.font.medium),
              ),
            ),
          );
        }

        if (state is AssignmentSuccess) {
          if (state.data.chapters.isEmpty) {
            return Center(
              child: Padding(
                padding: const .all(16),
                child: CustomText(
                  AppLabels.noAssignmentsAvailable.tr,
                  style: TextStyle(fontSize: context.font.medium),
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const .all(16),
            itemBuilder: (context, index) {
              final chapter = state.data.chapters[index];
              return _buildAssignmentSection(
                title: chapter.title,
                assignments: chapter.assignments,
                chapterId: chapter.id,
              );
            },
            separatorBuilder: (context, index) {
              return const SizedBox(height: 16);
            },
            itemCount: state.data.chapters.length,
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildChapterAssignments() {
    return BlocBuilder<AssignmentCubit, AssignmentState>(
      buildWhen: (previous, current) {
        // Only rebuild for fetch states, ignore submission states
        return current is AssignmentProgress ||
            current is AssignmentSuccess ||
            current is AssignmentError;
      },
      builder: (context, state) {
        if (state is AssignmentProgress) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AssignmentError) {
          return Center(
            child: Padding(
              padding: const .all(16),
              child: CustomText(
                state.error,
                style: TextStyle(fontSize: context.font.medium),
              ),
            ),
          );
        }

        if (state is AssignmentSuccess) {
          if (state.data.currentChapter.isEmpty) {
            return Center(
              child: Padding(
                padding: const .all(16),
                child: CustomText(
                  AppLabels.noAssignmentsAvailable.tr,
                  style: TextStyle(fontSize: context.font.medium),
                ),
              ),
            );
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const .all(16),
                  child: _buildChapterDetailCard(
                    state.data.currentChapter.first,
                  ),
                ),
                ListView.separated(
                  padding: const .symmetric(horizontal: 16),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final AssignmentChapter chapter =
                        state.data.currentChapter[index];
                    return _buildAssignmentSection(
                      title: chapter.title,
                      assignments: chapter.assignments,
                      chapterId: chapter.id,
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const SizedBox(height: 16);
                  },
                  itemCount: state.data.currentChapter.length,
                ),
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildChapterDetailCard(AssignmentChapter chapter) {
    return CustomCard(
      padding: const .all(8),
      child: Row(
        children: [
          CustomImage(
            chapter.courseImage,
            width: 45,
            height: 45,
            radius: 6,
            fit: .cover,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                CustomText(
                  chapter.courseName,
                  maxLines: 2,
                  ellipsis: true,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall!.copyWith(fontWeight: .w400),
                ),
                CustomText(
                  chapter.title,
                  maxLines: 2,
                  ellipsis: true,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.copyWith(fontWeight: .w400),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentSection({
    required String title,
    required List<AssignmentModel> assignments,
    required int chapterId,
    bool showChapterTitle = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.color.surface,
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const .all(10),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          if (showChapterTitle) ...{
            CustomText(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge!.copyWith(fontWeight: .w400),
            ),
            const SizedBox(height: 12),
          },
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: assignments.length,
            padding: .zero,
            itemBuilder: (context, index) {
              return AssignmentCard(
                assignment: assignments[index],
                chapterId: chapterId,
                index: index,
              );
            },
            separatorBuilder: (context, index) {
              return const SizedBox(height: 16);
            },
          ),
        ],
      ),
    );
  }
}
