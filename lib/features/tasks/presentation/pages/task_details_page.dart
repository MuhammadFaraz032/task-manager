import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:task_manager/core/theme/themecolors.dart';
import 'package:task_manager/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:task_manager/features/auth/presentation/bloc/auth_state.dart';
import 'package:task_manager/features/members/presentation/bloc/member_bloc.dart';
import 'package:task_manager/features/members/presentation/bloc/member_state.dart';
import 'package:task_manager/features/tasks/domain/entities/comment_entity.dart';
import 'package:task_manager/features/tasks/domain/entities/task_entity.dart';
import 'package:task_manager/features/tasks/presentation/bloc/comment_bloc.dart';
import 'package:task_manager/features/tasks/presentation/bloc/comment_event.dart';
import 'package:task_manager/features/tasks/presentation/bloc/comment_state.dart';
import 'package:task_manager/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:task_manager/features/tasks/presentation/bloc/task_event.dart';
import 'package:task_manager/features/tasks/presentation/bloc/task_state.dart';
import 'package:task_manager/features/tasks/presentation/pages/add_task_page.dart';
import 'package:task_manager/core/di/injection_container.dart';
import 'package:task_manager/features/workspace/presentation/cubit/workspace_cubit.dart';

class TaskDetailPage extends StatelessWidget {
  final String taskId;

  const TaskDetailPage({super.key, this.taskId = ''});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
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
        body: Center(child: CircularProgressIndicator(color: cs.primary)),
      );
    }

    // LEARNING: CommentBloc is scoped to this page only
    // We use BlocProvider here to create a fresh instance
    // that lives only as long as this page is open
    return BlocProvider(
      create: (_) => getIt<CommentBloc>(),
      child: _TaskDetailView(task: task),
    );
  }
}

class _TaskDetailView extends StatefulWidget {
  final TaskEntity task;

  const _TaskDetailView({required this.task});

  @override
  State<_TaskDetailView> createState() => _TaskDetailViewState();
}

