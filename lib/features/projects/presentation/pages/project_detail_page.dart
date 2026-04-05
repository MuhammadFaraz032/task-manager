// ignore_for_file: unused_element_parameter, unused_element

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:task_manager/core/theme/themecolors.dart';
import 'package:task_manager/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:task_manager/features/auth/presentation/bloc/auth_state.dart';
import 'package:task_manager/features/projects/domain/entities/project_entity.dart';
import 'package:task_manager/features/projects/presentation/bloc/project_bloc.dart';
import 'package:task_manager/features/projects/presentation/bloc/project_event.dart';
import 'package:task_manager/features/projects/presentation/bloc/project_state.dart';
import 'package:task_manager/features/tasks/domain/entities/task_entity.dart';
import 'package:task_manager/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:task_manager/features/tasks/presentation/bloc/task_event.dart';
import 'package:task_manager/features/tasks/presentation/bloc/task_state.dart';
import 'package:task_manager/features/tasks/presentation/pages/add_task_page.dart';
import 'package:task_manager/features/workspace/presentation/cubit/workspace_cubit.dart';
import 'package:task_manager/features/workspace/presentation/cubit/workspace_state.dart';

class ProjectDetailScreen extends StatelessWidget {
  final String projectId;

  const ProjectDetailScreen({super.key, this.projectId = ''});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // LEARNING: We get the project from ProjectBloc
    // which already has all projects loaded from Firestore
    // No need for a separate API call — just find it in the list
    final projectState = context.watch<ProjectBloc>().state;
    ProjectEntity? project;

    if (projectState is ProjectsLoaded) {
      try {
        project = projectState.projects.firstWhere((p) => p.id == projectId);
      } catch (_) {
        project = null;
      }
    }

