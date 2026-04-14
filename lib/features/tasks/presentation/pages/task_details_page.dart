import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:task_manager/core/theme/themecolors.dart';
import 'package:task_manager/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:task_manager/features/auth/presentation/bloc/auth_state.dart';
import 'package:task_manager/features/tasks/domain/entities/task_entity.dart';
import 'package:task_manager/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:task_manager/features/tasks/presentation/bloc/task_event.dart';
import 'package:task_manager/features/tasks/presentation/bloc/task_state.dart';

class TaskDetailPage extends StatelessWidget {
  final String taskId;

  const TaskDetailPage({super.key, this.taskId = ''});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // LEARNING: Get task from TaskBloc which already
    // has all tasks loaded — no separate API call needed
    final taskState = context.watch<TaskBloc>().state;
    TaskEntity? task;

    if (taskState is TasksLoaded) {
      try {
        task = taskState.tasks.firstWhere((t) => t.id == taskId);
      } catch (_) {
        task = null;
      }
    }

    if (task == null) {
      return Scaffold(
        backgroundColor: cs.surface,
        body: Center(
          child: CircularProgressIndicator(color: cs.primary),
        ),
      );
    }

    return _TaskDetailView(task: task);
  }
}

class _TaskDetailView extends StatefulWidget {
  final TaskEntity task;

  const _TaskDetailView({required this.task});

  @override
  State<_TaskDetailView> createState() => _TaskDetailViewState();
}

class _TaskDetailViewState extends State<_TaskDetailView> {
  // LEARNING: Local checklist state for immediate UI feedback
  // before Firestore confirms the update
  late List<ChecklistItem> _checklist;

  @override
  void initState() {
    super.initState();
    _checklist = List.from(widget.task.checklist);
  }

  @override
  void didUpdateWidget(_TaskDetailView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync checklist when task updates from Firestore
    if (oldWidget.task != widget.task) {
      _checklist = List.from(widget.task.checklist);
    }
  }

  void _toggleChecklist(int index) {
    setState(() {
      final item = _checklist[index];
      _checklist[index] = ChecklistItem(
        id: item.id,
        title: item.title,
        isCompleted: !item.isCompleted,
      );
    });

    // Save updated checklist to Firestore
    context.read<TaskBloc>().add(
          TaskUpdateRequested(
            taskId: widget.task.id,
            title: widget.task.title,
            description: widget.task.description,
            priority: widget.task.priority,
            status: widget.task.status,
            dueDate: widget.task.dueDate,
            checklist: _checklist,
          ),
        );
  }

