import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:task_manager/features/auth/presentation/bloc/auth_state.dart';
import 'package:task_manager/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:task_manager/features/tasks/presentation/bloc/task_state.dart';
import 'package:task_manager/features/tasks/domain/entities/task_entity.dart';

class GreetingSection extends StatelessWidget {
  const GreetingSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    // Get user name
    final authState = context.watch<AuthBloc>().state;
    String userName = 'User';
    if (authState is AuthAuthenticated) {
      userName = authState.user.fullName.split(' ').first;
    }
    
    // Get tasks due today
    final taskState = context.watch<TaskBloc>().state;
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    
    int tasksDueToday = 0;
    if (taskState is TasksLoaded) {
      tasksDueToday = taskState.tasks.where((task) {
        if (task.dueDate == null) return false;
        final dueDate = DateTime(
          task.dueDate!.year,
          task.dueDate!.month,
          task.dueDate!.day,
        );
        return dueDate == today && task.status != TaskStatus.completed;
      }).length;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF2563EB), Color(0xFF8B5CF6)],
          ).createShader(bounds),
          child: Text(
            'Hello, $userName!',
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 14,
              color: cs.onSurface.withValues(alpha: 0.6),
            ),
            children: [
              const TextSpan(text: 'You have '),
              TextSpan(
                text: '$tasksDueToday task${tasksDueToday != 1 ? 's' : ''}',
                style: TextStyle(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: ' due today.'),
            ],
          ),
        ),
      ],
    );
  }
}