    return Scaffold(
      backgroundColor: cs.surface,
      body: project == null
          ? _buildLoading(cs)
          : Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    /// Sticky Header
                    SliverAppBar(
                      pinned: true,
                      floating: false,
                      backgroundColor: cs.surface,
                      elevation: 0,
                      toolbarHeight: 64,
                      automaticallyImplyLeading: false,
                      flexibleSpace: Container(
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: cs.outline)),
                        ),
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    InkWell(
                                      // ✅ Fixed
                                      onTap: () {
                                        if (context.canPop()) {
                                          context.pop();
                                        } else {
                                          context.go('/projects');
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: cs.surface,
                                          border: Border.all(color: cs.outline),
                                        ),
                                        child: Icon(
                                          Icons.arrow_back_ios_rounded,
                                          color: cs.primary,
                                          size: 14,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.55,
                                      child: Text(
                                        project.name,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.45,
                                          color: cs.onSurface,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                InkWell(
                                  onTap: () =>
                                      _showOptionsMenu(context, project!),
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: cs.surface,
                                      border: Border.all(color: cs.outline),
                                    ),
                                    child: Icon(
                                      Icons.more_vert_rounded,
                                      color: cs.onSurface,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    /// Content
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          /// Progress Card
                          _ProgressCard(cs: cs, project: project),

                          const SizedBox(height: 32),

                          /// Task Section — still mock for now
                          /// TODO: wire to TaskBloc in next step
                          _TaskSection(
                            cs: cs,
                            projectId: projectId,
                            workspaceId:
                                (context.read<WorkspaceCubit>().state
                                        as WorkspaceLoaded)
                                    .workspace
                                    .id,
                          ),
                        ]),
                      ),
                    ),
                  ],
                ),

                /// Bottom Add Task Button
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _AddTaskButton(cs: cs, projectId: projectId),
                ),
              ],
            ),
    );
  }

  Widget _buildLoading(ColorScheme cs) {
    return Center(child: CircularProgressIndicator(color: cs.primary));
  }

  void _showOptionsMenu(BuildContext context, ProjectEntity project) {
    final cs = Theme.of(context).colorScheme;
    final workspaceId =
        (context.read<WorkspaceCubit>().state as WorkspaceLoaded).workspace.id;
    final projectBloc = context.read<ProjectBloc>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            // Mark as Complete
            ListTile(
              leading: Icon(Icons.check_circle_outline, color: cs.primary),
              title: Text(
                project.status == ProjectStatus.completed
                    ? 'Mark as Active'
                    : 'Mark as Completed',
                style: TextStyle(color: cs.onSurface),
              ),
              onTap: () {
                Navigator.pop(context);
                projectBloc.add(
                  ProjectUpdateRequested(
                    projectId: project.id,
                    name: project.name,
                    workspaceId: workspaceId,
                    description: project.description,
                    status: project.status == ProjectStatus.completed
                        ? ProjectStatus.active
                        : ProjectStatus.completed,
                    priority: project.priority,
                    dueDate: project.dueDate,
                  ),
                );
              },
            ),
            // Delete
            ListTile(
              leading: Icon(Icons.delete_outline, color: cs.error),
              title: Text('Delete Project', style: TextStyle(color: cs.error)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, project, projectBloc);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    ProjectEntity project,
    ProjectBloc projectBloc,
  ) {
    final cs = Theme.of(context).colorScheme;
    final workspaceId =
        (context.read<WorkspaceCubit>().state as WorkspaceLoaded).workspace.id;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: cs.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Project', style: TextStyle(color: cs.onSurface)),
        content: Text(
          'Are you sure you want to delete "${project.name}"? This cannot be undone.',
          style: TextStyle(color: cs.onSurface.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: TextStyle(color: cs.onSurface)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              projectBloc.add(
                ProjectDeleteRequested(
                  projectId: project.id,
                  workspaceId: workspaceId,
                  deletedBy: project.createdBy,
                ),
              );
              context.go('/projects');
            },
            child: Text('Delete', style: TextStyle(color: cs.error)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PROGRESS CARD
// ─────────────────────────────────────────────
class _ProgressCard extends StatelessWidget {
  final ColorScheme cs;
  final ProjectEntity project;

  const _ProgressCard({required this.cs, required this.project});

  String _formatDueDate(DateTime? dueDate) {
    if (dueDate == null) return 'No due date';
    final diff = dueDate.difference(DateTime.now()).inDays;
    if (diff < 0) return 'Overdue';
    if (diff == 0) return 'Due today';
    if (diff == 1) return '1 day left';
    return '$diff days left';
  }

  @override
  Widget build(BuildContext context) {
    final progressPercent = (project.progress * 100).toInt();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary, cs.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.2),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          /// Decorative circles
          Positioned(
            right: -64,
            top: -64,
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -48,
            bottom: -48,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),

          /// Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Project Progress",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$progressPercent%",
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      project.status.name.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${project.completedTasks}/${project.totalTasks} tasks completed",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  Text(
                    _formatDueDate(project.dueDate),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: project.progress,
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              /// Priority badge
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${project.priority.name.toUpperCase()} PRIORITY',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TaskSection extends StatefulWidget {
  final ColorScheme cs;
  final String projectId;
  final String workspaceId;

  const _TaskSection({
    required this.cs,
    required this.projectId,
    required this.workspaceId,
  });

  @override
  State<_TaskSection> createState() => _TaskSectionState();
}

class _TaskSectionState extends State<_TaskSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskBloc>().add(
        TasksLoadRequested(
          workspaceId: widget.workspaceId,
          projectId: widget.projectId,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = widget.cs;

    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        if (state is TaskLoading) {
          return Center(child: CircularProgressIndicator(color: cs.primary));
        } else {
          if (state is TaskError) {
            return Center(
              child: Text(state.message, style: TextStyle(color: cs.error)),
            );
          }

          if (state is TasksLoaded) {
            final activeTasks = state.tasks
                .where((t) => !t.isCompleted)
                .toList();
            final completedTasks = state.tasks
                .where((t) => t.isCompleted)
                .toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Tasks",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: cs.outline),
                      ),
                      child: Text(
                        "${state.tasks.length} tasks",
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Empty state
                if (state.tasks.isEmpty)
                  Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        Icon(
                          Icons.task_outlined,
                          size: 48,
                          color: cs.onSurface.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "No tasks yet",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Tap 'Add New Task' to get started",
                          style: TextStyle(
                            fontSize: 13,
                            color: cs.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Active tasks
                if (activeTasks.isNotEmpty) ...[
                  Text(
                    "Active",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface.withValues(alpha: 0.5),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...activeTasks.map(
                    (task) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _TaskTile(
                        cs: cs,
                        task: task,
                        onToggle: () {
                          final authState = context.read<AuthBloc>().state;
                          if (authState is AuthAuthenticated) {
                            context.read<TaskBloc>().add(
                              TaskToggleRequested(
                                taskId: task.id,
                                completedBy: authState.user.uid,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ],

                // Completed tasks
                if (completedTasks.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    "Completed",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface.withValues(alpha: 0.5),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...completedTasks.map(
                    (task) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _TaskTile(
                        cs: cs,
                        task: task,
                        onToggle: () {
                          final authState = context.read<AuthBloc>().state;
                          if (authState is AuthAuthenticated) {
                            context.read<TaskBloc>().add(
                              TaskToggleRequested(
                                taskId: task.id,
                                completedBy: authState.user.uid,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ],
            );
          }

          return const SizedBox.shrink();
        }
      },
    );
  }
}

// ─────────────────────────────────────────────
// TASK SECTION — mock for now
// TODO: wire to TaskBloc in next step
// ─────────────────────────────────────────────
// class _TaskSection extends StatelessWidget {
//   final ColorScheme cs;

//   const _TaskSection({required this.cs});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               "Tasks",
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: cs.onSurface,
//               ),
//             ),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               decoration: BoxDecoration(
//                 color: cs.surface,
//                 borderRadius: BorderRadius.circular(999),
//                 border: Border.all(color: cs.outline),
//               ),
//               child: Text(
//                 "0 tasks",
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: cs.onSurface.withValues(alpha: 0.5),
//                 ),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 24),
//         Center(
//           child: Column(
//             children: [
//               Icon(
//                 Icons.task_outlined,
//                 size: 48,
//                 color: cs.onSurface.withValues(alpha: 0.3),
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 "No tasks yet",
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: cs.onSurface.withValues(alpha: 0.5),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 "Tap 'Add New Task' to get started",
//                 style: TextStyle(
//                   fontSize: 13,
//                   color: cs.onSurface.withValues(alpha: 0.4),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// ─────────────────────────────────────────────
// TASK TILE
// ─────────────────────────────────────────────
// class _TaskTile extends StatelessWidget {
//   final ColorScheme cs;
//   final String title;
//   final String? priority;
//   final Color? priorityColor;
//   final String? dueDate;
//   final Color? dueDateColor;
//   final bool isCompleted;

//   const _TaskTile({
//     required this.cs,
//     required this.title,
//     this.priority,
//     this.priorityColor,
//     this.dueDate,
//     this.dueDateColor,
//     this.isCompleted = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: isCompleted ? cs.surface.withValues(alpha: 0.5) : cs.surface,
//         border: Border.all(
//           color: isCompleted ? cs.outline.withValues(alpha: 0.5) : cs.outline,
//         ),
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             width: 24,
//             height: 24,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: isCompleted ? cs.primary : Colors.transparent,
//               border: Border.all(
//                 color: isCompleted
//                     ? cs.primary
//                     : cs.primary.withValues(alpha: 0.3),
//                 width: 2,
//               ),
//             ),
//             child: isCompleted
//                 ? const Icon(Icons.check_rounded, color: Colors.white, size: 12)
//                 : null,
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               title,
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: isCompleted
//                     ? cs.onSurface.withValues(alpha: 0.5)
//                     : cs.onSurface,
//                 decoration: isCompleted ? TextDecoration.lineThrough : null,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class _TaskTile extends StatelessWidget {
  final ColorScheme cs;
  final TaskEntity task;
  final VoidCallback onToggle;

  const _TaskTile({
    required this.cs,
    required this.task,
    required this.onToggle,
  });

  Color _priorityColor() {
    switch (task.priority) {
      case TaskPriority.high:
        return cs.error;
      case TaskPriority.medium:
        return AppColors.warning;
      case TaskPriority.low:
        return AppColors.success;
      case TaskPriority.none:
        return cs.onSurface.withValues(alpha: 0.3);
    }
  }

  String _formatDueDate() {
    if (task.dueDate == null) return '';
    final diff = task.dueDate!.difference(DateTime.now()).inDays;
    if (diff < 0) return 'Overdue';
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    return '${task.dueDate!.day}/${task.dueDate!.month}';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go('/task/${task.id}'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: task.isCompleted
              ? cs.surface.withValues(alpha: 0.5)
              : cs.surface,
          border: Border.all(
            color: task.isCompleted
                ? cs.outline.withValues(alpha: 0.5)
                : cs.outline,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Checkbox
            GestureDetector(
              onTap: onToggle,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: task.isCompleted ? cs.primary : Colors.transparent,
                  border: Border.all(
                    color: task.isCompleted
                        ? cs.primary
                        : cs.primary.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: task.isCompleted
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 12,
                      )
                    : null,
              ),
            ),

            const SizedBox(width: 12),

            /// Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: task.isCompleted
                                ? cs.onSurface.withValues(alpha: 0.5)
                                : cs.onSurface,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                      if (task.priority != TaskPriority.none &&
                          !task.isCompleted)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _priorityColor().withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            task.priority.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: _priorityColor(),
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (!task.isCompleted && task.dueDate != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 12,
                          color: task.dueDate!.isBefore(DateTime.now())
                              ? cs.error
                              : cs.onSurface.withValues(alpha: 0.4),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDueDate(),
                          style: TextStyle(
                            fontSize: 12,
                            color: task.dueDate!.isBefore(DateTime.now())
                                ? cs.error
                                : cs.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (task.checklist.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      '${task.checklist.where((c) => c.isCompleted).length}/${task.checklist.length} subtasks',
                      style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ADD TASK BUTTON
// ─────────────────────────────────────────────
class _AddTaskButton extends StatelessWidget {
  final ColorScheme cs;
  final String projectId;

  const _AddTaskButton({required this.cs, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            cs.surface.withValues(alpha: 0),
            cs.surface.withValues(alpha: 0.9),
            cs.surface,
          ],
        ),
      ),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.brandGradient,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              isDismissible: true,
              builder: (_) => Container(
                height: MediaQuery.of(context).size.height * 0.92,
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: AddTaskPage(projectId: projectId),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          icon: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
          label: const Text(
            "Add New Task",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