class _TaskDetailViewState extends State<_TaskDetailView> {
  late List<ChecklistItem> _checklist;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checklist = List.from(widget.task.checklist);
    _loadComments();
  }

  @override
  void didUpdateWidget(_TaskDetailView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task != widget.task) {
      _checklist = List.from(widget.task.checklist);
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _loadComments() {
    final workspaceId =
        context.read<WorkspaceCubit>().currentWorkspaceId;
    if (workspaceId != null) {
      context.read<CommentBloc>().add(
            CommentsLoadRequested(
              workspaceId: workspaceId,
              taskId: widget.task.id,
            ),
          );
    }
  }

  void _addComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    final workspaceId =
        context.read<WorkspaceCubit>().currentWorkspaceId;
    if (workspaceId == null) return;

    context.read<CommentBloc>().add(
          CommentAddRequested(
            workspaceId: workspaceId,
            taskId: widget.task.id,
            text: text,
            createdBy: authState.user.uid,
            createdByName: authState.user.fullName,
          ),
        );

    _commentController.clear();
  }

  void _deleteComment(String commentId) {
    final workspaceId =
        context.read<WorkspaceCubit>().currentWorkspaceId;
    if (workspaceId == null) return;

    context.read<CommentBloc>().add(
          CommentDeleteRequested(
            workspaceId: workspaceId,
            taskId: widget.task.id,
            commentId: commentId,
          ),
        );
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Delete Task', style: TextStyle(color: cs.onSurface)),
          content: Text(
            'Are you sure you want to delete "${widget.task.title}"?',
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
              child: Text('Delete', style: TextStyle(color: cs.error)),
            ),
          ],
        );
      },
    );
  }

  void _editTask() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (_) => BlocProvider.value(
        value: context.read<TaskBloc>(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.92,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: AddTaskPage(task: widget.task),
        ),
      ),
    );
  }

  String _formatDueDate(DateTime? dueDate) {
    if (dueDate == null) return 'No due date';
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dueDate.month - 1]} ${dueDate.day}, ${dueDate.year}';
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
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
    final authState = context.read<AuthBloc>().state;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Column(
        children: [
          /// Header
          SafeArea(
            bottom: false,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  Text(
                    task.projectId != null ? 'PROJECT TASK' : 'STANDALONE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: cs.onSurface,
                    ),
                  ),
                  InkWell(
                    onTap: _editTask,
                    borderRadius: BorderRadius.circular(8),
                    child: Icon(Icons.edit_outlined,
                        size: 20, color: cs.primary),
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
                                  colors: AppColors.brandGradient),
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                        ? const Icon(Icons.check_rounded,
                                            size: 14, color: Colors.white)
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
                                    border: Border.all(color: cs.outline),
                                    borderRadius:
                                        BorderRadius.circular(999),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.calendar_today_rounded,
                                          size: 12,
                                          color: cs.onSurface
                                              .withValues(alpha: 0.4)),
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
                                              .withValues(alpha: 0.3)),
                                      borderRadius:
                                          BorderRadius.circular(999),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.flag_rounded,
                                            size: 12,
                                            color: _priorityColor(cs)),
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
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Created By + Assigned To Row
                  BlocBuilder<MemberBloc, MemberState>(
                    builder: (context, memberState) {
                      final members = memberState is MembersLoaded
                          ? memberState.members
                          : <dynamic>[];

                      String createdByName = 'Someone';
                      try {
                        final creator = members
                            .firstWhere((m) => m.uid == task.createdBy);
                        createdByName = creator.fullName;
                      } catch (_) {}

                      String? assigneeName;
                      if (task.assignedTo != null) {
                        try {
                          final assignee = members
                              .firstWhere((m) => m.uid == task.assignedTo);
                          assigneeName = assignee.fullName;
                        } catch (_) {}
                      }

                      return Row(
                        children: [
                          Expanded(
                            child: _InfoCard(
                              cs: cs,
                              label: 'CREATED BY',
                              name: createdByName,
                            ),
                          ),
                          if (assigneeName != null) ...[
                            const SizedBox(width: 12),
                            Expanded(
                              child: _InfoCard(
                                cs: cs,
                                label: 'ASSIGNED TO',
                                name: assigneeName,
                              ),
                            ),
                          ],
                        ],
                      );
                    },
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
                              color: cs.onSurface.withValues(alpha: 0.4),
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
                                color: cs.onSurface.withValues(alpha: 0.7),
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
                                  color:
                                      cs.onSurface.withValues(alpha: 0.4),
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
                                widthFactor: progress.clamp(0.0, 1.0),
                                child: Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                        colors: AppColors.brandGradient),
                                    borderRadius:
                                        BorderRadius.circular(999),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ..._checklist.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: InkWell(
                                onTap: () => _toggleChecklist(index),
                                borderRadius: BorderRadius.circular(24),
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
                                                color: Colors.white)
                                            : null,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        item.title,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: item.isCompleted
                                              ? cs.onSurface
                                                  .withValues(alpha: 0.4)
                                              : cs.onSurface
                                                  .withValues(alpha: 0.9),
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

                  const SizedBox(height: 16),

                  /// Comments Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'COMMENTS',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                                color: cs.onSurface.withValues(alpha: 0.4),
                              ),
                            ),
                            BlocBuilder<CommentBloc, CommentState>(
                              builder: (context, state) {
                                final count = state is CommentsLoaded
                                    ? state.comments.length
                                    : 0;
                                return Text(
                                  '$count comment${count == 1 ? '' : 's'}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: cs.primary,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Comment input
                        Container(
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: cs.outline),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _commentController,
                                  style: TextStyle(
                                      fontSize: 14, color: cs.onSurface),
                                  decoration: InputDecoration(
                                    hintText: 'Add a comment...',
                                    hintStyle: TextStyle(
                                      fontSize: 14,
                                      color: cs.onSurface
                                          .withValues(alpha: 0.4),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: GestureDetector(
                                  onTap: _addComment,
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: cs.primary,
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.send_rounded,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Comments list
                        BlocBuilder<CommentBloc, CommentState>(
                          builder: (context, state) {
                            if (state is CommentLoading) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            if (state is CommentsLoaded) {
                              if (state.comments.isEmpty) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Text(
                                      'No comments yet. Be the first!',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: cs.onSurface
                                            .withValues(alpha: 0.4),
                                      ),
                                    ),
                                  ),
                                );
                              }

                              return Column(
                                children: state.comments
                                    .map((comment) => _CommentCard(
                                          cs: cs,
                                          comment: comment,
                                          isOwner: authState
                                                  is AuthAuthenticated &&
                                              authState.user.uid ==
                                                  comment.createdBy,
                                          timeAgo:
                                              _timeAgo(comment.createdAt),
                                          onDelete: () =>
                                              _deleteComment(comment.id),
                                        ))
                                    .toList(),
                              );
                            }

                            return const SizedBox();
                          },
                        ),
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
                Expanded(
                  child: GestureDetector(
                    onTap: _toggleComplete,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: task.isCompleted
                            ? null
                            : const LinearGradient(
                                colors: AppColors.brandGradient,
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                        color: task.isCompleted
                            ? const Color(0xFFF59E0B).withValues(alpha: 0.12)
                            : null,
                        borderRadius: BorderRadius.circular(24),
                        border: task.isCompleted
                            ? Border.all(
                                color: const Color(0xFFF59E0B)
                                    .withValues(alpha: 0.4))
                            : null,
                        boxShadow: task.isCompleted
                            ? []
                            : [
                                BoxShadow(
                                  color: cs.primary.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            task.isCompleted
                                ? Icons.replay_rounded
                                : Icons.check_circle_outline_rounded,
                            size: 16,
                            color: task.isCompleted
                                ? const Color(0xFFF59E0B)
                                : Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            task.isCompleted
                                ? 'Reopen Task'
                                : 'Mark as Complete',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: task.isCompleted
                                  ? const Color(0xFFF59E0B)
                                  : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
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
                    child: Icon(Icons.delete_outline_rounded,
                        size: 18, color: cs.error),
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

// ─────────────────────────────────────────────
// COMMENT CARD
// ─────────────────────────────────────────────
class _CommentCard extends StatelessWidget {
  final ColorScheme cs;
  final CommentEntity comment;
  final bool isOwner;
  final String timeAgo;
  final VoidCallback onDelete;

  const _CommentCard({
    required this.cs,
    required this.comment,
    required this.isOwner,
    required this.timeAgo,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border.all(color: cs.outline),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: cs.primaryContainer,
              child: Text(
                comment.createdByName.isNotEmpty
                    ? comment.createdByName[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: cs.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        comment.createdByName,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            timeAgo,
                            style: TextStyle(
                              fontSize: 11,
                              color: cs.onSurface.withValues(alpha: 0.4),
                            ),
                          ),
                          if (isOwner) ...[
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: onDelete,
                              child: Icon(
                                Icons.delete_outline_rounded,
                                size: 14,
                                color: cs.error.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    comment.text,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: cs.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
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
// INFO CARD
// ─────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final ColorScheme cs;
  final String label;
  final String name;

  const _InfoCard({
    required this.cs,
    required this.label,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border.all(color: cs.outline),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: cs.onSurface.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: cs.primaryContainer,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: cs.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}