  void _toggleComplete() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    context.read<TaskBloc>().add(
          TaskToggleRequested(
            taskId: widget.task.id,
            completedBy: authState.user.uid,
          ),
        );
  }

  void _deleteTask() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    showDialog(
      context: context,
      builder: (dialogContext) {
        final cs = Theme.of(context).colorScheme;
        return AlertDialog(
          backgroundColor: cs.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Delete Task',
            style: TextStyle(color: cs.onSurface),
          ),
          content: Text(
            'Are you sure you want to delete "${widget.task.title}"?',
            style: TextStyle(
                color: cs.onSurface.withValues(alpha: 0.7)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel',
                  style: TextStyle(color: cs.onSurface)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<TaskBloc>().add(
                      TaskDeleteRequested(
                        taskId: widget.task.id,
                        deletedBy: authState.user.uid,
                      ),
                    );
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/tasks');
                }
              },
              child: Text('Delete',
                  style: TextStyle(color: cs.error)),
            ),
          ],
        );
      },
    );
  }

  String _formatDueDate(DateTime? dueDate) {
    if (dueDate == null) return 'No due date';
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dueDate.month - 1]} ${dueDate.day}, ${dueDate.year}';
  }

  Color _priorityColor(ColorScheme cs) {
    switch (widget.task.priority) {
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final task = widget.task;

    final completedCount = _checklist.where((c) => c.isCompleted).length;
    final progress =
        _checklist.isEmpty ? 0.0 : completedCount / _checklist.length;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Column(
        children: [
          /// Header
          SafeArea(
            bottom: false,
            child: Container(
              height: 53,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: cs.surface,
                border: Border(bottom: BorderSide(color: cs.outline)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/tasks');
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Row(
                      children: [
                        Icon(Icons.arrow_back_ios_rounded,
                            size: 14, color: cs.primary),
                        Text(
                          'Back',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: cs.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        task.projectId != null ? 'PROJECT TASK' : 'STANDALONE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: cs.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: _deleteTask,
                    borderRadius: BorderRadius.circular(8),
                    child: Icon(
                      Icons.more_horiz_rounded,
                      size: 20,
                      color: cs.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 96),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Hero Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      border: Border.all(color: cs.outline),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -63,
                          top: -63,
                          child: Container(
                            width: 128,
                            height: 128,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: AppColors.brandGradient,
                              ),
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    task.title,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: cs.onSurface,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Completion circle
                                GestureDetector(
                                  onTap: _toggleComplete,
                                  child: AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 200),
                                    width: 28,
                                    height: 28,
                                    margin: const EdgeInsets.only(top: 4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: task.isCompleted
                                          ? cs.primary
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: task.isCompleted
                                            ? cs.primary
                                            : cs.onSurface
                                                .withValues(alpha: 0.3),
                                        width: 2,
                                      ),
                                    ),
                                    child: task.isCompleted
                                        ? const Icon(
                                            Icons.check_rounded,
                                            size: 14,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                // Due date chip
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: cs.surface,
                                    border:
                                        Border.all(color: cs.outline),
                                    borderRadius:
                                        BorderRadius.circular(999),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.calendar_today_rounded,
                                        size: 12,
                                        color: cs.onSurface
                                            .withValues(alpha: 0.4),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        _formatDueDate(task.dueDate)
                                            .toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: cs.onSurface
                                              .withValues(alpha: 0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Priority chip
                                if (task.priority != TaskPriority.none)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _priorityColor(cs)
                                          .withValues(alpha: 0.1),
                                      border: Border.all(
                                        color: _priorityColor(cs)
                                            .withValues(alpha: 0.3),
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(999),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.flag_rounded,
                                          size: 12,
                                          color: _priorityColor(cs),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${task.priority.name.toUpperCase()} PRIORITY',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: _priorityColor(cs),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                // Status chip
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: task.isCompleted
                                        ? cs.primary.withValues(alpha: 0.1)
                                        : cs.surfaceContainerHighest,
                                    borderRadius:
                                        BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    task.status.name.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: task.isCompleted
                                          ? cs.primary
                                          : cs.onSurface
                                              .withValues(alpha: 0.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// Description
                  if (task.description.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DESCRIPTION',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color:
                                  cs.onSurface.withValues(alpha: 0.4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cs.surface,
                              border: Border.all(color: cs.outline),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Text(
                              task.description,
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.6,
                                color: cs.onSurface
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  /// Checklist
                  if (_checklist.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'CHECKLIST',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                  color: cs.onSurface
                                      .withValues(alpha: 0.4),
                                ),
                              ),
                              Text(
                                '$completedCount/${_checklist.length} completed',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: cs.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Progress bar
                          Stack(
                            children: [
                              Container(
                                width: double.infinity,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: cs.outline,
                                  borderRadius:
                                      BorderRadius.circular(999),
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor: progress,
                                child: Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: AppColors.brandGradient,
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(999),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Checklist items
                          ..._checklist.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: InkWell(
                                onTap: () => _toggleChecklist(index),
                                borderRadius:
                                    BorderRadius.circular(24),
                                child: Container(
                                  height: 46,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: cs.surface,
                                    border:
                                        Border.all(color: cs.outline),
                                    borderRadius:
                                        BorderRadius.circular(24),
                                  ),
                                  child: Row(
                                    children: [
                                      AnimatedContainer(
                                        duration: const Duration(
                                            milliseconds: 200),
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: item.isCompleted
                                              ? cs.primary
                                              : Colors.transparent,
                                          border: Border.all(
                                            color: cs.onSurface
                                                .withValues(alpha: 0.3),
                                            width: 2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: item.isCompleted
                                            ? const Icon(
                                                Icons.check_rounded,
                                                size: 14,
                                                color: Colors.white,
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        item.title,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: item.isCompleted
                                              ? cs.onSurface.withValues(
                                                  alpha: 0.4)
                                              : cs.onSurface.withValues(
                                                  alpha: 0.9),
                                          decoration: item.isCompleted
                                              ? TextDecoration.lineThrough
                                              : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          /// Sticky Footer
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            decoration: BoxDecoration(
              color: cs.surface,
              border: Border(top: BorderSide(color: cs.outline)),
            ),
            child: Row(
              children: [
                /// Mark Complete / Reopen
                Expanded(
                  child: GestureDetector(
                    onTap: _toggleComplete,
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: task.isCompleted
                            ? cs.surfaceContainerHighest
                            : cs.primary,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            task.isCompleted
                                ? Icons.refresh_rounded
                                : Icons.check_rounded,
                            size: 15,
                            color: task.isCompleted
                                ? cs.onSurface
                                : Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            task.isCompleted ? 'Reopen' : 'Complete',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: task.isCompleted
                                  ? cs.onSurface
                                  : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                /// Delete Button
                InkWell(
                  onTap: _deleteTask,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: cs.error.withValues(alpha: 0.1),
                      border: Border.all(
                          color: cs.error.withValues(alpha: 0.2)),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: cs.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}