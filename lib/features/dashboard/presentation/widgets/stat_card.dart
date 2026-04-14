import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/core/theme/themecolors.dart';
import 'package:task_manager/features/projects/presentation/bloc/project_bloc.dart';
import 'package:task_manager/features/projects/presentation/bloc/project_state.dart';
import 'package:task_manager/features/tasks/domain/entities/task_entity.dart';
import 'package:task_manager/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:task_manager/features/tasks/presentation/bloc/task_state.dart';

class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Get projects count
    final projectState = context.watch<ProjectBloc>().state;
    final totalProjects = projectState is ProjectsLoaded
        ? projectState.projects.where((p) => !p.isDeleted).length
        : 0;

    // Get tasks counts
    final taskState = context.watch<TaskBloc>().state;
    int totalTasks = 0;
    int pendingTasks = 0;
    int completedTasks = 0;

    if (taskState is TasksLoaded) {
      totalTasks = taskState.tasks.length;
      pendingTasks = taskState.tasks
          .where((t) => t.status != TaskStatus.completed)
          .length;
      completedTasks = taskState.tasks
          .where((t) => t.status == TaskStatus.completed)
          .length;
    }

    // 2 columns x 2 rows layout
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Projects',
                value: '$totalProjects',
                bottomText: 'Active projects',
                bottomTextColor: cs.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'Total Tasks',
                value: '$totalTasks',
                bottomText: 'All tasks',
                bottomTextColor: cs.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Pending',
                value: '$pendingTasks',
                bottomText: 'Need attention',
                bottomTextColor: AppColors.warning,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'Completed',
                value: '$completedTasks',
                bottomText: 'Done!',
                bottomTextColor: AppColors.success,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? bottomText;
  final Color? bottomTextColor;
  final Widget? child;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.bottomText,
    this.bottomTextColor,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: cs.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          if (bottomText != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                bottomText!,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: bottomTextColor,
                ),
              ),
            ),
          if (child != null) child!,
        ],
      ),
    );
  }
}