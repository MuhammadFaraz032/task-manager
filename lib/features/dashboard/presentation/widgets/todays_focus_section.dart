import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:task_manager/features/auth/presentation/bloc/auth_state.dart';
import 'package:task_manager/features/projects/presentation/bloc/project_bloc.dart';
import 'package:task_manager/features/projects/presentation/bloc/project_state.dart';
import 'package:task_manager/features/tasks/domain/entities/task_entity.dart';
import 'package:task_manager/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:task_manager/features/tasks/presentation/bloc/task_event.dart';
import 'package:task_manager/features/tasks/presentation/bloc/task_state.dart';

class TodaysFocusSection extends StatelessWidget {
  const TodaysFocusSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final taskState = context.watch<TaskBloc>().state;
    final projectState = context.watch<ProjectBloc>().state;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Debug prints
    // print('📅 TODAY: $today');
    // print('📊 TASK STATE: ${taskState.runtimeType}');
    
    // Build project name lookup
    final projectNames = <String, String>{};
    if (projectState is ProjectsLoaded) {
      for (final p in projectState.projects) {
        projectNames[p.id] = p.name;
      }
      // print('📁 Projects loaded: ${projectState.projects.length}');
    } else {
      // print('📁 Project state is NOT loaded: ${projectState.runtimeType}');
    }
    
    // Filter tasks due today and not completed
    List<TaskEntity> todaysTasks = [];
    if (taskState is TasksLoaded) {
      // print('✅ Tasks loaded: ${taskState.tasks.length} total tasks');
      for (final task in taskState.tasks) {
        // print('  - Task: ${task.title}, dueDate: ${task.dueDate}, status: ${task.status}');
        if (task.dueDate != null) {
          final dueDate = DateTime(
            task.dueDate!.year,
            task.dueDate!.month,
            task.dueDate!.day,
          );
          final isToday = dueDate.isAtSameMomentAs(today);
          final isNotCompleted = task.status != TaskStatus.completed;
          // print('    dueDate normalized: $dueDate, isToday: $isToday, isNotCompleted: $isNotCompleted');
          if (isToday && isNotCompleted) {
            todaysTasks.add(task);
          }
        }
      }
      // print('🎯 Tasks due today: ${todaysTasks.length}');
    } else {
      // print('❌ Task state is NOT loaded: ${taskState.runtimeType}');
      if (taskState is TaskInitial) {
        // print('  → TaskBloc is initial, need to load tasks');
      }
    }
    
    final todayFormatted = DateFormat('EEE, MMM d').format(now);
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Today's Focus",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            Text(
              todayFormatted,
              style: TextStyle(
                fontSize: 12,
                color: cs.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (todaysTasks.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.outline),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.celebration_rounded,
                    size: 32,
                    color: cs.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No tasks due today!',
                    style: TextStyle(
                      color: cs.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          )
        else ...[
          ...todaysTasks.map((task) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TaskItem(
              task: task,
              projectName: task.projectId != null ? projectNames[task.projectId] : null,
            ),
          )),
          if (todaysTasks.length >= 5)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextButton(
                onPressed: () {
                  context.push('/tasks');
                },
                child: Text(
                  'View All Tasks →',
                  style: TextStyle(
                    color: cs.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class TaskItem extends StatelessWidget {
  final TaskEntity task;
  final String? projectName;

  const TaskItem({
    super.key,
    required this.task,
    this.projectName,
  });

  String _getTimeFromDueDate() {
    if (task.dueDate == null) return '';
    return DateFormat('h:mm a').format(task.dueDate!);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isCompleted = task.isCompleted;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
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
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isCompleted
                      ? cs.primary
                      : cs.onSurface.withValues(alpha: 0.3),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
                color: isCompleted
                    ? cs.primary.withValues(alpha: 0.1)
                    : Colors.transparent,
              ),
              child: isCompleted
                  ? Icon(Icons.check_rounded, color: cs.primary, size: 16)
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  projectName != null ? 'Project: $projectName' : 'Standalone Task',
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: cs.background,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: cs.outline),
            ),
            child: Text(
              _getTimeFromDueDate(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: cs.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}